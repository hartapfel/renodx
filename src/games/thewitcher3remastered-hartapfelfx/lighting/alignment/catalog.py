"""Discover native-slot light fixtures across installed game bundles, without visiting scenes."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import argparse
import configparser
import hashlib
import json
from pathlib import Path, PureWindowsPath
import struct
import sys

sys.dont_write_bytecode = True
from build import Document, Unsupported, bundle_items, collect_runtime_fixtures, extract, flame_bindings, get, write_runtime


def inspect_fixture(raw):
    """Require an owned local light and an unambiguous stationary flame attachment."""
    document = Document(raw)
    template, = [c['props'] for c in document.chunks if c['cls'] == 'CEntityTemplate']
    slots = get(template, 'slots', [])
    names = [get(slot, 'name') for slot in slots]
    if len(set(names)) != len(names):
        raise Unsupported('duplicate native slot identity')
    if any(get(slot, 'boneName') for slot in slots):
        raise Unsupported('animated bone attachment needs continuous tracking')
    if any('LightComponent' in get(a, 'childClass', '') for a in get(template, 'streamedAttachments', [])):
        raise Unsupported('separately attached light needs parent-aware tracking')
    if not any(c['cls'] in ('CPointLightComponent', 'CSpotLightComponent') for d in document.documents() for c in d.chunks):
        raise Unsupported('no owned point/spot component')
    bindings = flame_bindings(template, particle_origins=True)
    if any(binding['slot'] not in names for binding in bindings):
        raise Unsupported('flame attachment has no explicit native entity slot')
    return bindings


def scan(args):
    if args.lz4_path:
        sys.path.insert(0, str(args.lz4_path.resolve()))
    if args.output.exists():
        raise ValueError('use a new output directory to preserve previous evidence')
    if not (args.game / 'content/content0/bundles').is_dir():
        raise ValueError('game root has no content/content0/bundles directory')
    settings = configparser.ConfigParser()
    if args.mods_settings:
        settings.read(args.mods_settings, encoding='utf-8-sig')
    mods = sorted([p for p in (args.game / 'Mods').glob('mod*')
                   if p.is_dir() and not p.name.lower().startswith('mod0000_hartapfellightalignment')
                   and settings.getint(p.name, 'Enabled', fallback=1)],
                  key=lambda p: (settings.getint(p.name, 'Priority', fallback=1000000), p.name.lower()))
    sources = [('stock', path) for folder in ('content', 'dlc')
               for path in sorted((args.game / folder).rglob('*.bundle'))]
    sources += [(mod.name, path) for mod in mods for path in sorted((mod / 'content').glob('*.bundle'))]
    index, failures = {}, []
    for group, bundle in sources:
        try:
            for name, item in bundle_items(bundle):
                if name.endswith('.w2ent'):
                    index.setdefault(name, []).append((group, item))
        except Unsupported as error:
            failures.append(dict(bundle=str(bundle), reason=str(error)))
    if not index:
        raise ValueError('no entity templates were indexed; check the game root and bundle diagnostics')
    print(f'Indexed {len(index)} entity paths from {len(sources)} bundles.', flush=True)
    report, candidates = [], []
    mod_rank = {mod.name: i for i, mod in enumerate(mods)}
    for number, (asset, copies) in enumerate(sorted(index.items())):
        groups = {group for group, _ in copies}
        active = min((group for group in groups if group != 'stock'), key=mod_rank.get, default='stock')
        relevant = [(group, item) for group, item in copies if group in ('stock', active)]
        variants, issues, hashes = [], [], []
        interesting = False
        for group, item in relevant:
            # Bound individual decompression; a skipped asset never generates a mapping.
            if item['size'] > 16 * 1024 * 1024:
                issues.append('template exceeds 16 MiB inspection bound')
                continue
            try:
                raw = extract(item)
                digest = hashlib.sha256(raw).hexdigest()
                hashes.append(dict(group=group, bundle=str(item['bundle']), sha256=digest))
                if not (b'CFXTrackItemParticles' in raw and
                        (b'CPointLightComponent' in raw or b'CSpotLightComponent' in raw)):
                    issues.append('no serialized owned light/flame pair')
                    continue
                interesting = True
                variants.append(dict(asset=asset, runtime_emitters=inspect_fixture(raw)))
            except (Unsupported, ValueError, IndexError, UnicodeError, struct.error) as error:
                issues.append(str(error))
        if not interesting:
            continue
        entry = dict(asset=asset, active_source=active, sources=hashes)
        if not any(part in ('light_sources', 'lightsources') for part in PureWindowsPath(asset).parts):
            entry.update(status='skipped', reasons=['gameplay/cinematic entity outside light-fixture namespaces requires review'])
        elif issues:
            entry.update(status='skipped', reasons=sorted(set(issues)))
        elif 'stock' not in groups:
            entry.update(status='skipped', reasons=['custom-mod-only fixture; public catalog needs stock evidence'])
        elif len(collect_runtime_fixtures(variants)) != 1:
            entry.update(status='skipped', reasons=['stock/active-mod flame associations disagree'])
        else:
            entry.update(status='verified', runtime_emitters=variants[0]['runtime_emitters'])
            candidates.append(entry)
        report.append(entry)
        if number % 2000 == 0:
            print(f'Inspected {number + 1}/{len(index)} entity paths.', flush=True)
    # The runtime key is a template stem, so unresolved same-stem assets must
    # also veto discovery; otherwise their paths cannot be distinguished in-game.
    verified_paths = {entry['asset'] for entry in candidates}
    blocked = {PureWindowsPath(asset).stem.lower() for asset in index if asset not in verified_paths}
    discovered = collect_runtime_fixtures(candidates)
    ambiguities = {stem: sorted(asset for asset in index if PureWindowsPath(asset).stem.lower() == stem)
                   for stem in sorted(discovered.keys() & blocked)}
    additions = {stem: targets for stem, targets in discovered.items() if stem not in blocked}
    fixtures = json.loads(args.baseline.read_text(encoding='utf-8'))
    conflicts = []
    for stem, targets in additions.items():
        if stem in fixtures and json.dumps(fixtures[stem], sort_keys=True) != json.dumps(targets, sort_keys=True):
            conflicts.append(stem)
            continue
        fixtures.setdefault(stem, targets)
    args.output.mkdir(parents=True)
    (args.output / 'fixtures.json').write_text(json.dumps(fixtures, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    (args.output / 'report.json').write_text(json.dumps(dict(
        indexed_entity_paths=len(index), bundle_count=len(sources), baseline_sha256=hashlib.sha256(args.baseline.read_bytes()).hexdigest(),
        baseline_count=len(json.loads(args.baseline.read_text(encoding='utf-8'))), fixture_count=len(fixtures),
        baseline_conflicts=sorted(conflicts), ambiguous_stems=ambiguities,
        bundle_errors=failures, templates=report), indent=2) + '\n', encoding='utf-8')
    write_runtime(args.output / 'content', fixtures)
    print(f'Verified {len(candidates)} template paths; {len(fixtures)} fixture identities including preserved baseline; '
          f'{len(conflicts)} baseline conflicts retained for review; {len(failures)} bundle errors.', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game', type=Path, required=True)
    parser.add_argument('--mods-settings', type=Path, help='Mod enable/priority profile; all installed mods are considered enabled if omitted')
    parser.add_argument('--baseline', type=Path, default=Path(__file__).with_name('fixtures.json'))
    parser.add_argument('--lz4-path', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    scan(parser.parse_args())
