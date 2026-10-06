"""Adapt the three LUT and five grading shaders to the D3D11 WARP harness.

Run from the repository root: python <this file> <scratch dir> <baseline mod dir>.
Only register spaces, sampling derivatives and entry-point plumbing change.
"""
from pathlib import Path
import subprocess
import sys

root = Path.cwd()
mod = root / "src/games/thewitcher3remastered"
out = Path(sys.argv[1]).resolve()
baseline = Path(sys.argv[2]).resolve()
targets = [("postprocess", name) for name in (
    "0xF961D049", "0xC5AB358E", "0x16967617", "0xAD02BAB3", "0x9600E32A",
)] + [("luts", name) for name in ("0x2F2D0992", "0x90AD6BBC", "0x0F6A9050")]

for mode, source_root in (("before", baseline), ("after", mod)):
    dest = out / ("gpu-" + mode)
    for source in source_root.rglob("*"):
        if not source.is_file() or source.suffix not in (".h", ".hlsl", ".hlsli"):
            continue
        target = dest / source.relative_to(source_root)
        target.parent.mkdir(parents=True, exist_ok=True)
        text = source.read_text().replace("../../shaders/", (root / "src/shaders").as_posix() + "/")
        text = text.replace("register(b13, space50)", "register(b13)")
        for texture, sampler, uv in (("t2", "s2", "TEXCOORD_2"),
                                     ("t2", "s2", "float2(TEXCOORD_2.x, TEXCOORD_2.y)"),
                                     ("t0", "s0", "float2(_18, _19)"),
                                     ("t0", "s0", "float2(_16, _17)")):
            text = text.replace(f"{texture}.Sample({sampler}, {uv})",
                                f"{texture}.SampleLevel({sampler}, {uv}, 0.f)")
        if any(source.name == name + ".ps_6_6.hlsl" for _, name in targets):
            text = "#pragma warning(disable:3571)\n#define select(c,a,b) ((c)?(a):(b))\n" + text
            text = text.replace("float4 main(", "float4 PixelMain(")
            args = "float4(float2(i%32,i/32)+0.5f,0,1),uv"
            if source.parent.name == "postprocess" and not source.name.startswith(("0xF961D049", "0x9600E32A")):
                args += ",uv"
            text += """
RWStructuredBuffer<float4> result_buffer : register(u0);
[numthreads(64,1,1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint i = id.x;
  float2 uv = (float2(i%32,i/32)+0.5f)/float2(32,16);
  float4 graded = PixelMain(ARGS);
  float3 source = t0.Load(int3(i%32,i/32,0)).rgb;
  result_buffer[i*4] = graded;
  result_buffer[i*4+1] = float4(WitcherToneMapPsychoV30(source),1);
  WitcherGradeState state = WitcherPrepareGrade(source);
  result_buffer[i*4+2] = float4(WitcherRestoreGrade(state.neutral_sdr,state),1);
  // Triplets straddle each LMS zero plane with the other cones held fixed.
  float3 cones = float3(1.2f,0.8f,0.3f)*exp2(float((i/9)%17)-8.f);
  float crossing = (float(i%3)-1.f)*1e-6f;
  if ((i/3)%3 == 0) cones.x = crossing;
  else if ((i/3)%3 == 1) cones.y = crossing;
  else cones.z = crossing;
  if (i == 510) cones = 0.f;
  if (i == 511) cones = float3(-1.f,-1.f,1.f);
  result_buffer[i*4+3] = float4(WitcherToneMapPsychoV30(mul(
      renodx::tonemap::psychov::PSYCHO30_LMS_TO_BT709_MAT,
      cones*renodx::tonemap::psychov::PSYCHO30_D65_WHITE_LMS*0.18f)),1);
}
""".replace("ARGS", args)
        target.write_text(text)
    for folder, name in targets:
        subprocess.run([str(root / "bin/fxc.exe"), "/nologo", "/T", "cs_5_0", "/E", "main", "/O3",
                        "/Fo", str(dest / (name + ".cso")), str(dest / folder / (name + ".ps_6_6.hlsl"))],
                       check=True, stdout=subprocess.DEVNULL)
print("Compiled all three LUT and five post-grade variants before/after for WARP", flush=True)
