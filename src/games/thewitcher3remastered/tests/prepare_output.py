"""Adapt both real output shaders to CS5.0 for the D3D11 WARP harness.

Only register spaces, entry-point plumbing and the select spelling change.
All production composition and PQ arithmetic remains intact.
Run from the repository root with a scratch output directory argument.
"""
from pathlib import Path
import sys

root = Path.cwd()
mod = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else root / "src/games/thewitcher3remastered"
dest = Path(sys.argv[1]).resolve()
for source in mod.rglob("*"):
    if not source.is_file() or source.suffix not in (".h", ".hlsl", ".hlsli"):
        continue
    target = dest / source.relative_to(mod)
    target.parent.mkdir(parents=True, exist_ok=True)
    text = source.read_text().replace("../../shaders/", (root / "src/shaders").as_posix() + "/")
    text = text.replace("register(b13, space50)", "register(b13)")
    text = text.replace("register(t0, space51)", "register(t3)")
    if source.parent.name == "output":
        text = "#pragma warning(disable:3571)\n#define select(c,a,b) ((c)?(a):(b))\n" + text
        text = text.replace("OutputSignature main(", "OutputSignature PixelMain(")
        text += """
RWStructuredBuffer<float4> results : register(u0);
[numthreads(64,1,1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint i = id.x;
  float2 position = float2(i % 32, i / 32) + 0.5f;
  OutputSignature o = PixelMain(float4(position, 0, 1), position / float2(32, 16));
  results[i * 4] = o.SV_Target;
  results[i * 4 + 1] = o.SV_Target_1;
"""
        if source.name.startswith("0x496222DA"):
            text += "  results[i * 4 + 2] = o.SV_Target_2;\n  results[i * 4 + 3] = o.SV_Target_3;\n"
        else:
            text += "  results[i * 4 + 2] = 0;\n  results[i * 4 + 3] = 0;\n"
        text += "}\n"
    target.write_text(text)
