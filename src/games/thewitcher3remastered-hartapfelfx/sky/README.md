# Celestial sky

The two captured sky families (`449D3390` and Toussaint `3B15DAAB`) share
`celestial.hlsli`. Enhanced skies replace the painted celestial cubemaps instead
of filtering their stars and highlights into coarse, glowing blobs. Native
weather colours, terrain depth, fog and exposure remain. The azimuth-only lunar
horizon hotspot is replaced by a glow centred on the visible Moon.

The main sky draws filtered stars. Its existing cloud composite then adds the
Sun and Moon **after** integrating direct-beam extinction. A post-draw callback
runs that composite immediately after the native sky, including clear weather
where the engine omits cloud cards. Subsequent native cloud cards are suppressed
for that exact target and viewport. Both captured Moon draws (`E446F231` and
Toussaint `6D5A1EC2`) and the `E46451D5` Sun mesh are suppressed only when their
enhanced view is available. Reflection faces render the same sources in their
sky and retain the existing environment-cloud transmission during conversion.

`A0A02407`, previously classified as a Sun draw, is a `Texture2D.Load` screen
copy with no lighting inputs. It remains untouched and is no longer used to
measure solar radiance. This and the painted-highlight removal address known
sources of unwanted sky glow; final identification of the screenshot's exact
spot still requires an in-game comparison of this build.

Sun Size and Moon Size retain their existing sliders and saved percentages.
Their 100% reference now comes from each native draw's vertex constants, not
the previous fixed 3.63/14.3-degree diameters. The original vertex shaders
unpack positions with `world * (unorm_position * extent + minimum)`; the addon
projects that authored bound onto the camera plane and derives its angular
radius from the native camera distance. The Sun's original `N.V > .5` support
contributes its geometric `sqrt(3)/2` projected footprint. This is a native
shader rule, not an enlargement factor. Pixel/vertex visibility distinguishes
their different b2 buffers; the compatible b3 alias is also accepted.
The renderer uses `sin(native_angle) * slider`, matching linear mesh scaling.
The authored 75% Moon setting remains 75%; 100% selects its native reference.
Centres still use the game's visible vectors (`b12[204/205]`). Until geometry
for a potentially visible emitter is observed, the original celestial pipeline
is retained. A body far below the horizon does not hold up a night/day load.

**Lighting > Sun & Moon Appearance > Sun Glow Size** independently scales the
glow from 25% to 400%, with a 125% default (25% wider than its 100% reference).
Sun Size still scales the body and entire glow together. Existing profiles keep
their Sun/Moon sizes; the new control gets its own default and belongs to the
Lighting reset. Nights/Clouds resets do not change it. No tab or preset was added.

The Sun retains linear limb darkening, a 12%-radius soft rim, and a 55% body /
45% radius-relative Gaussian core profile. Glow overlaps the body and rim before
cloud extinction. Its outer shoulder now uses the **native sky's solar lobe**,
`pow(saturate(dot(view,sun)), b12[204].x)`, evaluated at the scaled angular
separation. The native exponent's weather/time curve supplies the original
sunrise/sunset broadening. A fourth-order outer falloff prevents a flat bright
halo ending in another visible circle after exposure. A short, smooth afterglow
ends about 2.6 degrees below the horizon. All of this is an analytic scene-unit
approximation over the existing sky, not an additional spectral atmosphere LUT.
Per-pixel horizon visibility retains the upper limb after the centre sets.

Sun colours and glow colours are separate native inputs. `E46451D5` computes
`pow(max(L * normalize(L) / dot(L,scalar) * material0,0),2.2) * material2.rgb *
material2.a`, where `L = b0[10].rgb`, `material0 = b2[0].rgb`, `material2 = b2[2]`
and `scalar = saturate(b4[0].x)`. After normalization, its achromatic denominator,
height and fog factors cancel. The Sun callback therefore samples the CPU-visible
native GlobalCB colour (16 bytes) and material (48 bytes), evaluates the equivalent
normalized HDR colour, and caches it for the following sky recording. The native
material tint is applied **after** the gamma power, as in the original shader.
This material cache is the fallback when the shared linear emitter colour below
is unavailable; before a material is available it uses the normalized solar sky
colour. The GPU-only `b4` divisor was not reliably captured (DevKit rejected the
submission-end aliased allocation); its absolute native disc luminance is not
claimed. The established 160..800 scene-unit body calibration remains, with
achromatic low-Sun attenuation. These scalar choices preserve the native RGB
ratios while keeping direct-beam visibility readable in the engine's FP16 range.

