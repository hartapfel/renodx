"""Verify the hanging-lamp emission origin against the exact native particle input."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import hashlib
import json
from pathlib import Path
import struct
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1] / 'lighting/alignment'
sys.path.insert(0, str(ROOT))
from build import particle_origin, Unsupported

raw = Path(sys.argv[1]).read_bytes()
profile = json.loads((ROOT / 'particle_origins.json').read_text())[r'fx\light_sources\torches\torch_fx5.w2p']
assert hashlib.sha256(raw).hexdigest() == profile['sha256'], 'particle input differs from the verified resource'
assert particle_origin(raw) == tuple(profile['position'])
# Regress the actual failure: a -35 cm spawner origin is not the visible emission origin.
catalog = json.loads((ROOT / 'fixtures.json').read_text())
assert catalog['hanging_lamp_complex'] == [['light_point', [profile['position'][0], 0., -0.3499999940395355 + profile['position'][2]]]]
# A varying position range cannot safely be collapsed to this constant origin.
pattern = struct.pack('<3f', *profile['position']) * 2
offset = raw.find(pattern)
assert offset >= 0 and raw.find(pattern, offset + 1) == -1
varying = bytearray(raw)
struct.pack_into('<f', varying, offset + 12 + 8, .2)
try:
    particle_origin(varying)
except Unsupported:
    pass
else:
    raise AssertionError('varying emitter position accepted as constant')
print('PASS: verified particle hash, constant emission origin, hanging-lamp offset composition and rejection of varying emission positions.')

if len(sys.argv) > 2:
    raw = Path(sys.argv[2]).read_bytes()
    profile = json.loads((ROOT / 'particle_origins.json').read_text())[r'fx\light_sources\torches\torch_fx1.w2p']
    assert hashlib.sha256(raw).hexdigest() == profile['sha256']
    assert particle_origin(raw, profile['emitter']) == tuple(profile['position'])
    for selection in (None, 'missing_flame'):
        try:
            particle_origin(raw, selection)
        except Unsupported:
            pass
        else:
            raise AssertionError('ambiguous/missing emitter selection accepted')
    pattern = struct.pack('<3f', *profile['position']) * 2
    offset = raw.find(pattern)
    assert offset >= 0 and raw.find(pattern, offset + 1) == -1
    varying = bytearray(raw)
    struct.pack_into('<f', varying, offset + 12 + 8, .2)
    try:
        particle_origin(varying, profile['emitter'])
    except Unsupported:
        pass
    else:
        raise AssertionError('varying named flame accepted as constant')
    assert catalog['torch_hand_long_complex'] == [['fx_fire_point', [
        .2199999988079071 + profile['position'][0], -.009999999776482582, profile['position'][2]]]]
    print('PASS: exact torch particle hash, named flame selection among six emitters, offset composition and ambiguous/varying emitter rejection.')
