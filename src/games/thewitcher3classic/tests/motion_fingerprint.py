"""Regression guards for the offline motion-family discovery tool."""
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from motion_fingerprint import Fingerprinter

SOURCE = '''void main(float3 v0 : POSITION0,
  float4 v1 : INSTANCE_TRANSFORM0,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : SV_Position0) {
  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r0.w = 1;
  r1.x = dot(r0.xyzw, v1.xyzw);
  o0.xyzw = float4(1, 2, 3, 4);
  o1.xyzw = r1.xxxx * cb1[0].xyzw;
  return;
}'''


class FingerprintTests(unittest.TestCase):
    def test_register_renaming_and_unrelated_material_output(self):
        tool = Fingerprinter()
        changed = SOURCE.replace('r0', 'r37').replace('r1', 'r81').replace('float4(1, 2, 3, 4)', 'float4(4, 3, 2, 1)')
        self.assertEqual(tool.position(SOURCE), tool.position(changed))

    def test_position_inputs_and_matrices_are_not_ignored(self):
        tool = Fingerprinter()
        original = tool.position(SOURCE)
        for before, after in [('cb2[4]', 'cb2[6]'), ('cb1[0]', 'cb1[1]'),
                              ('INSTANCE_TRANSFORM0', 'INSTANCE_TRANSFORM1'),
                              ('v1.xyzw', 'v1.yxzw'), ('r0.w = 1', 'r0.w = 0')]:
            self.assertNotEqual(original, tool.position(SOURCE.replace(before, after)))

    def test_unknown_position_expression_and_control_flow_are_rejected(self):
        tool = Fingerprinter()
        for source in [SOURCE.replace('r0.w = 1', 'r0.w = unknown(r0.x)'),
                       SOURCE.replace('  return;', '  if (v0.x) { o1.x = 0; }\n  return;')]:
            with self.assertRaises(ValueError):
                tool.position(source)

    def test_unknown_unrelated_material_math_does_not_poison_position(self):
        tool = Fingerprinter()
        self.assertEqual(tool.position(SOURCE), tool.position(SOURCE.replace('float4(1, 2, 3, 4)', 'unknown(v0.x)')))

    def test_unrelated_control_flow_does_not_change_an_emitted_position(self):
        tool = Fingerprinter()
        changed = SOURCE.replace('  return;', '  if (v0.x) {\n    r0.xyzw = float4(4, 3, 2, 1);\n  }\n  return;')
        self.assertEqual(tool.position(SOURCE), tool.position(changed))

    def test_branch_written_input_to_position_is_rejected(self):
        changed = SOURCE.replace('  o1.xyzw', '  if (v0.x) {\n    r1.x = 0;\n  }\n  o1.xyzw')
        with self.assertRaises(ValueError):
            Fingerprinter().position(changed)


if __name__ == '__main__':
    unittest.main()
