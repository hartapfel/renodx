"""Validate generated content overrides against their exact installed inputs."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import collections
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import sys
import zlib

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('alignment', Path(__file__).parents[1] / 'lighting/alignment/build.py')
alignment = importlib.util.module_from_spec(spec)
spec.loader.exec_module(alignment)


def verify(document):
    data, base = document.data, document.base
    header = bytearray(data[base:base + 160])
    expected = struct.unpack_from('<I', header, 32)[0]
    struct.pack_into('<I', header, 32, 0xDEADBEEF)
    assert zlib.crc32(header) == expected, ('header checksum', base)
    for index, stride in ((0, 1), (1, 8), (2, 8), (3, 16), (4, 24)):
        offset, count, expected = document.tables[index]
        if count and expected:
            assert zlib.crc32(data[base + offset:base + offset + count * stride]) == expected, ('table checksum', base, index)
    for chunk in document.chunks:
        if chunk['crc']:
            assert zlib.crc32(data[chunk['start']:chunk['start'] + chunk['size']]) == chunk['crc'], ('chunk checksum', base)


def main(candidate, lz4_path):
    sys.path.insert(0, str(lz4_path.resolve()))
    report = json.loads((candidate / 'manifest.json').read_text())
    report = [r for r in report if r['status'] == 'aligned']
    content = candidate / 'mod0000_HartapfelLightAlignment/content'
    packed = {name: item for bundle in content.glob('*.bundle') for name, item in alignment.bundle_items(bundle)}
    assert set(packed) == {r['asset'] for r in report}, 'packaged asset coverage'
    assert (content / 'metadata.store').stat().st_size > 0
    changed_bytes, unique_lights = 0, 0
    for record in report:
        item = next(item for name, item in alignment.bundle_items(Path(record['source'])) if name == record['asset'])
        before = alignment.extract(item)
        assert hashlib.sha256(before).hexdigest() == record['source_sha256'], 'source changed during build'
        after = candidate.joinpath('raw', *Path(record['asset'].replace('\\', '/')).parts).read_bytes()
        assert len(before) == len(after), 'position-only edit resized an asset'
        assert hashlib.sha256(after).hexdigest() == record['sha256']
        assert alignment.extract(packed[record['asset']]) == after, 'bundle round trip'
        original, modified = alignment.Document(before), alignment.Document(after)
        allowed, by_component = set(), collections.defaultdict(set)
        original_docs = {d.base: d for d in original.documents()}
        modified_docs = {d.base: d for d in modified.documents()}
        assert original_docs.keys() == modified_docs.keys(), 'nested document layout changed'
        for base, doc in modified_docs.items():
            verify(doc)
            allowed.update(range(base + 32, base + 36))
            allowed.update(range(base + 96, base + 100))  # Export table checksum.
            for chunk in doc.chunks:
                allowed.update(range(chunk['entry'] + 20, chunk['entry'] + 24))
        for change in record['changes']:
            matches = [c for c in original_docs[change['document']].chunks
                       if c['cls'] in ('CPointLightComponent', 'CSpotLightComponent')
                       and alignment.get(c['props'], 'name') == change['component']]
            assert len(matches) == 1, 'ambiguous light component'
            prop = matches[0]['props']['transform']
            offset = prop['offset'] + 1
            assert tuple(change['before']) == struct.unpack_from('<3f', before, offset)
            assert tuple(change['after']) == struct.unpack_from('<3f', after, offset)
            allowed.update(range(offset, offset + 12))
            by_component[change['component']].add(tuple(change['after']))
        assert all(len(points) == 1 for points in by_component.values()), 'compiled and editable positions disagree'
        differences = {i for i, (a, b) in enumerate(zip(before, after)) if a != b}
        assert differences and differences <= allowed, 'non-position/non-checksum data changed'
        assert alignment.align(bytearray(after)) == [], 'correction is not idempotent'
        changed_bytes += len(differences)
        unique_lights += len(by_component)
    # Rotated parent offsets must not be silently evaluated with the wrong axis convention.
    try:
        alignment.translate((0., 0., 1.), dict(alignment.IDENTITY, pitch=90.))
    except alignment.Unsupported:
        pass
    else:
        raise AssertionError('unverified parent rotation was accepted')
    assert alignment.translate((0., 0., 0.), dict(alignment.IDENTITY, pitch=90., z=2.)) == (0., 0., 2.)
    print(f'PASS: {len(report)} effective templates, {unique_lights} light components, '
          f'{sum(len(r["changes"]) for r in report)} editable/compiled transforms, {changed_bytes} changed bytes; '
          'position-only differences, matching compiled copies, nested checksums, bundle round trips and idempotence.')


if __name__ == '__main__':
    main(Path(sys.argv[1]), Path(sys.argv[2]))
