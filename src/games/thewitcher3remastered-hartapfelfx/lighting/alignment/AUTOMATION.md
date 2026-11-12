# Automatic fixture discovery

`catalog.py` builds native light-to-flame associations from installed game data.
One accepted template applies to all its streamed instances through the existing
engine-slot runtime. Players install the resulting ZIP and restart; no Python,
scanner, mod menu or individual scene visits are needed.

## Evidence and limits

[CDPR's light-authoring guide](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/53772302/HOW-TO%2BAdd%2Blight%2Bsources)
separates light components from effects attached to named slots. The scanner
follows those serialized relationships using the bounded WolvenKit-based reader
already documented in [README.md](README.md). Runtime uses the engine's
`CalcEntitySlotMatrix`, including placed translation, rotation, scale and parent
transforms. It does not move a light to the nearest unrelated flame in the world.

The scan indexes every `.w2ent` in the installed content/DLC bundles and enabled
mod bundles, excluding this alignment mod's generated outputs. It examines
serialized point/spot and flame-effect candidates in the physical light-fixture
namespaces `light_sources` and `lightsources`. It requires:

- An owned point/spot component and a supported active flame effect/spawner.
- Explicit, unique native flame slots, without bone or separate light attachments.
- Matching associations across content/DLC duplicates and the highest-priority
  enabled mod override. Shadowed lower-priority mod copies are ignored.
- No unresolved same-stem template paths; runtime names cannot distinguish them.

Individual decompression is bounded at 16 MiB. Unsupported data is skipped and
interesting rejected candidates are recorded with their reasons. Unknown particle
internal displacements still need evidence before adding them to the verified
particle-origin table. The scanner preserves existing reviewed bindings; it
reports disagreements for review instead of replacing them.

The content/DLC baseline includes the installed DLC directories; source paths and
SHA-256 values in the private report identify exactly what was inspected. No game
or third-party fixture assets are redistributed by this catalog operation. The
public package includes only generated names/offsets and its existing separately
guarded bathhouse world patch.

Authored fill lights with no flame relationship, story/cinematic composites,
moving bone emitters, unresolved inheritance and cooked sector lights without
entity-owned slots need separate investigation. The scanner does not claim to
correct these or to eliminate every possible world-light mismatch.

## Developer workflow

Run from the repository root, using a new output directory:

```powershell
python src/games/thewitcher3remastered-hartapfelfx/lighting/alignment/catalog.py --game '<game root>' --mods-settings '<profile>/mods.settings' --lz4-path '<optional lz4 directory>' --output '<new catalog directory>'
python src/games/thewitcher3remastered-hartapfelfx/tests/light_alignment_catalog.py '<new catalog directory>' src/games/thewitcher3remastered-hartapfelfx/lighting/alignment/fixtures.json '<optional lz4 directory>'
```

Review `report.json`, including skipped cases, baseline conflicts and ambiguous
stems, before promoting the candidate `fixtures.json` into this source folder.
The audit re-extracts the added fixtures and checks every recorded source hash,
scope, association and preserved baseline. Package with `package_release.py` and
the independently validated `static_lights.py` content described in README.md.
Validate the generated map's syntax and restart the game to compile it.

11 November 2026: 24,663 entity paths / 64 bundles; 734 potential serialized pairs
reported; 284 template paths pass the structural/scope guards. After name
ambiguity checks and preserving the 266-entry baseline, the catalog contains
337 fixture identities, including 71 additions. These are fixture identities,
not a light-instance count. Zero bundle errors and baseline conflicts occurred.

The original 5-second, 60 m, 2048-entity sweep and per-entity cache are unchanged.
Version 1.1.2 also hooks the W3FireSource spawn override directly. Three audited
large shrine spot/bounce identities use the 12 m bounds in `fixture_limits.json`;
the remaining identities retain 4 m. Discovery never expands these limits from
an asset name alone. Standalone `city_bouncelight_fire` templates have no flame
particle tracks and require a separate, verified world-instance association.
Version 1.1.3 replaces the rigid world-to-local inverse with a full affine
inverse, preserving correct flame height on scaled fixtures.
More names increase the one-time lookup work for newly encountered entities;
there is no new per-frame scan, GPU pass or readback. Actual game CPU/GPU timings
have not been measured. Offline DevKit inspection is cleared after use.

The user restarted with version 1.1.0's map. Two ready native input captures
confirm the current fence torch's point/spot sources move approximately
0.528 / 0.504 m and converge within 3.5 cm including native flicker, preserving
radius/type. Gameplay resumes with the expanded scripts. The subsequent camera
view differs, so no identical-view visual-quality or all-location acceptance
claim is made. See `tmp/light-alignment-auto-20261111/live-verification.json`.
