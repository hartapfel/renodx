# Local light alignment

## Standalone release

The public **HartapfelFX Light Alignment 1.1.1** is a standalone mod-manager
ZIP, independent of RenoDX, ReShade, BetterCandles and NativeBridge. It contains
`Mods/mod0000_HartapfelLightAlignment/content/scripts/local` and its metadata,
one native bathhouse world-light correction, installation notes, license and
payload hashes. Players install the archive;
the game compiles its scripts at startup. See [player instructions](INSTALL.txt).
The existing personalized asset prototype described below is separate from
this public package. Remove that old mod folder before switching to the public
release, since overwrite updates can retain omitted bundles.

Build the guarded static content patch from the stock Remastered 5.0.16 game
layer first, using Python with `lz4` and the existing W3Bundle build tool. The
subsequent ZIP packager uses only Python's standard library. From the repository root:

```powershell
python src/games/thewitcher3remastered-hartapfelfx/lighting/alignment/static_lights.py --game '<game root>' --output '<new native candidate>' --w3bundle '<W3Bundle.exe>'
python src/games/thewitcher3remastered-hartapfelfx/lighting/alignment/package_release.py --static-content '<new native candidate>/content' --output build/Release/packages/HartapfelFX-Light-Alignment-1.1.1
python src/games/thewitcher3remastered-hartapfelfx/tests/light_alignment_package.py build/Release/packages/HartapfelFX-Light-Alignment-1.1.1/HartapfelFX-Light-Alignment-Remastered-1.1.1.zip '<optional directory containing lz4>'
```

The output directory must be new. The packager includes an explicit set of
original scripts/docs, generated associations and the validated single-layer
native patch. It excludes personal lighting bundles, personal manifests,
absolute paths, native binaries and build tools.
ZIP member order and timestamps are fixed; repacking the same validated native
content, source checkout and Python/zlib toolchain produces identical archives. A `.zip.sha256` accompanies
the ZIP. No addon rebuild or game install changes are needed to produce it.

`fixtures.json` is the reviewed, generated catalog of **337 fixture identities**,
containing only names and resolved flame-emission offsets. Its original 201 entries
come from candidate 06; another 62 verified brazier/fireplace identities were extracted
from effective installed templates. Version 1.0.1 adds three verified small wooden
wall-torch variants. Version 1.1.0 adds 71 identities from the automatic installed-data
scan, including the current fence-mounted long torch. Missing native slots are skipped at runtime.
The catalog is a supported fixture set, not a whole-world instance count.

### Torch self-shadow halo, version 1.1.1

The user's dark halo around a torch exposed a missing particle-internal offset.
The earlier map aligned the light to the effect attachment/spawner; the actual
`torch_fx1.w2p` flame initializes at `(-0.01, 0, 0.10)` within that effect.
At the supplied view, native depth at the point-light projection is 4.081004 m
and the light's view depth is 4.097690 m: the old source is approximately 1.7 cm
inside the visible torch surface. Replaying its camera-depth query blocks almost
every nearby ray. Shadowing this misplaced point is not a reliable flame halo.

The particle has six emitters. The bounded parser now supports an explicit,
unique editor-name selection and verifies `Copy of new_fire_looped`, rather than
using the smoke, glow, sphere or sparks origin. The selected flame has identical
position endpoints and zero additional position offset. Its source SHA-256 is
`0edf0b62a621e4bc0008a640d782e859601740ea6697762996e943be9d05b713`.
Thirteen hand/long/wall torch identities compose this measured displacement.
The other 324 bindings and all native slot identities remain unchanged.

All 337 source associations were re-extracted and matched against the old map
before changing the thirteen particle offsets. Hash, named-emitter, constant-range,
missing/ambiguous-emitter rejection and hanging-lamp regressions pass. The correction
uses the native slot matrix, so the offset follows each torch's orientation.
No shadow bias, shadow toggle, strength, sampling budget or geometry rejection is
relaxed to conceal the problem. The addon and runtime script are unchanged.
Live depth/appearance verification follows the user-controlled restart.
Evidence: `tmp/local-light-halo-20261111`, including `inputs.json`,
`depth-replay.json`, `particle-positions.json` and `emitter-corrections.json`.

### Automatic discovery, version 1.1.0

