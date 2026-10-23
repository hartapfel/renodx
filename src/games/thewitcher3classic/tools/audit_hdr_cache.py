"""Offline HDR candidate inventory from audit_motion_cache.py's DXBC manifest.

Disassemble every pixel/compute program, preserve candidates in scratch, and
report known curve/LUT/grade families for semantic review. Pattern matches are
not sufficient for automatic shader replacement. No game cache is modified.
"""
import argparse
import ctypes as c
import json
from pathlib import Path
import re
import struct
import zlib
from audit_motion_cache import container, signature


def disassemble(data):
    compiler = c.WinDLL('d3dcompiler_47.dll')
    compiler.D3DDisassemble.argtypes = [c.c_void_p, c.c_size_t, c.c_uint, c.c_char_p, c.POINTER(c.c_void_p)]
    compiler.D3DDisassemble.restype = c.c_long
    blob = c.c_void_p()
    if compiler.D3DDisassemble(data, len(data), 0, None, c.byref(blob)) < 0:
        raise ValueError('D3DDisassemble failed')
    table = c.cast(blob, c.POINTER(c.POINTER(c.c_void_p))).contents
    try:
        address = c.WINFUNCTYPE(c.c_void_p, c.c_void_p)(table[3])(blob)
        length = c.WINFUNCTYPE(c.c_size_t, c.c_void_p)(table[4])(blob)
        return c.string_at(address, length).decode('utf-8').rstrip('\0')
    finally:
        c.WINFUNCTYPE(c.c_uint, c.c_void_p)(table[2])(blob)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inventory', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--dumps', type=Path, nargs='*', default=[])
    args = parser.parse_args()
    inventory = json.loads(args.inventory.read_text(encoding='utf-8'))
    shaders = {s['hash']: s for s in inventory['shaders']}
    dumped = set()
    for folder in args.dumps:
        for path in folder.glob('*.cso'):
            data = path.read_bytes()
            parts = container(data)
            program = parts.get(b'SHEX', parts.get(b'SHDR', b''))
            if not program:
                continue
            version = struct.unpack_from('<I', program)[0]
            shader_hash = f'0x{zlib.crc32(data):08X}'
            dumped.add(shader_hash)
            if shader_hash not in shaders:
                shaders[shader_hash] = dict(hash=shader_hash, stage=version >> 16,
                                           inputs=signature(parts, b'ISGN'), outputs=signature(parts, b'OSGN'),
                                           sources=[[str(path), 0]])
    args.output.mkdir(parents=True, exist_ok=True)
    rows = []
    cached_path, cache = None, None
    for shader in sorted(shaders.values(), key=lambda s: s['sources'][0]):
        if shader['stage'] not in (0, 5):
            continue
        path, offset = shader['sources'][0]
        if path != cached_path:
            cache, cached_path = Path(path).read_bytes(), path
        size = struct.unpack_from('<I', cache, offset + 24)[0]
        data = cache[offset:offset + size]
        assert f'0x{zlib.crc32(data):08X}' == shader['hash']
        source = disassemble(data)
        # These identify candidate families, not whether each saturate is color.
        grade = all(token in source for token in ('cb3[14]', 'cb3[15]', '0.454545', '2.200000'))
        curve = '11.200000' in source and 'div ' in source and 'cb3[' in source
        lut = all(token in source for token in ('63.750000', '0.015625', '0.454545'))
        fullscreen = (len(shader['outputs']) == 1
                      and all(s[0] in ('SV_POSITION', 'TEXCOORD') for s in shader['inputs']))
        color_clamp = bool(re.search(r'\b(?:mad|mul|mov|add)_sat o0\.(?:xyz|xyzw)', source))
        row = dict(hash=shader['hash'], stage=shader['stage'], grade=grade, curve=curve,
                   lut=lut, fullscreen=fullscreen, output_saturate=color_clamp,
                   bytes=size, dumped=shader['hash'] in dumped, sources=shader['sources'])
        rows.append(row)
        (args.output / (shader['hash'] + '.asm')).write_text(source, encoding='utf-8')
        if grade or curve or lut or fullscreen:
            (args.output / (shader['hash'] + '.cso')).write_bytes(data)
    report = dict(cache_counts=inventory['cache_counts'], dumped=len(dumped), scanned=len(rows), shaders=rows)
    (args.output / 'hdr-inventory.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps({'scanned': len(rows), 'families': [r for r in rows if r['grade'] or r['curve'] or r['lut']]}, indent=2))


if __name__ == '__main__':
    main()
