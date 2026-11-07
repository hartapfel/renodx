"""Rebuild cloud-shadow adapters from hash-verified native captures.

The manifest names the world-coordinate SSA values already used by each
native cloud projection and the remaster's separate skylight contributions.
All native material, terrain, light and ray-tracing instructions remain input
to DXC's linker. No decompilation or old Remastered mod code is used.
"""

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import zlib


HELPERS = {
    "replace": '@"\\01?HFCloudShadow@@YAMMMMM@Z"',
    "neutralize": '@"\\01?HFCloudNeutralize@@YAMMMMM@Z"',
    "multiply": '@"\\01?HFCloudShadowMultiply@@YAMMMMM@Z"',
}
NIGHT_SKYLIGHT = '@"\\01?HFNightSkylight@@YAMXZ"'


def run(arguments):
    return subprocess.check_output([str(argument) for argument in arguments], stderr=subprocess.STDOUT).decode(errors="replace").replace("\r\n", "\n")


def promote_handles(text):
    """Express SM6.3 resource handles in SM6.6's explicit binding form.

    DXC's linker cannot consume the native legacy createHandle instructions.
    Every captured range here is a single, statically indexed descriptor. Its
    original metadata supplies the register, space, kind, stride and size.
    The game already requires SM6.6 for its native pixel/compute shaders.
    """
    metadata = dict(re.findall(r"^!(\d+) = (.*)$", text, re.M))
    resource_id = re.search(r"!dx.resources = !\{!(\d+)\}", text)[1]
    groups = re.fullmatch(r"!\{(.*)\}", metadata[resource_id])[1].split(", ")
    properties = {}
    for resource_class, group in enumerate(groups):
        if group == "null":
            continue
        for item in re.findall(r"!(\d+)", metadata[group[1:]]):
            entry = re.fullmatch(r'!\{i32 (\d+), (.+?)\* undef, !"", i32 (\d+), i32 (\d+), i32 (\d+), (.*)\}', metadata[item])
            if entry is None:
                raise ValueError("Unsupported native descriptor metadata " + metadata[item])
            index, kind_name, space, slot, count, tail = entry.groups()
            if count != "1":
                raise ValueError("Native handle promotion requires a single descriptor")
            if resource_class == 0:
                kind = int(re.search(r"i32 (\d+)", tail)[1])
                if kind == 12:
                    stride_id = re.findall(r"!(\d+)", tail)[0]
                    stride = int(re.fullmatch(r"!\{i32 1, i32 (\d+)\}", metadata[stride_id])[1])
                    flags, size = 12, stride
                elif kind == 11:
                    flags, size = 11, 0
                else:
                    if "<float>" in kind_name:
                        components = 1
                    elif "vector<float, 4>" in kind_name:
                        components = 4
                    else:
                        raise ValueError("Unsupported native texture component type " + kind_name)
                    flags, size = kind, 9 + (components << 8)
            elif resource_class == 2:
                flags, size = 13, int(re.search(r"i32 (\d+)", tail)[1])
            elif resource_class == 3:
                flags, size = (32782 if tail.startswith("i32 1") else 14), 0
            else:
                raise ValueError("Unexpected UAV in a native vertex shader")
            properties[resource_class, int(index)] = (space, slot, flags, size)

    def handle(match):
        name, resource_class, index, slot = match.groups()
        space, lower, flags, size = properties[int(resource_class), int(index)]
        if slot != lower:
            raise ValueError("Unexpected dynamic native descriptor index")
        return (
            f"  %hf_handle_{name} = call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, "
            f"%dx.types.ResBind {{ i32 {lower}, i32 {lower}, i32 {space}, i8 {resource_class} }}, i32 {slot}, i1 false)\n"
            f"  %{name} = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle %hf_handle_{name}, "
            f"%dx.types.ResourceProperties {{ i32 {flags}, i32 {size} }})"
        )

    text, count = re.subn(r"^  %(\d+) = call %dx.types.Handle @dx.op.createHandle\(i32 57, i8 (\d+), i32 (\d+), i32 (\d+), i1 false\).*$", handle, text, flags=re.M)
    if count != len(properties):
        raise ValueError("Native handle inventory changed")
    text = text.replace("%dx.types.Handle = type { i8* }", "%dx.types.Handle = type { i8* }\n%dx.types.ResBind = type { i32, i32, i32, i8 }\n%dx.types.ResourceProperties = type { i32, i32 }")
    text = text.replace('!{!"vs", i32 6, i32 3}', '!{!"vs", i32 6, i32 6}').replace("!{i32 1, i32 3}", "!{i32 1, i32 6}")
    return text + "\ndeclare %dx.types.Handle @dx.op.createHandleFromBinding(i32, %dx.types.ResBind, i32, i1)\ndeclare %dx.types.Handle @dx.op.annotateHandle(i32, %dx.types.Handle, %dx.types.ResourceProperties)\n"