The new [catalog workflow](AUTOMATION.md) searches entity templates across the
installed content, DLC and enabled mods. It checks actual owned light components,
flame effects, spawners and native attachment slots; a player does not need to
visit each instance. This run indexed 24,663 entity paths from 64 bundles and
added 71 identities while preserving all 266 previous bindings. Runtime scanning
frequency, bounds and caching are unchanged. Python and the offline scanner are
developer tools, absent from the player package.

DevKit identifies the user's current Crow's Perch fence torch as
`torch_hand_long_complex`, placed in
`levels/novigrad/baron_lair/baron_castle/fx_lights.w2l` at
`(170.146637, 171.352341, 34.200661)`. The authored flame slot and spawner give
local `(-0.030710, 0.001624, 0.230000)`. The nearby native point and spot pair
matches the fixture's rigid distances within 1.5 cm, including flicker; their
expected corrections are approximately 0.535 m and 0.504 m. Native slot matrices
resolve the actual tilted instance, without an invented Euler convention.

The discovery audit re-extracts every new fixture source and verifies its recorded
SHA-256. Source consistency, fixture scope, ambiguous-name exclusion and all
previous bindings pass. Unsupported gameplay/cinematic entities, bone attachments,
missing slots, unknown formats and ambiguous stems remain review items. Packed
world lights without an entity attachment still require a verified world-layer
association. This automates supported fixture discovery, not a promise of
universal scene reconstruction. Evidence: `tmp/light-alignment-auto-20261111`.
After the user-controlled restart, two ready native captures confirm the current
torch's point moves 0.528 m and its spot 0.504 m. Their separation falls to about
3.5 cm, including native flicker, with unchanged radius/type. The game compiles
the expanded map and resumes gameplay. The camera moved away from the close-up,
so this is numerical position verification, not an identical-view image claim.
See `live-verification.json` and `after-inputs.json` in the evidence directory.
Both input captures are cleared with zero pending readbacks. The local runtime,
personal bundles, bathhouse native patch and both addons retain their pre-install
hashes. Public version 1.1.0 is eight members / 15,497 bytes, SHA-256
`1e3474e80d568f463a19ff88dd09bf18a4d4a6bfd7765b1ce6fbf977f0b9bf2f`.

### Small wooden wall torch, version 1.0.1

A DevKit frame and two ready native `t18` samples identified the user's current
fish-market torch without desktop control. Its placed entity is in
`levels/novigrad/novigrad/fishmarket/water_channel_ns.w2l`, at approximately
`(604.661133, 1746.682373, 4.199560)`, with a 268-degree rotation and a template
import of `torch_wall_wooden_small_bounce`. This family was absent from the map.

The authored `light_point` slot is `(-0.494557, 0, 0.495718)`, whereas
`fx_fire_point` is `(-0.250710, 0.011624, 0.230000)` and its `torch_fx1` effect
spawner adds 0.10 m in Z. The native light at
`(604.678406, 1747.176636, 4.695278)` matches the placed light slot within 0.1 mm.
Composing the verified flame attachment predicts
`(604.681498, 1746.932525, 4.529560)`: a 0.295 m correction, including 0.166 m down.
Runtime code still uses engine slot matrices, including instance transforms.

Added the ordinary, bounce and non-interactive small wooden wall-torch identities.
All eleven stock/installed source occurrences have matching spawner bindings for
their respective identity; the bounce variant needs the 0.10 m offset and the
other two use zero. Ten stock copies pass the existing checksum verifier. The
installed BetterCandles copy has pre-existing chunk checksum diagnostics; its
bounded properties agree with stock, and its asset bytes are neither edited nor
distributed. Only the generated native-slot map changes in the local install.

The package retains the previously verified bathhouse world patch and all 263
previous fixture bindings. Map syntax, safe installation layout, payload hashes
and reproducible ZIP checks pass. Version 1.0.1 has 266 identities, eight archive
members and SHA-256
`acef0b8c19e8aa1c905c8cd4c988311f9e2015e3b3f7607d824d5fb8d682830e`.
Evidence is in `tmp/torch-alignment-20261111`: `verified-fixture.json`,
`before-inputs.json`, `scene-inputs.json`, `syntax-map.json` and `installed.json`.
Diagnostic capture is cleared. A user-controlled restart is required to compile
the updated map; same-scene post-restart acceptance is recorded separately.
No addon rebuild or new runtime scanning work is introduced.