The surrounding solar shoulder uses native linear `b12[199].rgb`, the sky gain
`b12[203].x*y`, native solar strength `saturate(b12[206].x)`, and the original
sky-material exposure branch: multiply by `b12[203].w` when `b2[0].y == 1`.
Main/reflection material flags are captured for the composite. Native weather
and sunrise/sunset curves now supply the colour, including warm low-Sun looks;
there is no fixed warm RGB tint or second wavelength-dependent filter on top.
The overlapping core uses the matching emitter colour. Sources stay
in linear HDR scene units until the existing exposure/bloom/tonemap pipeline.

Moon colour and brightness retain the previous native matching: standard
`E446F231` uses `b2[0].rgb * b2[2].rgb * b2[2].a`; Toussaint `6D5A1EC2` uses
`b12[277].rgb * b2[2].rgb * b2[2].a`. The Moon callback samples 48 bytes only
from CPU-visible upload memory, validates the vertex pair and finite values,
and retains a separate material for each family. Unavailable/first-frame
materials fall back to `b12[277]`. NASA terrain and regolith reflectance remain,
normalized to vanilla Lambert's 2/3 full-disc mean for a uniform albedo; exact
per-pixel equality to the original painted material is not intended. Moon
Brightness, native fog/cloud extinction and the centred glow remain.

Both original Moon pixel shaders use an independent clock-driven lighting
vector: `theta = 2*pi * (b0[0].y * 0.033863864839076996 + b0[0].w)`, followed by
`(cos(theta), sin(theta), 0)`. The enhanced Moon now uses that same **world-space**
vector for its spherical surface normals, phase/earthshine and glow. It no longer
infers the phase from sky-dome positions that may remain fixed. Advancing game
days cycles the phase at the native approximately 29.53-day rate; the daily
clock term follows the native rotation convention. Waxing and waning illuminate
opposite sides in the same world coordinates. This follows the game's phase
convention rather than imposing an independently timed astronomical Moon. The
native GlobalCB is already available to both sky families; the composite uses
its validated native/captured cloud clock, including all four first-row values.
Night sky-air lighting remains aligned to the visible Moon without moving it.

Stars keep the deterministic spherical shell, magnitude-to-flux scaling,
warm/cool colours, footprint-normalized Gaussian filtering, and existing
atmospheric/cloud/horizon/twilight attenuation. The scene-unit base is now **1.6
instead of 0.2 (8 times brighter)**. The existing Star Brightness default and
saved percentage remain unchanged at 100%/their saved value; zero still hides
stars. The increase happens in linear HDR source radiance, before exposure and
tone mapping. A direct GPU comparison to the preceding production feature
shader verifies the 8x ratio at the same ray, footprint, atmosphere and slider.
**Nights > Night Atmosphere > Star Brightness** retains its current ownership.

## Shared emitter colour and cloud illumination

`emission.hpp` observes the unmodified native directional-light colour, native
solar sky palette and family-specific Moon material. During low-Sun conditions
the authored warm solar palette supplies the common colour; daytime blue sky
halos are not used to tint the Sun. A continuous twilight blend selects the
solar/lunar colour for native directional lighting. The visible enhanced body,
its glow and cloud direct scattering consume the same cached colour ratios.

The existing native view builder, direct constants builder and GlobalCB builder
apply that spectrum to their directional RGB values while preserving Rec.709
luminance and alpha. This covers the established Raster/RT/PT consumers,
reflections and volumetric fog without recolouring torch/light buffers or a
finished image. Night intensity controls still operate independently. The
common constants' row10 is a matrix and is deliberately never recoloured.
Fresh native values are observed before editing, so repeated frames cannot
feed the tint back into itself. Preset Off and Original Clouds disable this
coupling. This preserves the native illumination calibration; it does not
claim absolute photometric equality between the stylized visible disc and
world light, or replace the engine's atmosphere with a spectral solver.

Cloud lighting now considers the spherical horizon at the top of the cloud
layer, rather than switching to moonlight as soon as the ground Sun sets.
Each occupied ray sample tests the local planetary horizon, so the lower
cloud cannot receive sunlight through the planet. Terrain shadow direction
selection retains its established ground horizon. The existing hemisphere
sky reduction also integrates the narrow native solar/lunar `cos^p` aureole
analytically (`2*pi/(p+1)` solid angle), avoiding noisy or missed sunset colour
from sparse samples. The lunar term follows native phase; source-size styling
does not alter this irradiance integral. No extra ray, pass or texture is added.