def patch_module(text, patches, night_skylight=()):
    applied = 0

    def function(match):
        nonlocal applied
        body = match[0]
        for patch in patches:
            if body.splitlines()[0] != patch["function"]:
                continue
            assignment = patch["assignment"]
            if body.count(assignment) != 1:
                raise ValueError("Native cloud visibility assignment changed")
            target, operation = assignment.split(" = ", 1)
            native = "%hf_native_" + target[1:]
            arguments = ", ".join("float " + value for value in patch["world"])
            helper = HELPERS[patch.get("mode", "replace")]
            replacement = f"{native} = {operation}\n  {target} = call float {helper}({arguments}, float {native})"
            body = body.replace(assignment, replacement)
            applied += 1
        return body

    result = re.sub(r"^define [^\n]+\n.*?^}", function, text, flags=re.M | re.S)
    if applied != len(patches):
        raise ValueError("Native cloud function inventory changed")
    for patch in night_skylight:
        assignment = patch["assignment"]
        if result.count(assignment) != 1:
            raise ValueError("Native skylight assignment changed")
        target, operation = assignment.split(" = ", 1)
        native = "%hf_sky_native_" + target[1:]
        gain = "%hf_sky_gain_" + target[1:]
        replacement = f"{native} = {operation}\n  {gain} = call float {NIGHT_SKYLIGHT}()"
        if condition := patch.get("condition"):
            replacement += f"\n  {gain}_branch = select i1 {condition}, float {gain}, float 1.000000e+00"
            gain += "_branch"
        replacement += f"\n  {target} = fmul fast float {native}, {gain}"
        result = result.replace(assignment, replacement)
    if night_skylight:
        result += f"\ndeclare float {NIGHT_SKYLIGHT}()\n"
    modes = dict.fromkeys(patch.get("mode", "replace") for patch in patches)
    return result + "".join(f"\ndeclare float {HELPERS[mode]}(float, float, float, float)\n" for mode in modes)


def patch_path_materials(text, exports):
    # Reuse the audited diffuse and GGX sites from the Graphics addon. Patch
    # the original SSA before adding cloud visibility, which shares no sites.
    import prepare_diffuse
    import prepare_specular
    applied = set()

    def rewrite(match):
        head, body, tail = match.groups()
        name = re.search(r'\\01\?([^@]+)@@', head)[1]
        if name not in exports:
            return match[0]
        body, _ = prepare_diffuse.rewrite(body, name)
        body, _ = prepare_specular.rewrite(body, name)
        applied.add(name)
        return head + body + tail

    text = re.sub(r"(?ms)^(define void @[^\n]+\{\n)(.*?)(^\})", rewrite, text)
    if applied != set(exports):
        raise ValueError("Native PT export inventory changed")
    return text + "\n" + prepare_diffuse.DECLARATION + prepare_specular.DECLARATIONS


