#!/usr/bin/env python3
"""Offline DXBC family inventory. Never changes game caches or runtime shaders.

Run against Classic's *shader.cache files, with --output pointing to scratch.
Signature matches are candidates for semantic review, not proof of equivalent
skinning/deformation or of a main-scene pass. DXBC structure reference:
https://llvm.org/docs/DirectX/DXContainer.html
"""
import argparse
import collections
import json
from pathlib import Path
import re
import struct
import zlib


def container(data):
    if len(data) < 32 or data[:4] != b'DXBC':
        raise ValueError('Missing DXBC header')
    size, count = struct.unpack_from('<II', data, 24)
    if size != len(data) or count > 64 or 32 + count * 4 > size:
        raise ValueError('Invalid DXBC size/part table')
    parts = {}
    for offset in struct.unpack_from(f'<{count}I', data, 32):
        if offset < 32 + count * 4 or offset + 8 > size:
            raise ValueError('Invalid part offset')
        name, length = struct.unpack_from('<4sI', data, offset)
        if offset + 8 + length > size or name in parts:
            raise ValueError('Invalid or duplicate part')
        parts[name] = data[offset + 8:offset + 8 + length]
    return parts


def signature(parts, name):
    if name not in parts:
        return []
    data = parts[name]
    count, offset = struct.unpack_from('<II', data)
    if count > 128 or offset + count * 24 > len(data):
        raise ValueError('Invalid SM4/5 signature')
    result = []
    for index in range(count):
        semantic, number, system, component, register, mask, used = struct.unpack_from('<IIIIIBB', data, offset + index * 24)
        end = data.find(b'\0', semantic)
        if semantic >= len(data) or end < semantic:
            raise ValueError('Invalid semantic string')
        result.append([data[semantic:end].decode('ascii').upper(), number, system, component, register, mask, used])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('caches', type=Path, nargs='+')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--originals', type=Path, help='Cross-check archived native originals against cache bytecode')
    args = parser.parse_args()
    mod = Path(__file__).resolve().parents[1]
    registered = set(re.findall(r'ObjectShader\{(0x[0-9A-F]{8})', (mod / 'temporal/object_shaders.hpp').read_text()
                                + (mod / 'temporal/object_skin_families.inc').read_text()))
    shaders = {}
    cache_counts = {}
    paths = sorted({path for item in args.caches for path in (item.rglob('*shader.cache') if item.is_dir() else [item])})
    for path in paths:
        data = path.read_bytes()
        cursor = count = 0
        while (offset := data.find(b'DXBC', cursor)) >= 0:
            cursor = offset + 4
            if offset + 32 > len(data):
                continue
            size = struct.unpack_from('<I', data, offset + 24)[0]
            if size < 32 or offset + size > len(data):
                continue
            bytecode = data[offset:offset + size]
            try:
                parts = container(bytecode)
                program = parts.get(b'SHEX', parts.get(b'SHDR', b''))
                if len(program) < 8:
                    continue
                version = struct.unpack_from('<I', program)[0]
                inputs = signature(parts, b'ISGN')
                outputs = signature(parts, b'OSGN')
            except (ValueError, UnicodeError, struct.error):
                continue
            cursor = offset + size
            count += 1
            crc = f'0x{zlib.crc32(bytecode):08X}'
            if crc in shaders:
                if shaders[crc]['bytecode'] != bytecode:
                    raise ValueError(f'CRC collision: {crc}')
                shaders[crc]['sources'].append([str(path), offset])
                continue
            shaders[crc] = dict(hash=crc, stage=version >> 16, model=f'{(version >> 4) & 15}_{version & 15}',
                                inputs=inputs, outputs=outputs, registered=crc in registered,
                                sources=[[str(path), offset]], bytecode=bytecode)
        cache_counts[str(path)] = count
    verified = 0
    if args.originals:
        for path in args.originals.glob('0x*.cso'):
            if path.stem in shaders:
                if path.read_bytes() != shaders[path.stem]['bytecode']:
                    raise ValueError(f'DevKit/cache mismatch: {path.stem}')
                verified += 1
    # Preserve component type, register, mask and semantic; UsedMask may differ
    # between materials without altering the vertex-to-pixel interface layout.
    families = collections.defaultdict(list)
    for shader in shaders.values():
        if shader['stage'] == 1 and any(item[0] == 'BLENDINDICES' for item in shader['inputs']):
            key = tuple(tuple(item[:6]) for item in shader['outputs'])
            families[key].append(shader['hash'])
    args.output.mkdir(parents=True, exist_ok=True)
    manifest = dict(cache_counts=cache_counts, unique=len(shaders), archived_byte_identical=verified,
                    stage_counts=dict(collections.Counter(s['stage'] for s in shaders.values())),
                    skin_families=[dict(outputs=list(key), hashes=hashes) for key, hashes in families.items()])
    pixel_interfaces = {tuple(tuple(item[:6]) for item in shader['inputs']) for shader in shaders.values()
                        if shader['registered'] and shader['stage'] == 0 and len(shader['outputs']) == 3}
    for shader in shaders.values():
        bytecode = shader.pop('bytecode')
        # Native binary copies stay in scratch; never in shader/live folders.
        if ((shader['stage'] == 1 and any(item[0] == 'BLENDINDICES' for item in shader['inputs']))
                or (shader['stage'] == 0 and len(shader['outputs']) == 3
                    and tuple(tuple(item[:6]) for item in shader['inputs']) in pixel_interfaces)):
            (args.output / (shader['hash'] + '.cso')).write_bytes(bytecode)
    manifest['shaders'] = list(shaders.values())
    (args.output / 'inventory.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    print(json.dumps({key: value for key, value in manifest.items() if key not in ('shaders', 'skin_families')}, indent=2))
    print(f'Skinned vertex shaders: {sum(map(len, families.values()))}; output families: {len(families)}')


if __name__ == '__main__':
    main()
