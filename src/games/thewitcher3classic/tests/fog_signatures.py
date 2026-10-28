"""Compare compiled fog/water PS linkage with captured original DXBC.

Run from the repository root: python .../fog_signatures.py PATH_TO_DEVKIT_DUMP
This checks registers/components, not just semantic names. Extra output MRTs
are allowed; native output slots and input channel locations must stay intact.
"""
import struct
import sys
from pathlib import Path


def signature(path, tag):
    data = path.read_bytes()
    assert data[:4] == b"DXBC", path
    for i in range(struct.unpack_from("<I", data, 28)[0]):
        offset = struct.unpack_from("<I", data, 32 + 4 * i)[0]
        if data[offset:offset + 4] != tag:
            continue
        chunk = data[offset + 8:]
        result = {}
        for j in range(struct.unpack_from("<I", chunk)[0]):
            name, index, system, kind, register, masks = struct.unpack_from("<6I", chunk, 8 + j * 24)
            semantic = chunk[name:chunk.index(b"\0", name)].decode().upper()
            result[(semantic, index)] = (register, masks & 255, system, kind)
        return result
    raise ValueError(f"Missing {tag!r} in {path}")


root = Path("src/games/thewitcher3classic")
dump = Path(sys.argv[1])
paths = list((root / "volumetrics").glob("*.ps_5_0.hlsl"))
paths += [root / "blitzfx/0x2825099C.ps_5_0.hlsl"]
paths += [root / "lighting/0xFAB74FB3.ps_5_0.hlsl"]
checked = 0
for path in paths:
    original = dump / path.name.replace(".hlsl", ".cso")
    if not original.exists():
        raise FileNotFoundError(original)
    compiled = Path("build/thewitcher3classic.include/embed") / (path.name.split(".")[0] + ".cso")
    for tag in (b"ISGN", b"OSGN"):
        old, new = signature(original, tag), signature(compiled, tag)
        for key, (register, mask, system, kind) in old.items():
            assert key in new, (path.name, tag, "missing", key)
            r, m, s, k = new[key]
            assert (r, s, k) == (register, system, kind) and m & mask == mask, (path.name, tag, key, old[key], new[key])
    checked += 1
print(f"PASS {checked} compiled fog/water shaders preserve native input and output register/component linkage")
