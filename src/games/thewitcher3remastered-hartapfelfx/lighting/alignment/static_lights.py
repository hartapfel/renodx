"""Build the verified Remastered bathhouse world-light correction from game data."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import argparse
import hashlib
import json
from pathlib import Path, PureWindowsPath
import struct
import subprocess
import sys

sys.dont_write_bytecode = True
from build import Document, Unsupported, bundle_items, extract

ASSET = r'levels\novigrad\novigrad\bathhouse\lights.w2l'
SOURCE_SHA256 = '95ed8a730454e1ab873a5df01fc65c2988008648f7f2518f4a2098f3d7a3a7b8'
LOWER = (714.0089721679688, 2000.1859130859375, 15.738349914550781)
UPPER = (714.0089721679688, 2000.1859130859375, 17.345687866210938)


def sector_points(data):
    """Read version-8 cooked sector point records, preserving both position copies."""
    document = Document(data)
    points = []
    for chunk in document.chunks:
        if chunk['cls'] != 'CSectorData':
            continue
        end = chunk['start'] + chunk['size']
        _, cursor = document.properties(chunk['start'] + 1, end)

        def read(fmt):
            nonlocal cursor
            if cursor + struct.calcsize(fmt) > end:
                raise Unsupported('sector field exceeds chunk boundary')
            result = document.unpack(fmt, cursor)
            cursor += struct.calcsize(fmt)
            return result

        def count():
            first, = read('<B')
            value, more, shift = first & 63, first & 64, 6
            while more:
                byte, = read('<B')
                value |= (byte & 127) << shift
                more, shift = byte & 128, shift + 7
                if shift > 32:
                    raise Unsupported('invalid sector VLQ count')
            if first & 128 and value or value > 100000:
                raise Unsupported('invalid sector array size')
            return value

        version, = read('<B')
        size_start = cursor
        payload_size, = read('<I')
        if version != 8 or size_start + payload_size != end:
            raise Unsupported('unverified cooked sector framing')
        for _ in range(count()):
            read('<6fQ')  # Resource bounds and FNV-1a path hash.
        objects = []
        for _ in range(count()):
            offset = cursor
            objects.append((offset, read('<BBHQ3f')))
        block_size = count()
        if cursor + block_size != end:
            raise Unsupported('invalid sector block boundary')
        for index, (entry, row) in enumerate(objects):
            kind, flags, radius, offset, x, y, z = row
            next_offset = objects[index + 1][1][3] if index + 1 < len(objects) else block_size
            if offset > next_offset or next_offset > block_size or next_offset - offset < 56:
                raise Unsupported('invalid sector object boundary')
            if kind != 5:
                continue
            if next_offset - offset != 116:
                raise Unsupported('unverified Remastered point-light record')
            block = cursor + offset
            position = document.unpack('<3f', block + 36)
            if position != (x, y, z):
                raise Unsupported('point streaming position differs from render position')
            points.append(dict(index=index, position=position, table_position=entry + 12,
                               render_position=block + 36, light=document.unpack('<I3f', block + 56)))
    return points


def patch_layer(before):
    if hashlib.sha256(before).hexdigest() != SOURCE_SHA256:
        raise Unsupported('bathhouse layer differs from verified Remastered 5.0.16 input; review its lighting before rebuilding')
    points = sector_points(before)
    lower = [p for p in points if p['position'] == LOWER]
    upper = [p for p in points if p['position'] == UPPER]
    if len(lower) != 1 or len(upper) != 1 or lower[0]['light'][1:3] != (14., 10.) or upper[0]['light'][1:3] != (6., 40.):
        raise Unsupported('verified bowl light pair not present')
    after = bytearray(before)
    for field in ('table_position', 'render_position'):
        struct.pack_into('<3f', after, lower[0][field], *UPPER)
    Document(after).checksums()
    return bytes(after), dict(asset=ASSET, source_sha256=SOURCE_SHA256,
                             sha256=hashlib.sha256(after).hexdigest(), before=LOWER, after=UPPER,
                             positions=[lower[0][key] for key in ('table_position', 'render_position')])


def build(args):
    if args.lz4_path:
        sys.path.insert(0, str(args.lz4_path.resolve()))
    if args.source:
        before = args.source.read_bytes()
    else:
        matches = [extract(item) for bundle in ('world_novigrad_runtime.bundle', 'world_novigrad_startup.bundle')
                   for name, item in bundle_items(args.game / 'content/content0/bundles' / bundle) if name == ASSET]
        if not matches or any(data != matches[0] for data in matches):
            raise Unsupported('missing unique stock bathhouse layer')
        before = matches[0]
    after, report = patch_layer(before)
    args.output.mkdir(parents=True, exist_ok=False)
    raw = args.output / 'raw'
    target = raw.joinpath(*PureWindowsPath(ASSET).parts)
    target.parent.mkdir(parents=True)
    target.write_bytes(after)
    content = args.output / 'content'
    content.mkdir()
    subprocess.run([str(args.w3bundle.resolve()), 'build', '-dir=' + str(raw.resolve()),
                    '-outdir=' + str(content.resolve())], check=True)
    report['files'] = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in content.iterdir() if p.is_file()}
    (args.output / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(f'Corrected one static point light and its streaming position by {UPPER[2] - LOWER[2]:.6f} m; other light data preserved.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    inputs = parser.add_mutually_exclusive_group(required=True)
    inputs.add_argument('--source', type=Path, help='Exact unpacked stock bathhouse lights.w2l')
    inputs.add_argument('--game', type=Path, help='Remastered game root; read the verified stock layer')
    parser.add_argument('--lz4-path', type=Path, help='Optional directory containing the lz4 Python package')
    parser.add_argument('--output', type=Path, required=True, help='New output directory')
    parser.add_argument('--w3bundle', type=Path, required=True)
    build(parser.parse_args())
