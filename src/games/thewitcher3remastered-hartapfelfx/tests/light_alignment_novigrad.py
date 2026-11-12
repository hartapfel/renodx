"""Regress unreachable shrine bounce lights and the fire-source spawn override."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import json
import math
from pathlib import Path
import re
import sys
import tempfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1] / 'lighting/alignment'
sys.path.insert(0, str(ROOT))
from build import Document, get, origin, write_runtime

fixtures = json.loads((ROOT / 'fixtures.json').read_text())
limits = json.loads((ROOT / 'fixture_limits.json').read_text())
stems = ('shrine_of_ethernal_fire_altar_spot', 'shrine_of_ethernal_fire_altar_small_spot_bounce',
         'shrine_of_ethernal_fire_altar_wide_bounce')
assert set(limits) == set(stems)
assert all(limits[stem] == 12. for stem in stems)
runtime = (ROOT / 'runtime.ws').read_text()
assert '@wrapMethod(W3FireSource)' in runtime
assert runtime.count('    wrappedMethod(spawnData);\n    HFAlignLocalLights();') == 2
assert 'best = maxDistance;' in runtime and 'best < maxDistance)' in runtime
assert 'HFAlignEmitterMap(this, slots, offsets, maxDistance)' in runtime
assert 'worldToLocal = MatrixGetInverted' not in runtime
assert runtime.count('VecTransformDir(localToWorld, Vector(') == 3
assert 'AbsF(determinant) < 0.000001' in runtime
# Evaluate the expressions shipped in the script, then round-trip independent
# expected points through rotated, scaled, mirrored and sheared native bases.
def dot(a, b):
    return sum(x * y for x, y in zip(a, b))

def cross(a, b):
    return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])

expressions = dict(re.findall(r'(inverse[XYZ]|determinant) = ([^;]+);', runtime))
for basis in (
    ((1.,0.,0.), (0.,1.,0.), (0.,0.,1.)),
    ((.836929798,0.,0.), (0.,.836929798,0.), (0.,0.,.836929798)),
    ((0.,2.,0.), (-.5,0.,0.), (0.,0.,3.)),
    ((-2.,0.,0.), (.2,.7,0.), (.3,.1,1.2)),
):
    scope = dict(zip(('axisX','axisY','axisZ'),basis), VecCross=cross, VecDot=dot)
    for name in ('inverseX','inverseY','inverseZ','determinant'):
        scope[name] = eval(expressions[name], {'__builtins__':{}}, scope)
    for local in ((0.,0.,1.5297431945800781), (.2,-.1,.1), (-.25,.4,2.)):
        delta = tuple(sum(basis[j][i]*local[j] for j in range(3)) for i in range(3))
        recovered = tuple(dot(delta,scope[name])/scope['determinant'] for name in ('inverseX','inverseY','inverseZ'))
        assert math.dist(local,recovered) < 1e-12
# Captured 83.7%-scale shrine: rigid inverse sends the light ~38 cm too low.
scale, flame = .8369297981262207, 1.5297431945800781
assert abs((29.86171531677246-28.968687057495117)-scale**3*flame) < .005
assert scale*flame-scale**3*flame > .38
with tempfile.TemporaryDirectory(dir=ROOT.parents[4] / 'tmp') as directory:
    write_runtime(Path(directory), fixtures)
    mapping = (Path(directory) / 'scripts/local/hf_light_alignment_map.ws').read_text()
    assert '    maxDistance = 4.0;' in mapping
    branches = dict(re.findall(r'if \(HFAlignTemplateMatches\(text, "([a-z0-9_]+)"\)\)\s*\{(.*?)return true;', mapping, re.S))
    assert set(branches) == set(fixtures)
    assert {stem for stem, body in branches.items() if 'maxDistance =' in body} == set(stems)
    for stem in stems:
        assert 'maxDistance = 12.0;' in branches[stem]
        assert fixtures[stem] == [['fire', [0., 0., 0.]]]
    assert 'city_bouncelight_fire' not in branches, 'standalone fill has no flame association'
    # The new argument must reach every shard; otherwise a later shard can
    # silently retain the old limit for a correctly matched shrine identity.
    declarations = re.findall(r'function HFAlignEmitterMap\d+\([^\n]+', mapping)
    calls = re.findall(r'if \(HFAlignEmitterMap\d+\([^\n]+', mapping)
    assert len(declarations) == len(calls) > 1
    assert all('out maxDistance : float' in d for d in declarations)
    assert all('offsets, maxDistance)' in c for c in calls)
if len(sys.argv) > 1:
    source = Path(sys.argv[1])
    for stem in stems:
        raw = (source / 'environment/decorations/light_sources/complex' / (stem + '.w2ent')).read_bytes()
        document = Document(raw)
        template = next(c['props'] for c in document.chunks if c['cls'] == 'CEntityTemplate')
        flame = origin(get(next(s for s in get(template, 'slots') if get(s, 'name') == 'fire'), 'transform'))
        distances = [math.dist(origin(get(c['props'], 'transform')), flame)
                     for d in document.documents() for c in d.chunks if c['cls'] == 'CPointLightComponent']
        assert distances and max(distances) > 4. and max(distances) < limits[stem]
        print(stem, 'stock point-to-flame distance', round(max(distances), 6), 'm')
    for path in source.rglob('city_bouncelight_fire*.w2ent'):
        assert not any(c['cls'] == 'CFXTrackItemParticles' for d in Document(path.read_bytes()).documents() for c in d.chunks)
print('PASS: captured scale failure, shipped affine inverse round trips, restricted shrine reach, fire-source hook and generated argument propagation verified.')