### Floor-brazier follow-up, 11 November 2026

The framed bathhouse-style floor braziers exposed a coverage gap: the initial
input set was limited to BetterCandles' version-162 template subset. The newer
brazier templates contain version-164 documents and embedded version-163 cooked
effects. The bounded reader now accepts versions 162/163/164 using the same
WolvenKit table/property layouts; static byte editing remains restricted to 162.
The effective `bathhouse_floor_brazier_complex` has a point light at local Z
3.2 m, a spot at 0.95 m, and three flame slots around Z 0.37-0.40 m with a 0.05 m
spawner offset. Native slot resolution includes their authored rotations.
All three bathhouse fixture variants and verified square/wall/Toussaint variants
are now in the public catalog. No universal Z offset or brightness change is used.

Evidence is under `tmp/light-alignment-20261111`: `braziers-index.json` (338
source occurrences), `braziers-report.json` (93 effective candidate assets),
`braziers-validation.log`, `braziers-source-checksums.json`, and the bounded
`braziers-before` native light capture. Of the indexed inputs, 166 parsed assets
passed all original header/table/chunk/nested checksum checks; 135 source-mod
assets have authored checksum mismatches, recorded without modifying them.
These read-only associations do not depend on rewriting those resources.
Unsupported format/animation/attachment cases remain excluded. The expanded
map retains every original fixture identity. After the user-controlled restart,
the user confirmed the floor braziers look better. Ready native `t18` light-buffer
copies show four matched 7 m-radius point sources moving down 2.392-2.401 m and
two matched 3.22 m-radius spot sources moving down about 0.532 m. World XY changes
are below 1.7 cm, including flame flicker; matching uses radius/type and world XY,
not array order. These are measured records, not a total scene light count.
The two-frame collection was cleared with no pending readbacks. Gameplay resumed
with the native script compiler accepting the expanded map, and the addon reports
zero lighting replacement fallbacks. See `braziers-comparison.json` and
`braziers-after-cleared.json`. Visual acceptance of every rendering mode and
every catalog fixture remains outstanding.

### Hanging-bowl particle emission origin

The next framed hanging bowl exposed a different issue: following the effect
spawner alone is insufficient when the particle resource initializes particles
away from its own origin. The `hanging_lamp` family spawns `torch_fx5.w2p` at
slot-relative Z -0.35 m. The particle's single cooked emitter initializes both
position endpoints at `(-0.01, 0, 0.10)` with zero additional `position_offset`.
Consequently the actual emission origin is `(-0.01, 0, -0.25)` relative to that
slot. The runtime map now includes this composition for all ten verified fixture
identities using that exact particle and identity spawner rotation/scale.
Native slot matrices still supply the fixture's world transform and scale.

`particle_origins.json` records the verified position and SHA-256 of the source
particle. `particle_origin()` reads the bounded constant prefix of its cooked
module data, using WolvenKit's field order and small VLQ array encoding; multiple
emitters, varying position endpoints and unsupported encodings are rejected.
It does not interpret editor graph `positionX`/`positionY` as spatial offsets.
The optional asset editor retains its original spawner-only behavior; the native
runtime map applies the particle offset after it, so the final engine position
is corrected without distributing modified particle or mesh assets.

Verification with the locally extracted input:

```powershell
python src/games/thewitcher3remastered-hartapfelfx/tests/light_alignment_particle.py '<extracted torch_fx5.w2p>'
```

Primary format sources: [cooked particle module fields](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/Types/BufferedTypes/BufferStructs/Complex/SParticleEmitterModuleData.cs),
[particle position initializer](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/Types/W3/RTTIConvert/CParticleInitializerPosition.cs),
[VLQ array reader](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/Types/Generic/Arrays/CBufferVLQInt32.cs)
and [VLQ integer encoding](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/W3ReaderExtensions.cs).
Evidence: `torch-particle.json`, `assets/torch_fx5.w2p`, `particle-origin-changes.json`
and `hanging-before-lights.json` under the same scratch evidence directory.

### Packed bathhouse bowl light

