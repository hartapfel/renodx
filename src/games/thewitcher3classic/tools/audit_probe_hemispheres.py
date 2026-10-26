"""Verify audited numeric hemisphere selectors against original DXBC.

The legacy decompiler formatted integer bit-pattern 1 as float 0.000000,
then numerically cast that zero before an environment-atlas lookup. This
checks the exact native register/condition pairs, not just matching text.
Requires Windows D3DCompiler and an archive of original game shaders.
"""
import argparse
import collections
import json
from pathlib import Path
import re

from audit_hdr_cache import disassemble


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('originals', type=Path)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    report = []
    for source_path in sorted(Path(__file__).resolve().parents[1].rglob('0x*.hlsl')):
        source = source_path.read_text()
        matches = list(re.finditer(
            r'(r\d+\.[xyzw]) = (r\d+\.[xyzw]) \? (0\.000000|1\.f) : (?:0|0\.f);', source))
        if not matches:
            continue
        original = args.originals / (source_path.name.split('.')[0] + '.cso')
        if not original.exists():
            original = args.originals / source_path.name.replace('.hlsl', '.cso')
        assembly = disassemble(original.read_bytes())
        native = re.findall(r'^[ \t]*and (r\d+\.[xyzw]), (r\d+\.[xyzw]), l\(1\)[ \t\r]*$', assembly, re.MULTILINE)
        expected = collections.Counter((match[1], match[2]) for match in matches)
        if expected != collections.Counter(native):
            raise ValueError(f'{source_path.name}: native integer-1 register/condition pairs differ')
        if any(match[3] != '1.f' for match in matches):
            raise ValueError(f'{source_path.name}: rounded-zero hemisphere selector remains')
        report.append({'shader': source_path.name, 'verified_selectors': len(matches)})
    if not report:
        raise ValueError('No audited hemisphere-selector sites found')
    result = {'shaders': report, 'total_selectors': sum(row['verified_selectors'] for row in report)}
    if args.output:
        args.output.write_text(json.dumps(result, indent=2))
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
