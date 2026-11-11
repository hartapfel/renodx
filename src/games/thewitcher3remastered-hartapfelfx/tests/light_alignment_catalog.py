"""Audit an automatic catalog against its baseline and exact installed source bytes."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import hashlib
import json
from pathlib import Path, PureWindowsPath
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'lighting/alignment'))
from build import bundle_items, extract


def main(candidate, baseline):
    report = json.loads((candidate / 'report.json').read_text(encoding='utf-8'))
    fixtures = json.loads((candidate / 'fixtures.json').read_text(encoding='utf-8'))
    previous = json.loads(baseline.read_text(encoding='utf-8'))
    assert hashlib.sha256(baseline.read_bytes()).hexdigest() == report['baseline_sha256']
    assert all(fixtures.get(stem) == targets for stem, targets in previous.items()), 'baseline binding changed'
    assert len(fixtures) == report['fixture_count']
    assert not report['bundle_errors'], 'incomplete bundle scan'
    added = set(fixtures) - set(previous)
    assert added.isdisjoint(report['ambiguous_stems']), 'unresolved template-stem collision published'
    assert added.isdisjoint(report['baseline_conflicts'])
    indexes, verified = {}, set()
    for row in report['templates']:
        stem = PureWindowsPath(row['asset']).stem.lower()
        if stem not in added:
            continue
        assert row['status'] == 'verified', 'an unresolved same-stem fixture entered the catalog'
        assert any(part in ('light_sources', 'lightsources') for part in PureWindowsPath(row['asset']).parts)
        expected = sorted({(binding['slot'], tuple(binding['offset'])) for binding in row['runtime_emitters']})
        assert [(slot, tuple(point)) for slot, point in fixtures[stem]] == expected
        assert any(source['group'] == 'stock' for source in row['sources'])
        for source in row['sources']:
            bundle = Path(source['bundle'])
            if bundle not in indexes:
                indexes[bundle] = dict(bundle_items(bundle))
            assert hashlib.sha256(extract(indexes[bundle][row['asset']])).hexdigest() == source['sha256'], 'source changed since scan'
        verified.add(stem)
    assert verified == added, 'addition has no verified source association'
    assert 'torch_hand_long_complex' in fixtures, 'current fence torch lost'
    assert 'pc_igni_w3re' not in added and 'q703_mandragora_rocking_boat' not in added, 'nonfixture gameplay entity admitted'
    print(f'PASS: {len(previous)} previous identities preserved; {len(added)} additions backed by exact game/mod source hashes; '
          'scope, associations, ambiguity guards and current fence torch verified.')


if __name__ == '__main__':
    if len(sys.argv) > 3:
        sys.path.insert(0, str(Path(sys.argv[3]).resolve()))
    main(Path(sys.argv[1]), Path(sys.argv[2]))
