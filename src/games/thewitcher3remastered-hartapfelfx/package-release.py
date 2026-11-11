"""Assemble the game-root release without reading personal ReShade profiles."""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import struct
import subprocess
import sys
import tempfile
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
sys.path.insert(0, str(ROOT / 'lighting/alignment'))
import package_release as alignment
import static_lights

BIN = 'bin/x64_dx12/'
MOD = f'Mods/{alignment.MOD}/'
MANIFEST = 'HartapfelFX-manifest.json'


def pe_exports(data):
    """Validate a bounded x64 DLL and read its export names without loading it."""
    def read(fmt, offset):
        if offset < 0 or offset + struct.calcsize(fmt) > len(data):
            raise ValueError('Truncated PE file')
        return struct.unpack_from(fmt, data, offset)

    if data[:2] != b'MZ':
        raise ValueError('Not a Windows PE file')
    pe, = read('<I', 0x3c)
    signature, machine, sections = read('<IHH', pe)
    optional_size, characteristics = read('<HH', pe + 20)
    if signature != 0x4550 or machine != 0x8664 or not characteristics & 0x2000:
        raise ValueError('Expected a Windows x64 DLL')
    optional = pe + 24
    if read('<H', optional)[0] != 0x20b or optional_size < 120:
        raise ValueError('Expected a PE32+ optional header')

    def offset(rva):
        for index in range(sections):
            section = optional + optional_size + index * 40
            address, size, start = read('<III', section + 12)
            if address <= rva < address + size:
                result = start + rva - address
                if result < len(data):
                    return result
        raise ValueError('PE export points outside file-backed sections')

    export_rva, = read('<I', optional + 112)
    if not export_rva:
        raise ValueError('DLL has no exports')
    directory = offset(export_rva)
    count, = read('<I', directory + 24)
    names, = read('<I', directory + 32)
    if count > 65536:
        raise ValueError('Invalid PE export count')
    table = offset(names)
    exports = set()
    for index in range(count):
        start = offset(read('<I', table + index * 4)[0])
        end = data.find(b'\0', start, min(start + 4096, len(data)))
        if end < 0:
            raise ValueError('Unterminated PE export name')
        exports.add(data[start:end].decode('ascii'))
    return exports


def alignment_payload(seed, work):
    """Reuse verified cooked content; regenerate scripts/maps from current source."""
    required = {MOD + name for name in (
        'README.txt', 'LICENSE.txt', 'manifest.json', 'content/info.json',
        'content/blob0.bundle', 'content/metadata.store',
        'content/scripts/local/hf_light_alignment.ws',
        'content/scripts/local/hf_light_alignment_map.ws')}
    with zipfile.ZipFile(seed) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)) or set(names) != required:
            raise ValueError('Alignment seed must be the complete standalone release ZIP')
        if sum(entry.file_size for entry in archive.infolist()) > 16 * 1024 * 1024:
            raise ValueError('Alignment seed exceeds the expected size budget')
        files = {name: archive.read(name) for name in names}
    manifest = json.loads(files[MOD + 'manifest.json'])
    if set(manifest['files']) != required - {MOD + 'manifest.json'}:
        raise ValueError('Alignment seed manifest does not cover its payload')
    for name, digest in manifest['files'].items():
        if hashlib.sha256(files[name]).hexdigest() != digest:
            raise ValueError('Alignment seed checksum mismatch: ' + name)
    world = manifest['world_light_patch']
    if (world['asset'] != static_lights.ASSET
            or world['source_sha256'] != static_lights.SOURCE_SHA256
            or world['sha256'] != '44a0754e0303d129c131ce31f491c8f2485f2ce200887eca976359d39363fdb0'
            or world['before'] != list(static_lights.LOWER)
            or world['after'] != list(static_lights.UPPER)):
        raise ValueError('Alignment world patch does not target the audited Remastered layer')
    # These hashes pin the already accepted cooked patch, not arbitrary game
    # files from an install. A new native correction requires a reviewed update.
    expected_static = {
        'blob0.bundle': '49e5fd4fb5f2cbe10bbee07c7e535bef4526c75beeebdb2d6fef818f15947727',
        'metadata.store': '1143d328c38a10c60f45c2c08a67b2be6605c1ebd8d2cf04ec4b6b379f90e4fd',
    }
    content = work / 'static/content'
    content.mkdir(parents=True)
    for name, digest in expected_static.items():
        data = files[MOD + 'content/' + name]
        if hashlib.sha256(data).hexdigest() != digest:
            raise ValueError('Unrecognized native alignment patch: ' + name)
        (content / name).write_bytes(data)
    (content.parent / 'manifest.json').write_text(json.dumps(dict(world, files=expected_static)), encoding='utf-8')
    # Reuse the standalone packager's fixture validation, runtime generator,
    # metadata and manifest logic; do not maintain a second emitter map.
    alignment.package(work / 'alignment', content)
    with zipfile.ZipFile(work / 'alignment' / f'HartapfelFX-Light-Alignment-Remastered-{alignment.VERSION}.zip') as archive:
        return {name: archive.read(name) for name in archive.namelist()}