The particle-origin change did not resolve the bowl shown in the user's next
screenshot; do not describe that experiment as acceptance of this fixture.
Native captures and a stock-layer trace identify two **static sector point
lights** in `levels/novigrad/novigrad/bathhouse/lights.w2l` at the identical authored
XY `(714.008972, 2000.185913)`. One is at Z 17.345688 (radius 6 m, brightness 40),
while the lower fill is at Z 15.738350 (radius 14 m, brightness 10). The lower
source coincides with the floating volumetric hotspot. The nearby authored
`chandelier_small.w2mesh` placement is compiled separately into `entity_lights.w2l`.
These static sector lights are not gameplay entities exposed to the script sweep.

`static_lights.py` moves only the lower point onto the existing upper source,
up 1.607338 m. It updates both the sector streaming/culling position and render
block position, then recalculates the existing CR2W checksums. It preserves
power, radius, colour, flicker, usage masks, shadows, every other object and all
gameplay entities in that layer. The other unmatched static lights stay unchanged.
The exact source SHA-256 is guarded; a changed game or modified source layer is
rejected for review. The public bundle contains only this stock-derived patch,
and does not distribute the personal BetterCandles/Flares Off bundle.

The read-only sector trace covered the bathhouse layers, resolved resource hashes
through the source FNV-1a algorithm, and searched 13,754 Novigrad layers for the
specific bowl coordinates. The version-8 cooked sector wrapper is bounded by its
payload size, arrays, sorted block offsets and final chunk boundary. Internals
follow WolvenKit's [sector object index](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/Types/BufferedTypes/BufferStructs/SSectorDataObject.cs),
[transform blocks](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/Types/BufferedTypes/BufferStructs/Complex/SBlockData.cs),
[point fields](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/Types/BufferedTypes/BufferStructs/Complex/SBlockDataObjects/SBlockDataLight.cs)
and [resource hashes](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.Common/Tools/FNV1A/FNV1A64HashAlgorithm.cs).
The observed Remastered point kind is 5 with 116-byte blocks. Version-161 nested
documents encountered in stock layers are also readable; byte editing of entity
templates remains restricted to version 162, and this world patch is guarded
against the exact version-164 input.

Use `tests/light_alignment_static.py '<unpacked stock lights.w2l>' '<native candidate>'
'<optional lz4 directory>'` to verify byte preservation, both position copies,
all original photometric fields, nested checksums, source guard and bundle round trip.
The world-layer file can conflict with mods replacing that same path; a whole-file
priority override does not merge their edits. Native game acceptance is recorded
after the user-controlled restart. Evidence: `bowl-layer-candidates.json`,
`bathhouse-native-light-sources.json`, `static-bowl01/manifest.json` and the native
before/after captures in the same scratch directory.

The user confirmed the world-layer correction works after restarting. The later
volumetric geometry-leak report is a separate addon visibility issue, documented
in [local volumetric occlusion](../../fog/LOCAL_OCCLUSION.md).

The current personal installation keeps its previous customized bundle and loads
the static patch through a temporary separate `mod0000_HartapfelLightAlignmentWorld`
folder. The public ZIP combines the scripts and this world patch in a single
`mod0000_HartapfelLightAlignment` folder. When switching that personal installation
to the public package, remove both old companion folders first; unrelated lighting
mods and the addon remain separate. The public archive is self-contained.