def audit(native, linked, path_materials=False):
    def operations(text):
        return Counter(re.findall(r"call [^\n]*@dx.op\.([^(]+)", text))

    before, after = operations(native), operations(linked)
    # Helper math adds scalar/half/CBV/raw loads. Native texture reads, writes,
    # visibility queries, atomics, barriers and stage IO must remain intact.
    protected = ("sample", "textureLoad", "textureStore", "bufferStore", "rawBufferStore", "atomic", "barrier", "traceRay", "rayQuery", "storeOutput", "loadInput", "discard", "callShader", "acceptHit", "ignoreHit", "reportHit", "emitIndices")
    for operation in set(before) | set(after):
        if operation.startswith(protected) and before[operation] != after[operation]:
            raise ValueError(f"Native operation changed {operation}: {before[operation]} -> {after[operation]}")
    def resources(text):
        nodes = dict(re.findall(r"^!(\d+) = (.*)$", text, re.M))
        root = re.search(r"!dx.resources = !\{!(\d+)\}", text)[1]
        result = {}
        def expand(value):
            return re.sub(r"!(\d+)", lambda match: expand(nodes[match[1]]), value)
        for resource_class, group in enumerate(re.fullmatch(r"!\{(.*)\}", nodes[root])[1].split(", ")):
            if group == "null":
                continue
            for index in re.findall(r"!(\d+)", nodes[group[1:]]):
                match = re.fullmatch(r'!\{i32 \d+, .+?, !".*?", i32 (\d+), i32 (\d+), i32 (\d+), (.*)\}', nodes[index])
                if match is None:
                    raise ValueError("Unsupported resource inventory " + nodes[index])
                space, slot, count, properties = match.groups()
                result[resource_class, int(space), int(slot), int(count)] = expand(properties)
        return result
    original_resources, adapted_resources = resources(native), resources(linked)
    for binding, properties in original_resources.items():
        if adapted_resources.get(binding) != properties:
            raise ValueError(f"Native resource binding/properties changed {binding}")
    expected = {(0, 72, 0, 1)}
    if path_materials:
        expected.add((2, 56, 0, 1))
    if set(adapted_resources) - set(original_resources) != expected:
        raise ValueError("Unexpected cloud adapter resource additions")
    return {operation: after[operation] for operation in sorted(after) if operation.startswith(protected)}


