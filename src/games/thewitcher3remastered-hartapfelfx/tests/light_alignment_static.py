"""Verify the exact native world-light fix, including bundle coverage and byte preservation."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from light_alignment import alignment, verify
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'lighting/alignment'))
from static_lights import ASSET, LOWER, UPPER, Unsupported, patch_layer, sector_points

source, candidate = map(Path, sys.argv[1:3])
if len(sys.argv) > 3:
    sys.path.insert(0, str(Path(sys.argv[3]).resolve()))
before = source.read_bytes()
after, report = patch_layer(before)
raw = candidate.joinpath('raw', *ASSET.split('\\')).read_bytes()
assert raw == after and len(before) == len(after)
original, modified = alignment.Document(before), alignment.Document(after)
allowed = set()
for document in modified.documents():
    verify(document)
    allowed.update(range(document.base + 32, document.base + 36))
    allowed.update(range(document.base + 96, document.base + 100))
    for chunk in document.chunks:
        allowed.update(range(chunk['entry'] + 20, chunk['entry'] + 24))
for offset in report['positions']:
    allowed.update(range(offset, offset + 12))
differences = {i for i, (a, b) in enumerate(zip(before, after)) if a != b}
assert differences and differences <= allowed, 'non-position/non-checksum bytes changed'
old, new = sector_points(before), sector_points(after)
assert len(old) == len(new) == 3
assert all(a['light'] == b['light'] for a,b in zip(old,new)), 'photometric fields changed'
assert [p['position'] for p in old].count(LOWER) == 1
assert [p['position'] for p in new].count(UPPER) == 2
packed = dict(alignment.bundle_items(candidate / 'content/blob0.bundle'))
assert set(packed) == {ASSET} and alignment.extract(packed[ASSET]) == after
assert (candidate / 'content/metadata.store').stat().st_size > 0
try:
    patch_layer(before[:-1] + bytes([before[-1] ^ 1]))
except Unsupported:
    pass
else:
    raise AssertionError('unreviewed source layer accepted')
print(f'PASS: one world light, both position copies, {len(differences)} changed bytes; all other fields preserved, checksums valid, bundle round trip and source-version guard passed.')