The archive structure follows [CDPR's mod-folder rules](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/36339714/Managing+mods)
and [The Witcher 3 Mod Manager's documented installation/update behavior](https://github.com/Systemcluster/The-Witcher-3-Mod-manager).
Install, disable and uninstall use the manager's existing controls; there is no
additional settings page or rendering-mode switch for a native position fix.

## Personalized asset prototype

This content companion corrects light **positions in engine templates**. It is
the user's requested first step while full emissive lighting remains research.
Raster, hybrid RT, PT, surface shadows and HartapfelFX volumetrics all consume
the corrected native positions. No shader replacement, GPU readback or
additional lighting pass is added.

A small engine-script companion resolves the same verified flame slots for
live gameplay entities. This covers layer/instance position overrides, inherited
slots and duplicate slot names that a template-only patch cannot resolve.
It uses `CalcEntitySlotMatrix`, the entity's inverse world transform and
`CLightComponent.SetPosition`; the engine supplies the actual slot convention.
New fixtures are handled at spawn. A bounded 60 m sweep (at most 2,048
gameplay entities every five seconds) covers restored fixtures and subclasses
which omit the base spawn callback. A per-entity cache prevents repeat slot
resolution and writes. There is no per-frame scan; gameplay CPU cost remains
unmeasured. Animated bone slots and light components with separate attachments
are left unchanged until their continuous tracking is supported.

The generated content patch is already built and installed for the current
setup. The user does not need to rebuild the addon. Restarting the game loads
the corrected templates instead of the old cached resources.

## How emitters are identified

The builder reads each template's cooked fire effect, resolves its flame
particle resource and follows its spawner to the authored entity slot. It
includes the spawner's relative offset and supported parent-component
transforms. Each existing point/spot light moves to the nearest verified
emitter on that same template. A multi-flame fixture retains its light count
and power; this is position alignment, not one new light per flame.

Both the editable entity data and its nested `flatCompiledData` copy are
updated. Only the serialized XYZ floats and required checksums change.
Brightness, radius, attenuation, colour, flicker, shadow settings, light-use
masks, particle effects and gameplay interactions retain their source bytes.
This also aligns probe-only helper lights belonging to a supported fixture.
An unrelated window/fill light with no verified emitter is not moved to a
nearby candle.

The tool leaves an asset unchanged if the association or transform cannot be
verified. Examples include bone-attached sources, unresolved rotated parents,
duplicate slot identities, absent/inherited slots, unverified file versions
and non-serialized light positions. These cases are listed in the manifest.
It does not infer a source from a bright screen pixel or a global height offset.
The runtime companion can resolve several of these cases through native slots
without changing the underlying asset, with the current 337 fixture identities.

## Existing mod compatibility

The current build starts with the installed BetterCandles light-source asset
set and resolves higher-priority installed overrides before editing. That
preserves the user's active Flares Off and compatibility-patch data. Explicit
`mods.settings` priorities and disabled mods are considered; the normal
alphabetical order resolves the remaining precedence. Differing duplicates
inside one source mod stop the build rather than choosing arbitrarily.

The generated `mod0000_HartapfelLightAlignment` is a separate content mod. It
does not replace BetterCandles or any original game files. The current setup's
empty `mods.settings` uses alphabetical precedence, so this companion loads
first. If explicit priorities are used, give it a higher priority (lower
number) than its light-source inputs. Rebuild the companion after updating
those inputs; the manifest records the exact source bundle and asset hash.
Game assets are generated build inputs/outputs, not repository source files.

Enable or disable the companion through the existing mod manager and restart
the game. No extra RenoDX slider is needed for this correction. The separate
HDR addon and all existing graphics controls remain compatible.
RenoDX Preset Off controls the addon features; it does not unload this separate
content/script mod. Disable the companion and restart to restore its inputs.

## Build and verification

Use Python with `lz4` available for reading the installed compressed bundles,
and the existing W3Bundle tool from the Remastered Script Merger installation.
These are offline build tools; neither is required by the running patch.
Choose a fresh output directory for each candidate:

```powershell
python lighting/alignment/build.py --game '<game root>' --mods-settings '<profile>/mods.settings' --output '<new candidate directory>' --w3bundle '<ScriptMerger>/W3Bundle/W3Bundle.exe'
python tests/light_alignment.py '<candidate directory>' '<directory containing the lz4 Python package>'
```

Run these commands from the HartapfelFX folder, or prefix the script paths
from the repository root. `--lz4-path` optionally selects a workspace-local
Python package installation. The builder also generates the verified runtime
slot map and copies `runtime.ws` into the companion's loose script folder.
The builder accepts only the verified bundle
layouts (versions 3/5) and CR2W version 162. It bounds every property read and
checks generated paths before writing to the new candidate directory.

The verifier compares every output byte against its exact source, allowing
only the selected position floats and checksum fields. It checks nested
checksums, matching editable/compiled positions, idempotence, complete bundle
coverage and byte-exact decompression of the packaged output.

11 November 2026 candidate: **187 templates, 315 distinct light components,
630 editable/compiled transform records** corrected out of 241 inspected
effective templates. All data checks pass. Examples: `candle_med_a` moves its
light from local Z 0.31 m to its flame attachment at 0.12 m; the wax-cluster
primary light moves from Z 0.4733 m to the nearest flame at Z 0.1675 m.
The other 54 templates remain unchanged under the guards above.

Evidence: `tmp/light-alignment-20261111/candidate06/manifest.json`,
`build.log`, `validation.log`. Live game acceptance is recorded separately
after installation. Initial template-only GPU captures show corrected lights
in the scene but retained positions on some nearby candle rigs; the native
slot companion addresses those instance overrides. The addon DLL/shader build is unchanged by this content
correction, so rebuilding it is not part of this verification.

For acceptance, reload the same candle scene and check the point of origin
of the volumetric light, candle/wall shadows, flames, extinguishing/relighting
and reflections. Compare Raster, RT and PT, and check a wall torch and a
brazier. An engine template change takes effect when those resources reload;
restarting the game provides a clean comparison.

## Installed and live verification

Candidate 06 is installed in `Mods/mod0000_HartapfelLightAlignment` as a
separate content/script companion. Its asset bundle SHA-256 is
`AA033276E94AFBEA4FA7FB8A4D2796D732F9104653BF1B65A4DF20D146A88D82`.
The existing HartapfelFX addon remains
`D92455C077FA2808C472CCACEB5DFF8FC43CD59F4E783B4BDEE74CF6C2483A94`.
Existing source mods, HDR addon and user settings were preserved.

The user restarted the game after installation. The native game compiler
accepted the scripts and gameplay resumed. Two-frame `9A6F318E` input captures
before and after the runtime addition contain ready `t18` light-buffer copies.
The nearby 1.8 m-radius candle light changes from approximately
`(54.4207, 6.5405, 3.9030)` to `(54.4447, 6.5586, 3.2902)`: about 0.61 m lower.
Its associated spot source is at `(54.4440, 6.5597, 3.2899)`, within about
1.4 mm, including the sources' small flicker displacement. Another nearby
1.5 m-radius source moves about 0.83 m to its emitter. Several stationary
fill-type records remain unchanged. Runtime lighting logs report zero replacement
fallbacks after the addition.

The camera and light-buffer ordering differ across launches; comparison uses
world positions and matching radius/type near each rig, not identical array
indices or pixel differences. The light-count constant-buffer copy had an
untracked-write gap, so the captures are not an authoritative total light
count. No numerical visual-quality or gameplay frame-time claim is made.
Raster/RT/PT share these engine positions; separate visual acceptance in all
three modes and additional locations remains outstanding.

Evidence: `after-inputs.json` (template-only), `runtime-inputs.json`,
`runtime-comparison.json`, `installed-runtime.json` and the syntax/data check
results under `tmp/light-alignment-20261111`. The optional offline parser
accepts the generated map and normalized function bodies but does not support
Remastered annotations; the actual restarted game supplies the annotation/API
compilation check. Diagnostic input collection is stopped after verification.

## Proven source material

- [CD PROJEKT RED: adding light sources](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/53772302/HOW-TO%2BAdd%2Blight%2Bsources): the light component and flame effect have separate authored positions; flame spawners attach to entity slots.
- [WolvenKit bundle reader](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.Bundles/Bundle.cs): the legacy bundle index and compressed asset payloads. Version 5's 304-byte records were additionally verified against installed assets and decompression boundaries.
- [WolvenKit CR2W reader/writer](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/CR2W/CR2WFile.cs): property boundaries, embedded chunks and checksum construction.
- [WolvenKit EngineTransform](https://github.com/WolvenKit/WolvenKit-7/blob/main/WolvenKit.CR2W/Types/Structs/Complex/EngineTransform.cs): independently flagged translation, rotation and scale fields.
- [CDPR script entity API](https://github.com/CDPR-Modding-Documentation/Witcher3-Scripts/blob/main/engine/entity.ws) and [component API](https://github.com/CDPR-Modding-Documentation/Witcher3-Scripts/blob/main/engine/components.ws): native slot-matrix resolution and position updates. Current installed declarations and the existing working annotation hooks were checked before use.
- The effective installed templates provide the actual flame-slot/spawner relationships and measured position corrections. They are the source of the asset-specific values, rather than an assumed universal candle offset.
