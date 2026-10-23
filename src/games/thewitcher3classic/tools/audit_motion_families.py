#!/usr/bin/env python3
"""Report cached skin shaders sharing audited position math AND native outputs.

First run audit_motion_cache.py, then decompile its scratch .cso files with
cmd_Decompiler.exe -D. This tool reads only original decompilations, never an
already instrumented source. --generate-vertices is an explicit offline source
generation step; review the report and run GPU equivalence tests before linking.
No shader discovery, compilation, matching or readback runs in the game.
"""
import argparse
import collections
import json
from pathlib import Path
import re
import shutil

from motion_fingerprint import Fingerprinter


def interface(source):
    return tuple(re.findall(r'out (float[1-4]?) o\d+ : (\w+)', source[source.index('void main('):].split('{', 1)[0]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('originals', type=Path)
    parser.add_argument('--generate-vertices', action='store_true')
    parser.add_argument('--generate-pixels', action='store_true')
    parser.add_argument('--test-originals', type=Path)
    parser.add_argument('--vertex-reference', help='Restrict the vertex audit to one existing audited reference; use a captured pass to resolve ambiguous interface groups')
    parser.add_argument('--vertex-list', default='object_skin_families.inc', help='Game-local registration list for explicitly selected vertex families')
    args = parser.parse_args()
    folder = Path(__file__).resolve().parents[1] / 'temporal'
    registry_text = (folder / 'object_shaders.hpp').read_text()
    registry = registry_text.split('OBJECT_PIXEL_SHADERS')[0]
    if Path(args.vertex_list).name != args.vertex_list:
        parser.error('--vertex-list must be a filename in temporal/')
    if args.vertex_reference and not re.search(r'ObjectShader\{' + re.escape(args.vertex_reference) + r',', registry):
        parser.error('--vertex-reference must name a hand-audited vertex registry entry')
    inventory = {item['hash']: item for item in json.loads((args.originals / 'inventory.json').read_text())['shaders']}
    fingerprinter = Fingerprinter()
    sources, rows, known = {}, [], collections.defaultdict(list)
    # All reference expressions are taken from pre-existing, audited registry
    # entries, never from newly generated entries in object_skin_families.inc.
    for path in sorted(args.originals.glob('0x*.hlsl')):
        if inventory[path.stem]['stage'] != 1:
            continue
        source = path.read_text(encoding='utf-8')
        sources[path.stem] = source
        row = dict(hash=path.stem)
        try:
            row['fingerprint'] = fingerprinter.position(source)
            row['interface'] = interface(source)
        except (ValueError, AttributeError, IndexError) as error:
            row['excluded'] = str(error)
        rows.append(row)
    for row in rows:
        entry = re.search(r'ObjectShader\{' + row['hash'] + r', __0x[0-9A-F]{8}, (\d+)', registry)
        if entry and 'fingerprint' in row and (not args.vertex_reference or row['hash'] == args.vertex_reference):
            known[(row['fingerprint'], row['interface'])].append((row['hash'], int(entry[1])))
    generated, eligible = [], []
    for row in rows:
        matches = known.get((row.get('fingerprint'), row.get('interface')), [])
        row['references'] = [item[0] for item in matches]
        groups = set(item[1] for item in matches)
        if len(groups) != 1:
            row.setdefault('excluded', 'No unambiguous audited position/interface pair')
            continue
        source = sources[row['hash']]
        row['group'] = groups.pop()
        row['forward'] = row['group'] in (11, 12)
        row['instanced'] = 'INSTANCE_SKINNING_DATA' in source
        row['reference_pose'] = 't1.Load' in source
        row['registered'] = row['hash'] in registry
        eligible.append(row)
        if row['registered']:
            continue
        if not args.generate_vertices:
            continue
        # Group 12 needs TEXCOORD12/13 plus separately audited clip precision.
        # Do not emit the generic TEXCOORD10/11 recipe for that interface.
        assert row['group'] != 12, 'Group-12 generation requires its own reviewed recipe'
        signature = source[source.index('void main('):].split('{', 1)[0]
        skin = re.search(r'float4 (v\d+) : INSTANCE_SKINNING_DATA0', signature)
        indices = re.search(r'uint4 (v\d+) : BLENDINDICES0', signature)
        weights = re.search(r'float4 (v\d+) : BLENDWEIGHT0', signature)
        position = re.search(r'float3 (v\d+) : POSITION0', signature)
        clip = re.search(r'out float4 (o\d+) : SV_Position0\)', signature)
        color = re.search(r'float4 (v\d+) : COLOR0', signature)
        # References constrain the entire position DAG. These additional guards
        # ensure this injection recipe uses the matching native parameter ABI.
        assert indices and weights and position and clip
        assert source.count('  return;') == 1
        assert 'cb2[4].xyz + cb2[5].xyz' in source
        if not skin:
            assert 'cb2[7].yyyy + cb2[7].xxxx' in source
        assert not row['reference_pose'] or (color and f'saturate({color[1]}.w)' in source)
        source = source.replace('void main(', '#include "./object_vertex.hlsli"\n\nvoid main(', 1)
        source = source.replace('  out float4 o0 : TEXCOORD0,', '  uint motion_instance : SV_InstanceID,\n  out float4 o0 : TEXCOORD0,', 1)
        source = source.replace(f'  out float4 {clip[1]} : SV_Position0)', f'  out float4 {clip[1]} : SV_Position0,\n  out float4 previous_clip : TEXCOORD10,\n  out nointerpolation float motion_history : TEXCOORD11)', 1)
        source = source.replace('  return;', f'  previous_clip = PreviousObjectClip({position[1]} * cb2[4].xyz + cb2[5].xyz, {indices[1]}, {weights[1]}, {skin[1] if skin else "cb2[7]"}, {"saturate(" + color[1] + ".w)" if row["reference_pose"] else "1.f"}, motion_instance, motion_history);\n  return;', 1)
        destination = folder / (row['hash'] + '.vs_5_0.hlsl')
        if destination.exists():
            assert destination.read_text(encoding='utf-8') == source, f'Preserve modified source: {destination}'
        else:
            destination.write_text(source, encoding='utf-8')
        if args.test_originals:
            destination = args.test_originals / (row['hash'] + '.cso')
            original = args.originals / destination.name
            if destination.exists():
                assert destination.read_bytes() == original.read_bytes()
            else:
                shutil.copyfile(original, destination)
        generated.append(f'    ObjectShader{{{row["hash"]}, __{row["hash"]}, {row["group"]}, {str(row["reference_pose"]).lower()}, false, false, {str(row["forward"]).lower()}, {str(not row["instanced"]).lower()}}},')
    if args.generate_vertices:
        (folder / args.vertex_list).write_text('// Offline audited position/interface matches. See tools/audit_motion_families.py.\n' + '\n'.join(generated) + '\n', encoding='utf-8')
    pixel_references, pixel_rows, generated_pixels = collections.defaultdict(list), [], []
    pixel_registry = registry_text.split('OBJECT_PIXEL_SHADERS')[1]
    for shader_hash, group in re.findall(r'ObjectShader\{(0x[0-9A-F]{8}), __0x[0-9A-F]{8}, (\d+)', pixel_registry):
        if shader_hash in inventory:
            native = inventory[shader_hash]
            if len(native['outputs']) == 3:
                pixel_references[tuple(tuple(item[:6]) for item in native['inputs'])].append((shader_hash, int(group)))
    for path in sorted(args.originals.glob('0x*.hlsl')):
        native = inventory[path.stem]
        if native['stage'] != 0 or len(native['outputs']) != 3:
            continue
        references = pixel_references.get(tuple(tuple(item[:6]) for item in native['inputs']), [])
        groups = set(item[1] for item in references)
        row = dict(hash=path.stem, references=[item[0] for item in references])
        pixel_rows.append(row)
        if len(groups) != 1:
            row['excluded'] = 'No unambiguous audited native pixel interface'
            continue
        row['group'] = groups.pop()
        row['registered'] = path.stem in pixel_registry
        if row['registered'] or not args.generate_pixels:
            continue
        source = path.read_text(encoding='utf-8')
        signature = source[source.index('void main('):].split('{', 1)[0]
        declarations = tuple(re.findall(r'  (float[1-4]?|uint[1-4]?) v\d+ : (\w+)', signature))
        reference_declarations = []
        for shader_hash, _ in references:
            reference = (args.originals / (shader_hash + '.hlsl')).read_text(encoding='utf-8')
            reference = reference[reference.index('void main('):].split('{', 1)[0]
            reference_declarations.append(tuple(re.findall(r'  (float[1-4]?|uint[1-4]?) v\d+ : (\w+)', reference)))
        if declarations not in reference_declarations or source.count('  return;') != 1:
            row['excluded'] = 'Native declaration/exit shape requires manual review'
            continue
        position = re.search(r'float4 (v\d+) : SV_POSITION0', signature, re.IGNORECASE)
        arguments = '' if position else '  float4 motion_position : SV_Position,\n'
        arguments += '  float4 previous_clip : TEXCOORD10,\n  nointerpolation float motion_history : TEXCOORD11,\n'
        front = re.search(r'  uint v\d+ : SV_IsFrontFace0,', signature)
        anchor = front[0] if front else '  out float4 o0 : SV_Target0,'
        assert anchor in source and '  out float4 o2 : SV_Target2)' in source
        source = source.replace('void main(', '#include "./object_pixel.hlsli"\n\nvoid main(', 1)
        source = source.replace(anchor, arguments + anchor, 1)
        source = source.replace('  out float4 o2 : SV_Target2)', '  out float4 o2 : SV_Target2,\n  out float2 object_motion : SV_Target3,\n  out float object_depth : SV_Target4)', 1)
        source = source.replace('  return;', f'  WriteObjectMotion({position[1] if position else "motion_position"}, previous_clip, motion_history, object_motion, object_depth);\n  return;', 1)
        destination = folder / (path.stem + '.ps_5_0.hlsl')
        if destination.exists():
            assert destination.read_text(encoding='utf-8') == source, f'Preserve modified source: {destination}'
        else:
            destination.write_text(source, encoding='utf-8')
        if args.test_originals:
            destination = args.test_originals / (path.stem + '.cso')
            if destination.exists():
                assert destination.read_bytes() == path.with_suffix('.cso').read_bytes()
            else:
                shutil.copyfile(path.with_suffix('.cso'), destination)
        generated_pixels.append(f'    ObjectShader{{{path.stem}, __{path.stem}, {row["group"]}}},')
    if args.generate_pixels:
        (folder / 'object_material_families.inc').write_text('// Offline audited native pixel interfaces. See tools/audit_motion_families.py.\n' + '\n'.join(generated_pixels) + '\n', encoding='utf-8')
    (args.originals / 'family-report.json').write_text(json.dumps(rows, indent=2), encoding='utf-8')
    (args.originals / 'material-family-report.json').write_text(json.dumps(pixel_rows, indent=2), encoding='utf-8')
    print(f'{len(rows)} shaders; {len(eligible)} eligible; {len(generated)} generated')
    print(f'{len(pixel_rows)} material shaders; {len(generated_pixels)} generated')
    print(collections.Counter(row.get('excluded', 'eligible') for row in rows))


if __name__ == '__main__':
    main()
