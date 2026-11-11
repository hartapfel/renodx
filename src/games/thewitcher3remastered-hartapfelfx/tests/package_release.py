"""Verify the combined game-root archive and reject invalid packaging inputs."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import hashlib
import importlib.util
import json
from pathlib import Path, PurePosixPath
import sys
import tempfile
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('hartapfelfx_release', ROOT / 'package-release.py')
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


def verify(path):
    with zipfile.ZipFile(path) as archive:
        assert archive.testzip() is None
        names = archive.namelist()
        assert len(names) == len(set(names))
        manifest = json.loads(archive.read(release.MANIFEST))
        assert set(manifest['files']) == set(names) - {release.MANIFEST}
        required = {release.MANIFEST, 'HartapfelFX-README.txt',
                    release.BIN + 'renodx-thewitcher3remastered-hartapfelfx.addon64',
                    release.MOD + 'manifest.json', release.MOD + 'content/blob0.bundle',
                    release.MOD + 'content/metadata.store',
                    release.MOD + 'content/scripts/local/hf_light_alignment.ws',
                    release.MOD + 'content/scripts/local/hf_light_alignment_map.ws'}
        assert required <= set(names)
        assert release.BIN + 'dxgi.dll' not in names and manifest['includes_reshade'] is False
        for license in ('RenoDX', 'FAST', 'Detours', 'JSON', 'Frozen', 'GTL'):
            assert archive.read(release.BIN + 'renodx-hartapfelfx-licenses/' + license + '-LICENSE.txt')
        for name in names:
            member = PurePosixPath(name)
            assert not member.is_absolute() and '..' not in member.parts and '\\' not in name and ':' not in name
            assert not name.lower().endswith(('.ini', '.log', '.pdb')) and 'devkit' not in name.lower()
            assert member.parts[0] in ('bin', 'Mods', release.MANIFEST, 'HartapfelFX-README.txt')
            if name in manifest['files']:
                assert hashlib.sha256(archive.read(name)).hexdigest() == manifest['files'][name]
        fixtures = json.loads((ROOT / 'lighting/alignment/fixtures.json').read_text())
        mapping = archive.read(release.MOD + 'content/scripts/local/hf_light_alignment_map.ws').decode()
        assert manifest['fixture_count'] == len(fixtures)
        assert mapping.count('if (HFAlignTemplateMatches(text, "') == len(fixtures)
        assert archive.read(release.MOD + 'content/scripts/local/hf_light_alignment.ws') == (ROOT / 'lighting/alignment/runtime.ws').read_bytes()
        assert archive.read(release.MOD + 'README.txt') == (ROOT / 'lighting/alignment/INSTALL.txt').read_bytes()
        with tempfile.TemporaryDirectory(dir=path.parent) as directory:
            archive.extractall(directory)
            game = Path(directory)
            assert (game / release.BIN / 'renodx-thewitcher3remastered-hartapfelfx.addon64').is_file()
            assert [p.name for p in (game / 'Mods').iterdir()] == [release.alignment.MOD]
    expected = path.with_suffix('.zip.sha256').read_text().split()[0]
    assert hashlib.sha256(path.read_bytes()).hexdigest() == expected
    print('PASS complete extract-to-game-root layout, payload hashes, licenses, current alignment scripts/map and no personal profiles or DevKit')


if __name__ == '__main__':
    package = Path(sys.argv[1]).resolve()
    verify(package)
    if len(sys.argv) > 2:
        seed = Path(sys.argv[2]).resolve()
        addon = release.REPO / 'build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64'
        with tempfile.TemporaryDirectory(dir=package.parent) as directory:
            work = Path(directory)
            # Exercise the public assembly path with the actual Release addon.
            only = release.package(addon, seed, work, 'test')
            verify(only)
            bad_addon = work / 'bad.addon64'
            bad_addon.write_bytes(b'not a PE DLL')
            try:
                release.package(bad_addon, seed, work, 'bad-addon')
            except ValueError:
                pass
            else:
                raise AssertionError('Invalid addon was accepted')
            assert not list(work.glob('*bad-addon*.zip'))
            with zipfile.ZipFile(seed) as archive:
                source = {name: archive.read(name) for name in archive.namelist()}
            # Even a self-consistent modified manifest must not admit an
            # unreviewed cooked world patch.
            bundle = release.MOD + 'content/blob0.bundle'
            source[bundle] = source[bundle][:-1] + bytes([source[bundle][-1] ^ 1])
            manifest = json.loads(source[release.MOD + 'manifest.json'])
            manifest['files'][bundle] = hashlib.sha256(source[bundle]).hexdigest()
            source[release.MOD + 'manifest.json'] = json.dumps(manifest).encode()
            bad_seed = work / 'bad-alignment.zip'
            with zipfile.ZipFile(bad_seed, 'w') as archive:
                for name, data in source.items():
                    archive.writestr(name, data)
            try:
                release.package(addon, bad_seed, work, 'bad-alignment')
            except ValueError:
                pass
            else:
                raise AssertionError('Modified native alignment bundle was accepted')
            assert not (work / 'HartapfelFX-Witcher3-Remastered-bad-alignment.zip').exists()
        print('PASS addon-only package and invalid addon / altered native alignment input rejection')
