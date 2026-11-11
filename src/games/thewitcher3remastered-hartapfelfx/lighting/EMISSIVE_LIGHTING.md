# Emissive local lighting investigation

11 November 2026. **Research only; no replacement lighting is implemented or
installed by this investigation.** The installed Small Object Shadows fix is
separate.

## Requested result

Replace candle, torch and similar proxy illumination with lighting driven by
the actual emitters. Remove unrelated authored fill illumination after its
identity is established. The user requires **Raster, hybrid RT and PT**.
Moving existing lights onto their emitters is a backup, not the primary design.

The user subsequently requested that alignment as the first implementation
step. The separate [alignment content companion](alignment/README.md) records
that work; it does not implement or replace the all-mode emissive goal here.

An emissive-looking flame, bloom, or a relocated point light does not by itself
meet this request. The emitter must illuminate other surfaces, respect
occlusion, affect reflections and indirect lighting, and feed atmospheric
scattering consistently. A window can admit real exterior illumination;
removing an artificial fill must preserve that transport.

## Verified boundaries

| Evidence | What it establishes | What it does not establish |
| --- | --- | --- |
| Installed engine script declaration `engine/CLightComponent.ws` | Light components expose enabled state, brightness, radius, shadow mode, color and flicker. | No sampled mesh-emitter registration API is exposed by this declaration. |
| Installed `modBetterCandles` scripts | Existing content can enumerate entities and their light components. They also modify candle/fire light rigs. | Their classifications are not a verified registry of emitting surfaces for this addon. |
| Installed `modNativeBridge` imports | The installed script bridge exposes API-version and string-to-name functions. | This is not an emitter enumeration, material editing or renderer registration interface. |
| One-frame native `9A6F318E` input capture | A local-light SRV at `t18`, space 0, was copied with ready status, along with ready frame constants. The existing decoded 160-byte light layout applies. | The copied prefix is not the active light count. The light constant buffer was rejected due to an untracked/aliased write, so its count is not usable. No particular record has been identified as the screenshot's window light. |
| Native PT library `47BC87E1` | The current and previous captured libraries have identical SHA-256. Its ABI includes the separate native `lightsPT` and packed-light buffers. | Having PT and editable DXR libraries does not prove that flame particles are ray-visible emitters or registered with a mesh-light sampler. |

The current game reports version `5.0.16.41566`. Existing BetterCandles,
DarkerDungeons and TurnOnTheLights installations must be considered when
attributing a scene's light to the base game. They were inspected read-only;
their files and settings were not altered.

No editor/cooker executable was found in the game installation, on the command
path, or in the inspected managed Remastered modding tools. Compatibility of
the older documented REDkit asset workflow with this game version remains
unverified. This is a tooling finding, not proof that native integration is
impossible.

## Source-backed design requirements

[CD PROJEKT RED's light-source tutorial](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/53772302/HOW-TO%2BAdd%2Blight%2Bsources)
authors a candle using separate light, interaction, material-effect and flame
particle components. A conversion therefore needs to preserve the connection
between emission and the candle's lit state; changing a material's appearance
alone cannot be assumed to replace its lighting component.

[PBRT's area-light model](https://pbr-book.org/4ed/Light_Sources/Area_Lights)
ties emission to shape, radiance, orientation and opacity, with matching
sampling probabilities. Use one physical emitter description rather than
unrelated per-mode intensity guesses.

[NVIDIA's mesh-light integration](https://github.com/NVIDIA-RTX/RTXDI/blob/main/Doc/Integration.md)
requires extracting emissive geometry and materials, preparing light records
and maintaining temporal correspondence. This is reference architecture;
**RTXDI use by this particular Witcher renderer has not been established**.
[NVIDIA's next-event-estimation explanation](https://developer.nvidia.com/blog/conquering-noisy-images-in-ray-tracing-with-next-event-estimation/)
explains why relying on incidental ray hits on tiny bright sources produces
noise that denoising alone cannot resolve.

For Raster, [Heitz et al.'s polygonal-light shading](https://eheitzresearch.wordpress.com/415-2/)
provides a proven real-time area-light evaluation approach. It addresses the
BRDF integral, not scene visibility or global illumination. Raster still needs
an occlusion and indirect-lighting solution; merely adding LTC evaluation
would be an incomplete implementation.

## Required implementation boundaries

1. Establish stable emitter identity, world geometry/transform, emitted
   radiance, opacity and lit/animation state through verified native or content
   interfaces. Include emitters outside the camera view and streamed entities.
2. Establish which native analytic lights are associated with each emitter,
   and separately identify artistic fill lights. GPU buffer indices, radius,
   color, or nearest-bright-pixel guesses are not stable identities.
3. Feed the shared emitter description into each renderer: sampled direct and
   indirect transport for PT; the hybrid RT shading/GI paths; and area-light
   evaluation, visibility and indirect lighting for Raster. Preserve native
   denoiser inputs, hair, water and transparent material contracts.
4. Replace proxy energy exactly once across direct light, bounced light,
   reflections and atmospheric volumes. Remove only the identified proxy/fill
   contribution; do not add mesh emission on top of the same analytic energy.
5. Complete and measure all three backends before exposing a user-facing mode.
   Keep settings in the existing Lighting tab and retain the current controls
   until a functioning replacement makes new controls meaningful.

The current addon has no verified emitter registry or complete backend for
this feature. Do not add an apparent working toggle, globally zero local-light
buffers, or advertise all-mode emissive lighting before these boundaries are
implemented and validated.

## First acceptance gate

Use one candle with its associated proxy isolated in a controlled scene.
Demonstrate emitter-driven illumination with the proxy contribution absent,
then verify an occluder, an off-screen emitter, diffuse bounce, specular
reflection, extinguishing/relighting and flicker. Repeat in Raster, RT and PT,
including fog/light combinations and the separate HDR addon. Capture the same
view before/after and measure GPU time and resource costs. Expand to torches,
braziers, fireplaces, moving lights and scene fills only after this gate passes.

Diagnostic evidence is under `tmp/local-emitter-research-20261111`. The
single-frame shader-input collection was stopped and has no pending readbacks.
No new DXR collection was started; the pre-existing startup DXR observer was
left in its original state. Diagnostic GPU readbacks are not a production design.