def restore_native_resources(native, linked):
    """Keep lowered native bindings after library linking eliminates globals.

    Native SM6.6 handles encode bindings directly. DXC's library linker tracks
    global resource uses instead, so its dead-global pass removes metadata for
    these handles while leaving their instructions intact. Rebuild the resource
    inventory before container assembly and validation.
    """
    native_nodes = dict(re.findall(r"^!(\d+) = (.*)$", native, re.M))
    linked_nodes = dict(re.findall(r"^!(\d+) = (.*)$", linked, re.M))
    next_node = max(map(int, linked_nodes)) + 1
    appended, remap = [], {}

    def copy_node(index):
        nonlocal next_node
        if index in remap:
            return remap[index]
        destination = str(next_node)
        next_node += 1
        remap[index] = destination
        value = re.sub(r"!(\d+)", lambda match: "!" + copy_node(match[1]), native_nodes[index])
        appended.append(f"!{destination} = {value}")
        return destination

    def groups(text, nodes):
        root = re.search(r"!dx.resources = !\{!(\d+)\}", text)[1]
        return root, re.fullmatch(r"!\{(.*)\}", nodes[root])[1].split(", ")

    _, native_groups = groups(native, native_nodes)
    linked_root, linked_groups = groups(linked, linked_nodes)
    binding_pattern = r'!\{i32 \d+, .+?, !".*?", i32 (\d+), i32 (\d+), i32 (\d+),'
    merged = []
    for resource_class, (original_group, helper_group) in enumerate(zip(native_groups, linked_groups)):
        entries, bindings = [], set()
        helper_entries = {}
        if helper_group != "null":
            for helper_index in re.findall(r"!(\d+)", linked_nodes[helper_group[1:]]):
                helper_value = linked_nodes[helper_index]
                match = re.match(binding_pattern, helper_value)
                if match is None:
                    raise ValueError("Unsupported helper resource metadata " + helper_value)
                helper_entries[tuple(map(int, match.groups()))] = helper_value
        for group, nodes, original in ((original_group, native_nodes, True), (helper_group, linked_nodes, False)):
            if group == "null":
                continue
            for index in re.findall(r"!(\d+)", nodes[group[1:]]):
                value = nodes[index]
                binding = re.match(binding_pattern, value)
                if binding is None:
                    raise ValueError("Unsupported lowered resource metadata " + value)
                key = tuple(map(int, binding.groups()))
                if key in bindings:
                    continue
                bindings.add(key)
                if original and key in helper_entries:
                    value = helper_entries[key]
                elif original:
                    value = re.sub(r"!(\d+)", lambda match: "!" + copy_node(match[1]), value)
                value = re.sub(r"^!\{i32 \d+,", f"!{{i32 {len(entries)},", value)
                entry = str(next_node)
                next_node += 1
                appended.append(f"!{entry} = {value}")
                entries.append("!" + entry)
        if not entries:
            merged.append("null")
            continue
        group = str(next_node)
        next_node += 1
        appended.append(f"!{group} = !{{{', '.join(entries)}}}")
        merged.append("!" + group)
    linked = re.sub(rf"^!{linked_root} = .*$", f"!{linked_root} = !{{{', '.join(merged)}}}", linked, flags=re.M)
    type_pattern = r'^(%(?:"[^"]+"|[\w.$-]+)) = type .*?$'
    existing_types = {match[1]: match[0] for match in re.finditer(type_pattern, linked, re.M)}
    missing_types = []
    for match in re.finditer(type_pattern, native, re.M):
        if match[1] not in existing_types:
            missing_types.append(match[0])
        elif existing_types[match[1]] != match[0]:
            raise ValueError("Native resource type changed " + match[1])
    linked = linked.replace("target triple = \"dxil-ms-dx\"", "target triple = \"dxil-ms-dx\"\n" + "\n".join(missing_types))
    return linked + "\n" + "\n".join(appended) + "\n"