These choices follow the source/transport separation in [PBRT radiometry](https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Radiometry)
and the integrated sky, atmosphere and cloud approach in [Hillaire 2020](https://doi.org/10.1111/cgf.14050).
The use of native palettes and luminance preservation is a game-specific
adaptation of those principles, not a method directly prescribed by either source.

No GPU readback, queue wait or additional pass/texture is needed for native
material/geometry sampling. The existing per-sky upload stores Moon material at byte64,
Sun colour at80, glow size at96, native exposure flag at100, native radii at112,
and solar/lunar spectra at128/144. The composite's
existing private settings page carries the same fields (page base256). The
C++ `ShaderInjectData` remains48 bytes and cloud `Parameters` remains256 bytes.
Cloud Rendering Original / Preset Off retains the native celestial pipeline.

The ten-level 512x256 R8 Moon map occupies 174,768 bytes per cloud view, plus one
immutable upload per device. It uses the existing shared raw buffer and root
bindings. The 256-byte cloud parameter block uses its previously spare final
16 bytes; the fog page still starts at 256. A 256-byte per-sky upload extends
the existing private settings CBV with a main-view flag at byte 48, without
changing native constants or adding a root parameter. Moon map sampling is
limited to its disc, stars skip daylight and empty correction regions, and
direct-beam marching is limited to disc pixels. The broad aureoles use each
pixel's existing cloud optical column. A conservative four-tap read of the
current trace (existing texture, private SRV14) and temporal transmission also
bounds disc visibility, preventing a high-resolution beam from punching through
a cloud already visible in either representation. This adds no texture allocation
or broad-halo density march. Main views that cannot composite fall back to the
native sky/discs instead of drawing enhanced emitters over later native clouds.
Enhanced main views skip
the old scene-before-emitter copy. No additional production full-screen pass
or new quality preset is needed for these sources.

Research references:

- [Sucker Punch, Rendering the World of Ghost of Tsushima (SIGGRAPH 2021)](https://www.advances.realtimerendering.com/s2021/jpatry_advances2021/index.html): production context for consistent sky/atmosphere, celestial sources and clouds.
- [PBRT, Distant Lights](https://www.pbr-book.org/4ed/Light_Sources/Distant_Lights): angular sources and consistent radiance/illumination distinctions.
- [Kasten & Young, revised optical air mass (1989)](https://doi.org/10.1364/AO.28.004735): finite near-horizon optical path approximation.
- [Cambridge, stellar atmospheres lecture](https://people.ast.cam.ac.uk/~pettini/Stellar%20Structure%20Evolution/Lecture05.pdf): solar limb darkening; the inexpensive linear model is used here.
- [NASA, Moon phases](https://science.nasa.gov/moon/moon-phases/), [USNO, phase geometry](https://aa.usno.navy.mil/faq/moon_phases): continuous waxing/waning and opposite illuminated sides. The game-specific phase vector above preserves vanilla's convention.
- [NASA lunar photometry reference](https://ntrs.nasa.gov/api/citations/19700001570/downloads/19700001570.pdf): particulate lunar reflectance, motivating Lommel-Seeliger instead of a shiny sphere.
- [NASA CGI Moon Kit](https://svs.gsfc.nasa.gov/4720/): LRO/LROC global colour map; provenance below.
- [ESO, stellar magnitudes](https://www.eso.org/~hboffin/Teaching/CMD.html): logarithmic magnitude/flux relationship.
- [Hillaire, A Scalable and Production Ready Sky and Atmosphere Rendering Technique (2020)](https://onlinelibrary.wiley.com/doi/full/10.1111/cgf.14050): separates direct sources from atmospheric scattering and transmission in a production rendering pipeline.
- [NVIDIA GPU Gems 2, atmospheric scattering](https://developer.nvidia.com/gpugems/gpugems2/part-ii-shading-lighting-and-shadows/chapter-16-accurate-atmospheric-scattering): aerosol forward scattering produces the soft halo surrounding the Sun.
- [Epic, Sky Atmosphere](https://dev.epicgames.com/documentation/en-us/unreal-engine/sky-atmosphere?application_version=4.27): source-direction alignment, Mie halos and haze in a production sky.
- [PBRT, phase functions](https://www.pbr-book.org/3ed-2018/Volume_Scattering/Phase_Functions): normalized HG functions and mixtures for more complex directional scattering. The finite-source width used here is an inexpensive approximation, not full angular convolution or a spectral Mie solver.
- [DeVore et al., solar aureole measurements](https://journals.ametsoc.org/view/journals/atot/26/12/2009jtecha1289_1.xml): observed near-forward cloud scattering varies with particle size and optical thickness; an aureole should not be an unoccluded bloom sprite.
- [Bruneton, atmosphere reference implementation](https://ebruneton.github.io/precomputed_atmospheric_scattering/atmosphere/functions.glsl): wavelength-dependent transmission, separate solar/sky radiance and the geometry of illuminated atmosphere near the horizon.
- [Met Office, blue skies and red sunsets](https://weather.metoffice.gov.uk/learn-about/weather/optical-effects/why-is-the-sky-blue): longer low-Sun paths preferentially remove blue light. The fitted local aureole complements the game's existing sunset sky colours.
- [PBRT, radiometry](https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Radiometry): linear source radiance and scalar transmission precede exposure/tone mapping; the stellar base increase is measured in that linear domain.

Asset provenance: NASA/GSFC Scientific Visualization Studio, CGI Moon Kit 2019,
LRO/LROC. Source `lroc_color_poles_2k.tif`, SHA256
`13b797422e8c4b8607ff2b2623ac3a046a6da0132d567c2d272d92fad7052c4a`.
The source RGB TIFF was resized with Lanczos to 512x256, converted using an
approximate gamma-2.2 RGB-to-linear luminance, then box-filtered in linear light
and quantized to R8 for all ten mip levels. Each level is padded to four bytes.
`moon_albedo.hpp` embeds the resulting immutable data and mean value; no files
are downloaded at runtime. Reproduction script/source are retained in workspace
scratch under `tmp/hartapfelfx-validation/prepare-moon-albedo.py`.

Validation: run the mod's `build-release.ps1 -CompileOnly`, then its isolated
`tests/startup.ps1` with original shaders and the HDR addon in both load orders.
The cloud GPU host covers limb darkening, sizes, phases, atmospheric extinction,
Moon brightness, stellar flux filtering/daylight/zero, published mip storage,
and actual FP16/FP32 clear/opaque source compositing. Further regressions cover
centred/symmetric aureoles, night light alignment, enlarged angular sizes,
complete Sun/glow slider scaling, grazing-path warming/afterglow, the visible
upper limb after centre-set, bounded outer-halo contrast and both native Moon
material colour/intensity products through the actual FP16 composite,
native Sun material/sky-glow palette separation, main/reflection exposure,
weather solar-strength zero, opposite native phase directions and month
cycling at fixed sky positions. `clouds-gpu.exe <shader-directory>
reference-stars <previous-cloud-features.cso>` additionally compares the actual
GPU stellar radiance at unchanged 100% brightness; the preceding 0.2-base shader
must produce one eighth of the new value. Menu integration verifies 125% glow
defaults, tab/reset ownership and saved Star Brightness parsing. The host also covers
current-opaque/temporally-transparent cloud silhouettes, and default stellar
contrast through BOTH actual native sky pixel shaders using captured night/haze
constants. These render real pixels rather than relying only on zero-vertex
linkage or helper probes. Runtime fixtures also include
both native sky families with no following disc/card draws, split command lists,
foreign cameras, photo-mode local lights, and the native DXR libraries. Gameplay
acceptance remains: Toussaint and a base region, clear/rainy/stormy day/night, sunrise,
Moon silhouettes through clouds, Star Brightness zero/100/200, photo mode,
travel/meditation, Original and Preset Off. The user controls game restarts.

8 November coherent-lighting validation adds production-marcher solar/lunar
colour replays at fixed geometry/time, native-luminance preservation through
FP16 storage, actual engine-hook RGB/alpha/Off checks, native mesh size/distance
checks, light-rain protection and early/paused rain transitions. The Release
suite passes 337 cloud GPU cases and 17 celestial render captures. Additional
coherent sunset/night FP16 captures and the standalone menu/profile integration
pass. Both HDR load orders pass actual-addon sky/cloud/fog/local-light/DXR tests
without DevKit. These are offline regressions, not live gameplay acceptance or
a gameplay performance measurement.
