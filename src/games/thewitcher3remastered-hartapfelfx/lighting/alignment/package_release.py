"""Create the standalone Light Alignment mod-manager ZIP (stdlib packager)."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import sys
import zipfile

sys.dont_write_bytecode = True
from build import write_runtime

VERSION = '1.1.3'
MOD = 'mod0000_HartapfelLightAlignment'
ROOT = Path(__file__).resolve().parent


def package(output, static_content):
    static_manifest = json.loads((static_content.parent / 'manifest.json').read_text(encoding='utf-8'))
    if set(static_manifest['files']) != {'blob0.bundle', 'metadata.store'}:
        raise ValueError('unexpected static light patch files')
    static_files = {name: (static_content / name).read_bytes() for name in static_manifest['files']}
    if any(hashlib.sha256(data).hexdigest() != static_manifest['files'][name] for name, data in static_files.items()):
        raise ValueError('static light patch hash mismatch')
    fixtures = json.loads((ROOT / 'fixtures.json').read_text(encoding='utf-8'))
    if not fixtures:
        raise ValueError('empty fixture catalog')
    for stem, targets in fixtures.items():
        if not re.fullmatch(r'[a-z0-9_]+', stem) or not targets:
            raise ValueError('invalid fixture identity')
        for slot, point in targets:
            if not re.fullmatch(r'[A-Za-z0-9_]+', slot) or len(point) != 3 or not all(math.isfinite(x) for x in point):
                raise ValueError('invalid flame slot or offset')
    output.mkdir(parents=True, exist_ok=False)
    stage = output / 'install'
    mod = stage / 'Mods' / MOD
    content = mod / 'content'
    write_runtime(content, fixtures)
    for name, data in static_files.items():
        (content / name).write_bytes(data)
    (content / 'info.json').write_text(json.dumps(dict(
        name='hartapfelfxlightalignment', modName='HartapfelFX Light Alignment', version=VERSION,
        description='Aligns supported candle, torch and brazier lights with flame emitters, '
                    'including a native bathhouse world-light fix. No RenoDX or BetterCandles required.',
        author='Hartapfel', succesfullyCooked=True, useLooseScripts=True), indent=2) + '\n', encoding='utf-8')
    for source, destination in [('INSTALL.txt', 'README.txt'), ('LICENSE.txt', 'LICENSE.txt')]:
        (mod / destination).write_bytes((ROOT / source).read_bytes())
    files = {path.relative_to(stage).as_posix(): path.read_bytes() for path in sorted(mod.rglob('*')) if path.is_file()}
    manifest = dict(name='HartapfelFX Light Alignment', version=VERSION,
                    fixture_count=len(fixtures), target='The Witcher 3 Remastered',
                    world_light_patch={key: static_manifest[key] for key in ('asset', 'source_sha256', 'sha256', 'before', 'after')},
                    files={name: hashlib.sha256(data).hexdigest() for name, data in files.items()})
    manifest_path = f'Mods/{MOD}/manifest.json'
    files[manifest_path] = (json.dumps(manifest, indent=2) + '\n').encode('utf-8')
    (stage / manifest_path).write_bytes(files[manifest_path])
    archive = output / f'HartapfelFX-Light-Alignment-Remastered-{VERSION}.zip'
    with zipfile.ZipFile(archive, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as packed:
        for name, data in sorted(files.items()):
            entry = zipfile.ZipInfo(name, date_time=(2026, 11, 11, 0, 0, 0))
            entry.compress_type = zipfile.ZIP_DEFLATED
            entry.create_system = 3
            entry.external_attr = 0o100644 << 16
            packed.writestr(entry, data, compresslevel=9)
    with zipfile.ZipFile(archive) as packed:
        if packed.testzip() or set(packed.namelist()) != set(files):
            raise ValueError('archive integrity or coverage failure')
        for name, data in files.items():
            if packed.read(name) != data:
                raise ValueError('archive payload mismatch: ' + name)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix('.zip.sha256').write_text(f'{digest}  {archive.name}\n', encoding='ascii')
    print(f'{archive.resolve()}\nSHA-256 {digest}\n{len(files)} files; {len(fixtures)} fixture identities; {archive.stat().st_size:,} bytes.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True, help='New output directory; existing directories are never replaced.')
    parser.add_argument('--static-content', type=Path, required=True, help='Validated static_lights.py output content directory')
    args = parser.parse_args()
    package(args.output.resolve(), args.static_content.resolve())