def package(addon, seed, output, version):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]*', version):
        raise ValueError('Invalid release version')
    addon_data = addon.read_bytes()
    if not {'NAME', 'DESCRIPTION'} <= pe_exports(addon_data):
        raise ValueError('Release DLL is not a RenoDX addon')
    output.mkdir(parents=True, exist_ok=True)
    destination = output / f'HartapfelFX-Witcher3-Remastered-{version}.zip'
    with tempfile.TemporaryDirectory(prefix='hartapfelfx-package-', dir=output) as directory:
        work = Path(directory)
        files = alignment_payload(seed, work)
        files[BIN + 'renodx-thewitcher3remastered-hartapfelfx.addon64'] = addon_data
        files['HartapfelFX-README.txt'] = (ROOT / 'PACKAGE-INSTALL.txt').read_bytes()
        licenses = {
            'RenoDX-LICENSE.txt': REPO / 'LICENSE',
            'FAST-LICENSE.txt': ROOT / 'clouds/LICENSE.fastnoise',
            'Detours-LICENSE.txt': REPO / 'external/Detours/LICENSE.md',
            'JSON-LICENSE.txt': REPO / 'external/json/LICENSE.MIT',
            'Frozen-LICENSE.txt': REPO / 'external/frozen/LICENSE',
            'GTL-LICENSE.txt': REPO / 'external/gtl/LICENSE',
        }
        for name, path in licenses.items():
            files[BIN + 'renodx-hartapfelfx-licenses/' + name] = path.read_bytes()
        try:
            revision = subprocess.check_output(['git', '-C', str(REPO), 'rev-parse', 'HEAD'], text=True, stderr=subprocess.DEVNULL).strip()
            modified = bool(subprocess.check_output(['git', '-C', str(REPO), 'status', '--porcelain', '--untracked-files=normal', '--', str(ROOT)], text=True, stderr=subprocess.DEVNULL).strip())
        except (OSError, subprocess.CalledProcessError):
            revision = 'unknown'
            modified = None
        alignment_manifest = json.loads(files[MOD + 'manifest.json'])
        files[MANIFEST] = (json.dumps(dict(
            name='HartapfelFX - The Witcher 3 Remastered', version=version,
            target='Remastered 5.0.16 / Windows x64 / DX12', source_commit=revision, source_modified=modified,
            includes_reshade=False,
            alignment_version=alignment.VERSION, fixture_count=alignment_manifest['fixture_count'],
            files={name: hashlib.sha256(data).hexdigest() for name, data in sorted(files.items())},
        ), indent=2) + '\n').encode('utf-8')
        temporary = work / 'release.zip'
        with zipfile.ZipFile(temporary, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for name, data in sorted(files.items()):
                path = PurePosixPath(name)
                if path.is_absolute() or '..' in path.parts or '\\' in name or ':' in name:
                    raise ValueError('Unsafe package member: ' + name)
                entry = zipfile.ZipInfo(name, date_time=(2026, 11, 11, 0, 0, 0))
                entry.create_system = 3
                entry.external_attr = 0o100644 << 16
                entry.compress_type = zipfile.ZIP_DEFLATED
                archive.writestr(entry, data, compresslevel=9)
        # Validate decompressed bytes, not just the archive's directory listing.
        with zipfile.ZipFile(temporary) as archive:
            if archive.testzip() or set(archive.namelist()) != set(files):
                raise ValueError('Release ZIP integrity or coverage failure')
            for name, data in files.items():
                if archive.read(name) != data:
                    raise ValueError('Release ZIP content mismatch: ' + name)
        digest = hashlib.sha256(temporary.read_bytes()).hexdigest()
        checksum = work / 'release.sha256'
        checksum.write_text(f'{digest}  {destination.name}\n', encoding='ascii')
        temporary.replace(destination)
        checksum.replace(destination.with_suffix('.zip.sha256'))
    print(f'Packaged and verified: {destination.resolve()}\nSHA-256: {digest}')
    print(f'{len(files)} files; {alignment_manifest["fixture_count"]} fixture identities; no ReShade loader')
    print('Extract this ZIP directly into the main game folder.')
    return destination


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--addon', type=Path, required=True)
    parser.add_argument('--alignment-package', type=Path, required=True)
    parser.add_argument('--output-directory', type=Path, required=True)
    parser.add_argument('--version', required=True)
    args = parser.parse_args()
    try:
        package(args.addon.resolve(), args.alignment_package.resolve(), args.output_directory.resolve(),
                args.version)
    except (OSError, ValueError, KeyError, zipfile.BadZipFile, struct.error) as error:
        parser.exit(1, f'Packaging failed: {error}\n')
