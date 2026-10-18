"""Extract the production layout predicate and tone mapper setting for host tests."""
from pathlib import Path
import sys

source = (Path(__file__).resolve().parents[1] / "addon.cpp").read_text()
dest = Path(sys.argv[1])
dest.mkdir(parents=True, exist_ok=True)
predicate = source[source.index("bool ShouldInjectPostProcessLayout("):source.index("\nbool IsPsychoV()")]
start = source.index('        .key = "ToneMapType",')
setting = source[start:source.index("\n    },", start)]
(dest / "postprocess-layout.h").write_text(predicate + "\n")
(dest / "tone-map-setting.h").write_text(setting + "\n")

packed = []
for key in ("ColorGradeHighlights", "ColorGradeShadows", "ColorGradeContrast",
            "ColorGradeHighlightSaturation", "ColorGradeBlowout", "ColorGradeFlare",
            "ToneMapHueShift", "FxSharpening"):
    start = source.index('        .key = "' + key + '",')
    block = source[start:source.index("\n    },", start)]
    # Visibility callbacks belong to the addon UI, not this layout host.
    block = "\n".join(line for line in block.splitlines()
                      if ".is_enabled =" not in line and ".is_visible =" not in line)
    packed.append("{\n" + block + "\n},")
start = source.index("std::vector<uint32_t> PackedPercentValues(")
end = source.index("\nrenodx::utils::settings::Settings", start)
(dest / "postprocess-layout.h").write_text(predicate + "\n" + source[start:end] + "\n")
(dest / "packed-percentage-settings.h").write_text("\n".join(packed) + "\n")
