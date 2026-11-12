"""Build position-only overrides from the user's effective light-source assets.

CR2W and bundle structures: WolvenKit/WolvenKit-7, documented in README.md.
Game assets are build inputs/outputs and must not be committed to this folder.
"""
# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
import argparse
import configparser
import hashlib
import json
import math
from pathlib import Path, PureWindowsPath
import re
import struct
import subprocess
import sys
import zlib


class Unsupported(ValueError):
    pass


IDENTITY = dict(x=0., y=0., z=0., pitch=0., yaw=0., roll=0., sx=1., sy=1., sz=1.)


class Document:
    """Bounded, position-preserving reader for the required CR2W properties."""

    def __init__(self, data, base=0, length=None):
        self.data, self.base = data, base
        self.end = base + (len(data) - base if length is None else length)
        if data[base:base + 4] != b'CR2W' or self.end > len(data):
            raise Unsupported('invalid CR2W boundary')
        if self.unpack('<I', base + 4)[0] not in (161, 162, 163, 164):
            raise Unsupported('unverified CR2W version')
        self.tables = [self.unpack('<III', base + 40 + i * 12) for i in range(10)]
        start, count, _ = self.tables[0]
        self.strings = self.bytes(base + start, count)
        self.names = [self.string(self.unpack('<I', base + self.tables[1][0] + i * 8)[0])
                      for i in range(self.tables[1][1])]
        self.imports = [self.string(self.unpack('<I', base + self.tables[2][0] + i * 8)[0])
                        for i in range(self.tables[2][1])]
        self.chunks = []
        for i in range(self.tables[4][1]):
            entry = base + self.tables[4][0] + i * 24
            cls, flags, parent, size, offset, template, crc = self.unpack('<HHIIIII', entry)
            if self.bytes(base + offset, 1) != b'\0':
                raise Unsupported('unverified chunk property prefix')
            props, _ = self.properties(base + offset + 1, base + offset + size)
            self.chunks.append(dict(cls=self.names[cls], props=props, entry=entry,
                                    start=base + offset, size=size, crc=crc))
        self.children = []
        for chunk in self.chunks:
            self.find_documents(chunk['props'])

    def unpack(self, fmt, offset):
        self.bytes(offset, struct.calcsize(fmt))
        return struct.unpack_from(fmt, self.data, offset)

    def bytes(self, offset, size):
        if size < 0 or offset < self.base or offset + size > self.end:
            raise Unsupported('property outside CR2W boundary')
        return self.data[offset:offset + size]

    def string(self, offset):
        if offset >= len(self.strings):
            raise Unsupported('invalid string reference')
        return self.strings[offset:].split(b'\0', 1)[0].decode('utf-8')

    def properties(self, pos, end):
        result = {}
        while pos + 2 <= end:
            name = self.unpack('<H', pos)[0]
            if not name:
                return result, pos + 2
            ty, size = self.unpack('<HI', pos + 2)
            if name >= len(self.names) or ty >= len(self.names) or size < 4 or pos + size + 4 > end:
                raise Unsupported('invalid property record')
            prop = dict(type=self.names[ty], offset=pos + 8, size=size - 4)
            prop['value'] = self.value(prop)
            result[self.names[name]] = prop
            pos += size + 4
        raise Unsupported('unterminated properties')

    def value(self, prop):
        pos, size, ty = prop['offset'], prop['size'], prop['type']
        if ty == 'CName':
            return self.names[self.unpack('<H', pos)[0]]
        if ty == 'String':
            # Component identifiers in supported assets use short ANSI strings.
            first = self.bytes(pos, 1)[0]
            if first & 0xC0 != 0x80 or first & 0x3F != size - 1:
                raise Unsupported('unverified component-name encoding')
            return self.bytes(pos + 1, size - 1).decode('ascii')
        if ty == 'EngineTransform':
            flags = self.bytes(pos, 1)[0]
            if flags & ~7:
                raise Unsupported('unknown transform flags')
            values = IDENTITY.copy()
            cursor = pos + 1
            for bit, keys in [(1, ('x', 'y', 'z')), (2, ('pitch', 'yaw', 'roll')), (4, ('sx', 'sy', 'sz'))]:
                if flags & bit:
                    values.update(zip(keys, self.unpack('<3f', cursor)))
                    cursor += 12
            if cursor != pos + size or not all(map(math.isfinite, values.values())):
                raise Unsupported('invalid transform')
            return values
        if ty == 'Vector':
            values, _ = self.properties(pos + 1, pos + size)
            return {key.lower(): get(values, key, 0.) for key in ('X', 'Y', 'Z')}
        if ty == 'Float':
            return self.unpack('<f', pos)[0]
        if ty == 'ELightUsageMask':
            return [self.names[x] for x in self.unpack('<' + 'H' * (size // 2), pos) if x]
        if ty == 'array:2,0,CName':
            count = self.unpack('<I', pos)[0]
            if size != 4 + count * 2:
                raise Unsupported('invalid name array')
            return [self.names[x] for x in self.unpack('<' + 'H' * count, pos + 4)]
        if ty in ('array:2,0,EntitySlot', 'array:2,0,CEntityTemplateCookedEffect', 'array:2,0,SStreamedAttachment'):
            count = self.unpack('<I', pos)[0]
            cursor, result = pos + 4, []
            for _ in range(count):
                if self.bytes(cursor, 1) != b'\0':
                    raise Unsupported('unverified struct property prefix')
                values, cursor = self.properties(cursor + 1, pos + size)
                result.append(values)
            if cursor != pos + size:
                raise Unsupported('invalid struct array')
            return result
        if ty.startswith('ptr:'):
            return self.unpack('<i', pos)[0]
        if ty == 'soft:CParticleSystem':
            index = self.unpack('<H', pos)[0]
            if not 1 <= index <= len(self.imports):
                raise Unsupported('unresolved particle resource')
            return self.imports[index - 1]
        return None

    def find_documents(self, props):
        for prop in props.values():
            if prop['type'] in ('SharedDataBuffer', 'CByteArray', 'array:2,0,Uint8') and prop['size'] >= 8:
                pos = prop['offset']
                if self.bytes(pos + 4, 4) == b'CR2W':
                    length = self.unpack('<I', pos)[0]
                    if length != prop['size'] - 4:
                        raise Unsupported('unverified embedded document length')
                    child = Document(self.data, pos + 4, length)
                    prop['document'] = child
                    self.children.append(child)
            elif isinstance(prop['value'], list):
                for item in prop['value']:
                    if isinstance(item, dict):
                        self.find_documents(item)

    def documents(self):
        yield self
        for child in self.children:
            yield from child.documents()

    def checksums(self):
        # Inner documents are payload of outer chunks: finalize from the inside out.
        for child in self.children:
            child.checksums()
        for chunk in self.chunks:
            if chunk['crc']:
                struct.pack_into('<I', self.data, chunk['entry'] + 20,
                                 zlib.crc32(self.data[chunk['start']:chunk['start'] + chunk['size']]))
        offset, count, crc = self.tables[4]
        if count and crc:
            struct.pack_into('<I', self.data, self.base + 40 + 4 * 12 + 8,
                             zlib.crc32(self.data[self.base + offset:self.base + offset + count * 24]))
        header = self.data[self.base:self.base + 160]
        struct.pack_into('<I', header, 32, 0xDEADBEEF)
        struct.pack_into('<I', self.data, self.base + 32, zlib.crc32(header))


def get(props, name, default=None):
    return props[name]['value'] if name in props else default


def origin(transform):
    return tuple(transform[key] for key in ('x', 'y', 'z'))


def translate(point, transform):
    # Do not invent a convention for rotated/bone-attached native transforms.
    if any(abs(value) > 1e-8 for value in point) and any(abs(transform[k]) > 1e-5 for k in ('pitch', 'yaw', 'roll')):
        raise Unsupported('rotated emitter parent requires native transform resolution')
    return tuple(point[i] * transform['s' + key] + transform[key] for i, key in enumerate(('x', 'y', 'z')))


def particle_origin(data, emitter_name=None):
    """Read a constant cooked emission origin using WolvenKit's module-data order."""
    document = Document(data)
    emitters = [c for c in document.chunks if c['cls'] == 'CParticleEmitter'
                and (emitter_name is None or get(c['props'], 'editorName') == emitter_name)]
    if len(emitters) != 1:
        raise Unsupported('particle requires an unambiguous selected emitter')
    emitter = emitters[0]
    end = emitter['start'] + emitter['size']
    _, cursor = document.properties(emitter['start'] + 1, end)

    def values(width):
        nonlocal cursor
        # This bounded reader supports the small constant/range buffers used here.
        count = document.bytes(cursor, 1)[0]
        cursor += 1
        if count == 0x80:
            count = 0
        if count > 2 or cursor + count * width * 4 > end:
            raise Unsupported('non-constant or unsupported particle evaluator')
        result = document.unpack('<' + 'f' * (count * width), cursor)
        cursor += count * width * 4
        if not all(map(math.isfinite, result)):
            raise Unsupported('invalid particle evaluator')
        return [result[i:i + width] for i in range(0, len(result), width)]

    values(1)  # alpha
    values(3)  # color
    values(1)  # lifeTime
    positions = values(3)
    if not positions or any(p != positions[0] for p in positions):
        raise Unsupported('particle position is not constant')
    if cursor + 4 > end or document.unpack('<f', cursor)[0] != 0.:
        raise Unsupported('particle position has an additional offset evaluator')
    return positions[0]


def flame_bindings(template, particle_origins=False):
    origins = json.loads(Path(__file__).with_name('particle_origins.json').read_text(encoding='utf-8')) if particle_origins else {}
    bindings = []
    for effect in get(template, 'cookedEffects', []):
        if get(effect, 'name') not in ('fire', 'burn', 'burning'):
            continue
        doc = effect.get('buffer', {}).get('document')
        if not doc:
            continue
        for chunk in doc.chunks:
            if chunk['cls'] != 'CFXTrackItemParticles':
                continue
            path = get(chunk['props'], 'particleSystem', '').lower()
            stem = PureWindowsPath(path).stem
            tokens = stem.split('_')
            if not any(x in stem for x in ('flame', 'fire', 'candle', 'torch', 'brazier')):
                continue
            if any(x in stem for x in ('stop', 'extinguish')):
                continue
            if any(x in stem for x in ('smoke', 'spark', 'ember')) and 'fire' not in tokens and 'flame' not in stem:
                continue
            index = get(chunk['props'], 'spawner', 0) - 1
            if not 0 <= index < len(doc.chunks):
                raise Unsupported('unresolved flame spawner')
            spawner = doc.chunks[index]
            props = spawner['props']
            if spawner['cls'] == 'CFXSimpleSpawner':
                names = get(props, 'slotNames', [])
                relative = get(props, 'relativePos', dict(x=0., y=0., z=0.))
            elif spawner['cls'] == 'CFXSpawnerComponent':
                names = [get(props, 'componentName')]
                relative = get(props, 'relativePosition', dict(x=0., y=0., z=0.))
            else:
                raise Unsupported('unsupported flame spawner class')
            point = origin(relative)
            if path in origins:
                # Non-identity spawner transforms need explicit composition first.
                if any(key in props for key in ('relativeRotation', 'relativeRot', 'relativeScale', 'scale', 'rotation')):
                    raise Unsupported('particle origin requires spawner transform composition')
                point = tuple(a + b for a, b in zip(point, origins[path]['position']))
            for name in names:
                bindings.append(dict(slot=name, offset=point, particle=path))
    if not bindings:
        raise Unsupported('no verified flame particle/slot relationship')
    return list({(b['slot'], b['offset'], b['particle']): b for b in bindings}.values())


def align(data):
    document = Document(data)
    # Versions 163/164 are read for slot maps; byte editing remains verified on 162.
    if document.unpack('<I', 4)[0] != 162:
        raise Unsupported('unverified CR2W editing version')
    templates = [c for c in document.chunks if c['cls'] == 'CEntityTemplate']
    if len(templates) != 1:
        raise Unsupported('missing unique entity template')
    template = templates[0]['props']
    slots = {}
    for slot in get(template, 'slots', []):
        name = get(slot, 'name')
        if name in slots:
            raise Unsupported('duplicate slot identity requires native resolution')
        slots[name] = slot
    components = {}
    documents = list(document.documents())
    for doc in documents:
        for chunk in doc.chunks:
            name = get(chunk['props'], 'name')
            if isinstance(name, str) and chunk['cls'].endswith('Component'):
                components.setdefault(name, chunk['props'])
    emitters = []
    for binding in flame_bindings(template):
        name = binding['slot']
        if name not in slots:
            raise Unsupported('flame slot not present in template')
        slot = slots[name]
        if get(slot, 'boneName'):
            raise Unsupported('bone-attached flame requires native transform resolution')
        point = translate(binding['offset'], get(slot, 'transform', IDENTITY))
        parent = get(slot, 'componentName')
        if parent:
            if parent not in components:
                raise Unsupported('unresolved emitter parent component')
            if 'transform' in components[parent]:
                point = translate(point, get(components[parent], 'transform'))
        emitters.append(dict(slot=name, position=struct.unpack('<3f', struct.pack('<3f', *point)), particle=binding['particle']))
    attached = {get(a, 'childName') for a in get(template, 'streamedAttachments', [])}
    changes = []
    for doc in documents:
        for chunk in doc.chunks:
            if chunk['cls'] not in ('CPointLightComponent', 'CSpotLightComponent'):
                continue
            props = chunk['props']
            name = get(props, 'name')
            if name in attached:
                raise Unsupported('attached light requires attachment-aware editing')
            prop = props.get('transform')
            if not prop or not data[prop['offset']] & 1:
                raise Unsupported('light position is not serialized')
            before = origin(prop['value'])
            emitter = min(emitters, key=lambda e: sum((a-b)**2 for a, b in zip(before, e['position'])))
            distance = math.dist(before, emitter['position'])
            if distance > 4.:
                raise Unsupported('light is too far from the verified emitter group')
            if distance <= .001:
                continue
            struct.pack_into('<3f', data, prop['offset'] + 1, *emitter['position'])
            changes.append(dict(component=name, document=doc.base, before=before,
                                after=emitter['position'], slot=emitter['slot'], particle=emitter['particle']))
    if changes:
        document.checksums()
        Document(data)  # Verify the edited hierarchy before it can be packaged.
    return changes


def bundle_items(path):
    with path.open('rb') as stream:
        header = stream.read(32)
        if header[:8] != b'POTATO70':
            raise Unsupported('invalid bundle header')
        table_bytes = struct.unpack_from('<I', header, 16)[0]
        version = struct.unpack_from('<H', header, 20)[0]
        stride = {3: 320, 5: 304}.get(version)
        if not stride or table_bytes % stride or table_bytes > path.stat().st_size - 32:
            raise Unsupported('invalid bundle table')
        table = stream.read(table_bytes)
        for pos in range(0, table_bytes, stride):
            name = table[pos:pos + 256].split(b'\0', 1)[0].decode('latin1')
            if version == 3:
                _, size, compressed, offset = struct.unpack_from('<4I', table, pos + 272)
                compression = struct.unpack_from('<I', table, pos + 316)[0]
            else:
                offset, size, compressed, _, compression = struct.unpack_from('<Q4I', table, pos + 272)
            if offset < table_bytes + 32 or offset + compressed > path.stat().st_size:
                raise Unsupported('bundle payload outside file: ' + name)
            yield name, dict(bundle=path, size=size, compressed=compressed, offset=offset,
                             compression=compression)


def extract(item):
    with item['bundle'].open('rb') as stream:
        stream.seek(item['offset'])
        raw = stream.read(item['compressed'])
    if item['compression'] == 0:
        result = raw
    elif item['compression'] in (4, 5):
        import lz4.block
        result = lz4.block.decompress(raw, uncompressed_size=item['size'])
    elif item['compression'] == 1:
        result = zlib.decompress(raw)
    else:
        raise Unsupported('unsupported bundle compression')
    if len(result) != item['size']:
        raise Unsupported('decompressed asset size mismatch')
    return result


def collect_runtime_fixtures(report):
    fixtures = {}
    for entry in report:
        bindings = entry.get('runtime_emitters')
        if not bindings:
            continue
        stem = PureWindowsPath(entry['asset']).stem.lower()
        targets = sorted({(b['slot'], tuple(b['offset'])) for b in bindings})
        if not re.fullmatch(r'[a-z0-9_]+', stem) or any(not re.fullmatch(r'[A-Za-z0-9_]+', slot) for slot, _ in targets):
            continue
        fixtures.setdefault(stem, []).append(targets)
    return {stem: variants[0] for stem, variants in fixtures.items() if all(v == variants[0] for v in variants)}


def write_runtime(content, fixtures):
    limits = json.loads(Path(__file__).with_name('fixture_limits.json').read_text(encoding='utf-8'))
    if any(not re.fullmatch(r'[a-z0-9_]+', stem) or not math.isfinite(value) or not 4. < value <= 12.
           for stem, value in limits.items()):
        raise ValueError('invalid reviewed fixture correction limit')
    scripts = content / 'scripts/local'
    scripts.mkdir(parents=True)
    (scripts / 'hf_light_alignment.ws').write_bytes(Path(__file__).with_name('runtime.ws').read_bytes())
    # Keep individual WitcherScript functions small; jump offsets are limited.
    rows = sorted(fixtures.items(), key=lambda item: (-len(item[0]), item[0]))
    shards = []
    for start in range(0, len(rows), 24):
        index = len(shards)
        lines = [f'function HFAlignEmitterMap{index}(text : string, out slots : array<name>, out offsets : array<Vector>, out maxDistance : float) : bool', '{']
        for stem, targets in rows[start:start + 24]:
            lines.extend([f'    if (HFAlignTemplateMatches(text, "{stem}"))', '    {'])
            if stem in limits:
                lines.append(f'        maxDistance = {limits[stem]:.1f};')
            for slot, point in targets:
                lines.append(f"        slots.PushBack('{slot}');")
                lines.append('        offsets.PushBack(Vector(' + ', '.join(f'{x:.9f}' for x in point) + ', 1.0));')
            lines.extend(['        return true;', '    }'])
        lines.extend(['    return false;', '}', ''])
        shards.append('\n'.join(lines))
    facade = ['// Generated from effective flame particle/spawner relationships. Do not edit.',
              'function HFAlignEmitterMap(entity : CEntity, out slots : array<name>, out offsets : array<Vector>, out maxDistance : float) : bool',
              '{', '    var text : string;', '    slots.Clear();', '    offsets.Clear();',
              '    maxDistance = 4.0;', '    text = StrLower(entity.ToString());']
    for i in range(len(shards)):
        facade.extend([f'    if (HFAlignEmitterMap{i}(text, slots, offsets, maxDistance))', '        return true;'])
    facade.extend(['    return false;', '}', ''])
    (scripts / 'hf_light_alignment_map.ws').write_text('\n'.join(facade) + '\n'.join(shards))
    print(f'Generated engine slot resolution for {len(fixtures)} fixture identities.')


def build(args):
    if args.lz4_path:
        sys.path.insert(0, str(args.lz4_path.resolve()))
    config = configparser.ConfigParser()
    if args.mods_settings:
        config.read(args.mods_settings, encoding='utf-8-sig')
    mods = [p for p in (args.game / 'Mods').iterdir() if p.is_dir() and p.name.lower().startswith('mod')
            and p.name != 'mod0000_HartapfelLightAlignment']
    mods = [p for p in mods if config.getint(p.name, 'Enabled', fallback=1)]
    mods.sort(key=lambda p: (config.getint(p.name, 'Priority', fallback=1000000), p.name.lower()))
    source = args.game / 'Mods' / args.source_mod / 'content'
    wanted = {name for path in source.glob('*.bundle') for name, _ in bundle_items(path) if name.endswith('.w2ent')}
    effective = {}
    for mod in mods:
        for path in sorted((mod / 'content').glob('*.bundle')):
            for name, item in bundle_items(path):
                if name in wanted:
                    if name in effective and effective[name]['bundle'].parent == path.parent:
                        if extract(effective[name]) != extract(item):
                            raise Unsupported('ambiguous duplicate asset in one mod: ' + name)
                    effective.setdefault(name, item)
    raw_root = args.output / 'raw'
    if args.output.exists():
        raise ValueError('use a new output directory to preserve prior candidates')
    raw_root.mkdir(parents=True)
    report = []
    for name, item in sorted(effective.items()):
        before = extract(item)
        after = bytearray(before)
        entry = dict(asset=name, source=str(item['bundle']), source_sha256=hashlib.sha256(before).hexdigest())
        try:
            doc = Document(before)
            templates = [c['props'] for c in doc.chunks if c['cls'] == 'CEntityTemplate']
            if len(templates) != 1:
                raise Unsupported('missing unique entity template')
            template = templates[0]
            if any(get(slot, 'boneName') for slot in get(template, 'slots', [])):
                raise Unsupported('animated bone slots require continuous tracking')
            if any('LightComponent' in get(a, 'childClass', '') for a in get(template, 'streamedAttachments', [])):
                raise Unsupported('light attachment requires parent-aware updates')
            entry['runtime_emitters'] = flame_bindings(template, particle_origins=True)
        except (Unsupported, IndexError, UnicodeError, struct.error) as error:
            entry['runtime_reason'] = str(error)
        try:
            entry['changes'] = align(after)
            if entry['changes']:
                relative = PureWindowsPath(name)
                if relative.is_absolute() or '..' in relative.parts:
                    raise ValueError('unsafe asset path')
                target = raw_root.joinpath(*relative.parts)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(after)
                entry['sha256'] = hashlib.sha256(after).hexdigest()
                entry['status'] = 'aligned'
            else:
                entry['status'] = 'already_aligned'
        except (Unsupported, IndexError, UnicodeError, struct.error) as error:
            entry['status'], entry['reason'] = 'unchanged', str(error)
        report.append(entry)
    (args.output / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    aligned = [r for r in report if r['status'] == 'aligned']
    print(f'Inspected {len(report)} effective templates; aligned {len(aligned)}; '
          f'updated {sum(len(r["changes"]) for r in aligned)} serialized light transforms.')
    if not aligned:
        raise ValueError('no verified alignment corrections were generated')
    if args.w3bundle:
        content = args.output / 'mod0000_HartapfelLightAlignment' / 'content'
        content.mkdir(parents=True)
        write_runtime(content, collect_runtime_fixtures(report))
        subprocess.run([str(args.w3bundle.resolve()), 'build', '-dir=' + str(raw_root.resolve()),
                        '-outdir=' + str(content.resolve())], check=True)
        (content / 'info.json').write_text(json.dumps(dict(
            name='hartapfelfxlightalignment', modName='HartapfelFX Light Alignment', version='1.0.0',
            description='Positions supported candle, torch and fire lights at their authored flame emitters. '
                        'Generated for this installed mod setup; rebuild after light-source mod updates.',
            author='Hartapfel', succesfullyCooked=True, useLooseScripts=True), indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game', type=Path, required=True)
    parser.add_argument('--source-mod', default='modBetterCandles')
    parser.add_argument('--mods-settings', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--lz4-path', type=Path)
    parser.add_argument('--w3bundle', type=Path)
    build(parser.parse_args())
