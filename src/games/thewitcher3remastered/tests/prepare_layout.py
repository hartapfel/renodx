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
