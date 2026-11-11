"""Check the public ZIP as installed files, including hashes, layout and fixture coverage."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import hashlib
import json
from pathlib import Path, PurePosixPath
import sys
import tempfile
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1] / 'lighting/alignment'
sys.path.insert(0, str(ROOT))
import package_release as release


def main(archive):
    prefix = f'Mods/{release.MOD}/'
    required = {prefix + name for name in (
        'README.txt', 'LICENSE.txt', 'manifest.json', 'content/info.json',
        'content/blob0.bundle', 'content/metadata.store',
        'content/scripts/local/hf_light_alignment.ws', 'content/scripts/local/hf_light_alignment_map.ws')}
    with zipfile.ZipFile(archive) as packed:
        assert packed.testzip() is None, 'ZIP CRC failure'
        names = packed.namelist()
        assert len(names) == len(set(names)) and set(names) == required, 'unexpected or duplicate archive member'
        for name in names:
            path = PurePosixPath(name)
            assert not path.is_absolute() and '..' not in path.parts and '\\' not in name and ':' not in name
            assert b'C:\\Users\\' not in packed.read(name) and b'C:/Users/' not in packed.read(name), 'personal path leaked'
        manifest = json.loads(packed.read(prefix + 'manifest.json'))
        assert set(manifest['files']) == required - {prefix + 'manifest.json'}
        for name, digest in manifest['files'].items():
            assert hashlib.sha256(packed.read(name)).hexdigest() == digest
        info = json.loads(packed.read(prefix + 'content/info.json'))
        assert info['version'] == release.VERSION and info['useLooseScripts'] is True
        assert packed.read(prefix + 'content/scripts/local/hf_light_alignment.ws') == (ROOT / 'runtime.ws').read_bytes()
        catalog = json.loads((ROOT / 'fixtures.json').read_text(encoding='utf-8'))
        assert manifest['fixture_count'] == len(catalog)
        mapping = packed.read(prefix + 'content/scripts/local/hf_light_alignment_map.ws').decode('utf-8')
        assert mapping.count('if (HFAlignTemplateMatches(text, "') == len(catalog)
        for stem, targets in catalog.items():
            assert mapping.count(f'if (HFAlignTemplateMatches(text, "{stem}"))') == 1
            assert targets and len({(slot, tuple(point)) for slot, point in targets}) == len(targets)
        for stem in ('bathhouse_floor_brazier', 'bathhouse_floor_brazier_complex', 'braziers_floor_square', 'candle_med_a',
                     'torch_wall_wooden_small', 'torch_wall_wooden_small_bounce', 'torch_wall_wooden_small_non_interactive',
                     'torch_hand_long_complex', 'gen_torch_long_b', 'torch_wall_metal'):
            assert stem in catalog, 'known fixture lost: ' + stem
        # Simulate extracting into an empty game root; all engine files belong to one mod.
        with tempfile.TemporaryDirectory(dir=archive.resolve().parent) as directory:
            packed.extractall(directory)
            mods = list((Path(directory) / 'Mods').iterdir())
            assert len(mods) == 1 and mods[0].name == release.MOD
            assert len(list((mods[0] / 'content/scripts/local').glob('*.ws'))) == 2
            from build import bundle_items, extract
            from static_lights import ASSET
            assets = dict(bundle_items(mods[0] / 'content/blob0.bundle'))
            assert set(assets) == {ASSET}, 'unexpected cooked game/mod assets'
            assert hashlib.sha256(extract(assets[ASSET])).hexdigest() == manifest['world_light_patch']['sha256']
    expected = archive.with_suffix('.zip.sha256').read_text(encoding='ascii').split()[0]
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == expected, 'archive checksum failure'
    print(f'PASS: {len(required)} safe archive paths; installed layout, payload hashes, {len(catalog)} unique fixture mappings and unchanged runtime script.')


if __name__ == '__main__':
    if len(sys.argv) > 2:
        sys.path.insert(0, str(Path(sys.argv[2]).resolve()))
    main(Path(sys.argv[1]))