def header(path, shader_hash, data, original_hash, night_skylight=False, path_materials=False):
    lines = [
        "// Generated by tools/cloud_adapters.py from verified native DXIL.",
        "// Native SHA256 " + original_hash,
        "// Cloud visibility and Darker Nights skylight are adapted. See tools/cloud_adapters.json."
        if night_skylight else "// Only the cloud-visibility factor is adapted. See tools/cloud_adapters.json.",
        *(["// Also adapts native PT diffuse and specular material response."] if path_materials else []),
        "#pragma once", "#include <cstdint>",
        "namespace hartapfelfx::clouds::native {",
        f"inline constexpr uint8_t shader_{shader_hash}[] = {{",
    ]
    for offset in range(0, len(data), 16):
        lines.append("  " + ", ".join(f"0x{value:02X}" for value in data[offset:offset + 16]) + ",")
    lines += ["};", "}  // namespace hartapfelfx::clouds::native", ""]
    path.write_text("\n".join(lines))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--originals", type=Path, required=True)
    parser.add_argument("--ray-libraries", type=Path, required=True)
    parser.add_argument("--linker", type=Path, required=True)
    parser.add_argument("--dxc", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--write-headers", action="store_true")
    parser.add_argument("--shader", action="append", help="Rebuild only the specified CRC, without the 0x prefix.")
    args = parser.parse_args()
    mod = Path(__file__).resolve().parent.parent
    sys.path.insert(0, str(mod.parent / "thewitcher3remastered-graphics/raytracing"))
    manifest = json.loads((mod / "tools/cloud_adapters.json").read_text())
    if args.shader:
        manifest = {shader.upper(): manifest[shader.upper()] for shader in args.shader}
    args.output.mkdir(parents=True, exist_ok=True)
    helpers = {}
    for name, definitions in (("graphics", []), ("ray", ["-D", "HFCLOUD_RAY_LIBRARY"]),
                              ("pt", ["-D", "HFCLOUD_RAY_LIBRARY", "-D", "HFCLOUD_PATH_MATERIALS"])):
        compiled = args.output / f"helper-{name}.cso"
        assembly = args.output / f"helper-{name}.ll"
        assembled = args.output / f"helper-{name}.assembled.cso"
        run([args.dxc, "-T", "lib_6_6", "-HV", "2021", "-Ges", "-WX", *definitions, "-Fo", compiled, mod / "clouds/shadow_library.hlsli"])
        assembly.write_text(run([args.dxc, "-dumpbin", compiled]))
        # Both inputs go through the assembler to give the linker consistent
        # container compiler-version metadata without modifying native DXIL.
        run([args.linker, assembly, assembled])
        helpers[name] = assembled
    report = {}
    for shader_hash, record in manifest.items():
        profile = record["profile"]
        ray = profile.startswith("lib_")
        source = (args.ray_libraries / f"0x{shader_hash}.library.cso") if ray else (args.originals / f"0x{shader_hash}.{profile}.cso")
        data = source.read_bytes()
        if len(data) != record["bytes"] or hashlib.sha256(data).hexdigest() != record["sha256"] or zlib.crc32(data) != int(shader_hash, 16):
            raise ValueError("Native capture identity mismatch " + source.name)
        original = run([args.dxc, "-dumpbin", source])
        night_skylight = record.get("night_skylight", ())
        names = list(dict.fromkeys(re.search(r'\\01\?([^@]+)@@', patch["function"])[1] for patch in record["patches"])) if ray else []
        path_materials = bool(record.get("path_materials"))
        text = patch_path_materials(original, names) if path_materials else original
        text = patch_module(text, record["patches"], night_skylight)
        if profile == "vs_6_3":
            text = promote_handles(text)
            profile = "vs_6_6"
        assembly = args.output / f"0x{shader_hash}.patch.ll"
        binary = args.output / f"0x{shader_hash}.cso"
        assembly.write_text(text)
        entry = "-" if ray else profile[:2] + "_main"
        exports = []
        if ray:
            exports = ["-exports", ";".join(names)]
        run([args.linker, assembly, binary, helpers["pt" if path_materials else "ray" if ray else "graphics"], entry, profile, *exports])
        linked = run([args.dxc, "-dumpbin", binary])
        linked = restore_native_resources(original, linked)
        restored = args.output / f"0x{shader_hash}.linked.ll"
        restored.write_text(linked)
        run([args.linker, restored, binary, "--validate"])
        linked = run([args.dxc, "-dumpbin", binary])
        if ray:
            native_functions = set(re.findall(r'^define void (@[^\n]+?)\(', original, re.M))
            linked_functions = set(re.findall(r'^define void (@[^\n]+?)\(', linked, re.M))
            if native_functions != linked_functions or re.search(r'^define .*HFCloud(?:Shadow|Neutralize)', linked, re.M):
                raise ValueError("Native ray exports changed or helper export leaked")
        report[shader_hash] = {"native": record["sha256"], "linked": hashlib.sha256(binary.read_bytes()).hexdigest(), "profile": profile,
                               "cloud_terms": len(record["patches"]), "operations": audit(original, linked, path_materials)}
        if args.write_headers:
            header(mod / f"clouds/native/0x{shader_hash}.hpp", shader_hash, binary.read_bytes(), record["sha256"], bool(night_skylight), path_materials)
        print(f"PASS {shader_hash} {profile}, {len(record['patches'])} cloud terms, native writes/samples/queries/IO preserved")
    (args.output / "audit.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
