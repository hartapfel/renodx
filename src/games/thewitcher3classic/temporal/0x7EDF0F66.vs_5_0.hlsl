// Native SpeedTree deformation evaluated at current and previous state.
#define main EvaluateFoliageCurrent
#include "./0x7EDF0F66.native.hlsli"
#undef main

#define FOLIAGE_PREVIOUS_DECL
#define main EvaluateFoliagePrevious
#define b0 b4
#define b1 b5
#define b2 b6
#define b3 b7
#define b11 b9
#define BaseTreeCB previous_BaseTreeCB
#define FrameCB previous_FrameCB
#define MaterialCB previous_MaterialCB
#define WindDynamicsCB previous_WindDynamicsCB
#define m_amLightModelViewProjs previous_m_amLightModelViewProjs
#define m_avBillboardTexCoords previous_m_avBillboardTexCoords
#define m_avEffectConfigFlags previous_m_avEffectConfigFlags
#define m_avShadowSmoothingTable previous_m_avShadowSmoothingTable
#define m_avWindConfigFlags previous_m_avWindConfigFlags
#define m_avWindLodFlags previous_m_avWindLodFlags
#define m_f3dGrassRange previous_m_f3dGrassRange
#define m_f3dGrassStartDist previous_m_f3dGrassStartDist
#define m_f3dLodHighDetailDist previous_m_f3dLodHighDetailDist
#define m_f3dLodRange previous_m_f3dLodRange
#define m_fAdherence previous_m_fAdherence
#define m_fAlphaScalar previous_m_fAlphaScalar
#define m_fAmbientImageScalar previous_m_fAmbientImageScalar
#define m_fBillboardHorzFade previous_m_fBillboardHorzFade
#define m_fBillboardRange previous_m_fBillboardRange
#define m_fBillboardStartDist previous_m_fBillboardStartDist
#define m_fBranchFieldMin previous_m_fBranchFieldMin
#define m_fBranchLightingAdjust previous_m_fBranchLightingAdjust
#define m_fBranchSeamWeight previous_m_fBranchSeamWeight
#define m_fBranchVerticalOffset previous_m_fBranchVerticalOffset
#define m_fDirectionAdherence previous_m_fDirectionAdherence
#define m_fDistance previous_m_fDistance
#define m_fFadeInverseDistance previous_m_fFadeInverseDistance
#define m_fFadeStartPercent previous_m_fFadeStartPercent
#define m_fFarClip previous_m_fFarClip
#define m_fHeight previous_m_fHeight
#define m_fHeightExponent previous_m_fHeightExponent
#define m_fHueVariationByPos previous_m_fHueVariationByPos
#define m_fHueVariationByVertex previous_m_fHueVariationByVertex
#define m_fLeafRippleMin previous_m_fLeafRippleMin
#define m_fLeafTumbleMin previous_m_fLeafTumbleMin
#define m_fLeewardScalar previous_m_fLeewardScalar
#define m_fLightingScalar previous_m_fLightingScalar
#define m_fNoisePeriod previous_m_fNoisePeriod
#define m_fNoiseSize previous_m_fNoiseSize
#define m_fNoiseTurbulence previous_m_fNoiseTurbulence
#define m_fNoiseTwist previous_m_fNoiseTwist
#define m_fNumBillboards previous_m_fNumBillboards
#define m_fOneMinusAmbientContrastFactor previous_m_fOneMinusAmbientContrastFactor
#define m_fOneMinusBillboardHorzFade previous_m_fOneMinusBillboardHorzFade
#define m_fRadiansPerImage previous_m_fRadiansPerImage
#define m_fRippleDistance previous_m_fRippleDistance
#define m_fRippleTime previous_m_fRippleTime
#define m_fShadowMapWritingActive previous_m_fShadowMapWritingActive
#define m_fShininess previous_m_fShininess
#define m_fStrength previous_m_fStrength
#define m_fTerrainAmbientOcclusion previous_m_fTerrainAmbientOcclusion
#define m_fTile previous_m_fTile
#define m_fTime previous_m_fTime
#define m_fTransmissionShadowBrightness previous_m_fTransmissionShadowBrightness
#define m_fTransmissionViewDependency previous_m_fTransmissionViewDependency
#define m_fTumbleDirectionAdherence previous_m_fTumbleDirectionAdherence
#define m_fTumbleFlip previous_m_fTumbleFlip
#define m_fTumbleTime previous_m_fTumbleTime
#define m_fTumbleTwist previous_m_fTumbleTwist
#define m_fTurbulence previous_m_fTurbulence
#define m_fTwitch previous_m_fTwitch
#define m_fTwitchFreqScale previous_m_fTwitchFreqScale
#define m_fTwitchSharpness previous_m_fTwitchSharpness
#define m_fTwitchThrow previous_m_fTwitchThrow
#define m_fTwitchTime previous_m_fTwitchTime
#define m_fWallTime previous_m_fWallTime
#define m_fWhip previous_m_fWhip
#define m_mCameraFacingMatrix previous_m_mCameraFacingMatrix
#define m_mModelViewProj2d previous_m_mModelViewProj2d
#define m_mModelViewProj3d previous_m_mModelViewProj3d
#define m_mProjectionInverse3d previous_m_mProjectionInverse3d
#define m_sBranch1 previous_m_sBranch1
#define m_sBranch2 previous_m_sBranch2
#define m_sFrondRipple previous_m_sFrondRipple
#define m_sGlobal previous_m_sGlobal
#define m_sLeaf1 previous_m_sLeaf1
#define m_sLeaf2 previous_m_sLeaf2
#define m_sRolling previous_m_sRolling
#define m_sShadows previous_m_sShadows
#define m_vAmbient previous_m_vAmbient
#define m_vAmbientColor previous_m_vAmbientColor
#define m_vAnchor previous_m_vAnchor
#define m_vCameraDirection previous_m_vCameraDirection
#define m_vCameraPosition previous_m_vCameraPosition
#define m_vDiffuse previous_m_vDiffuse
#define m_vDiffuseColor previous_m_vDiffuseColor
#define m_vDir previous_m_vDir
#define m_vDirLight previous_m_vDirLight
#define m_vDirection previous_m_vDirection
#define m_vHueVariationColor previous_m_vHueVariationColor
#define m_vLavaCustomBaseTreeParams previous_m_vLavaCustomBaseTreeParams
#define m_vLavaCustomMaterialParams previous_m_vLavaCustomMaterialParams
#define m_vLodRefPosition previous_m_vLodRefPosition
#define m_vOffset previous_m_vOffset
#define m_vShadowMapRanges previous_m_vShadowMapRanges
#define m_vShadowMapTexelOffset previous_m_vShadowMapTexelOffset
#define m_vSpecular previous_m_vSpecular
#define m_vSpecularColor previous_m_vSpecularColor
#define m_vTransmission previous_m_vTransmission
#define m_vTransmissionColor previous_m_vTransmissionColor
#define m_vViewport previous_m_vViewport
#define m_vViewportInverse previous_m_vViewportInverse
#include "./0x7EDF0F66.native.hlsli"
#undef b0
#undef b1
#undef b2
#undef b3
#undef b11
#undef BaseTreeCB
#undef FrameCB
#undef MaterialCB
#undef WindDynamicsCB
#undef m_amLightModelViewProjs
#undef m_avBillboardTexCoords
#undef m_avEffectConfigFlags
#undef m_avShadowSmoothingTable
#undef m_avWindConfigFlags
#undef m_avWindLodFlags
#undef m_f3dGrassRange
#undef m_f3dGrassStartDist
#undef m_f3dLodHighDetailDist
#undef m_f3dLodRange
#undef m_fAdherence
#undef m_fAlphaScalar
#undef m_fAmbientImageScalar
#undef m_fBillboardHorzFade
#undef m_fBillboardRange
#undef m_fBillboardStartDist
#undef m_fBranchFieldMin
#undef m_fBranchLightingAdjust
#undef m_fBranchSeamWeight
#undef m_fBranchVerticalOffset
#undef m_fDirectionAdherence
#undef m_fDistance
#undef m_fFadeInverseDistance
#undef m_fFadeStartPercent
#undef m_fFarClip
#undef m_fHeight
#undef m_fHeightExponent
#undef m_fHueVariationByPos
#undef m_fHueVariationByVertex
#undef m_fLeafRippleMin
#undef m_fLeafTumbleMin
#undef m_fLeewardScalar
#undef m_fLightingScalar
#undef m_fNoisePeriod
#undef m_fNoiseSize
#undef m_fNoiseTurbulence
#undef m_fNoiseTwist
#undef m_fNumBillboards
#undef m_fOneMinusAmbientContrastFactor
#undef m_fOneMinusBillboardHorzFade
#undef m_fRadiansPerImage
#undef m_fRippleDistance
#undef m_fRippleTime
#undef m_fShadowMapWritingActive
#undef m_fShininess
#undef m_fStrength
#undef m_fTerrainAmbientOcclusion
#undef m_fTile
#undef m_fTime
#undef m_fTransmissionShadowBrightness
#undef m_fTransmissionViewDependency
#undef m_fTumbleDirectionAdherence
#undef m_fTumbleFlip
#undef m_fTumbleTime
#undef m_fTumbleTwist
#undef m_fTurbulence
#undef m_fTwitch
#undef m_fTwitchFreqScale
#undef m_fTwitchSharpness
#undef m_fTwitchThrow
#undef m_fTwitchTime
#undef m_fWallTime
#undef m_fWhip
#undef m_mCameraFacingMatrix
#undef m_mModelViewProj2d
#undef m_mModelViewProj3d
#undef m_mProjectionInverse3d
#undef m_sBranch1
#undef m_sBranch2
#undef m_sFrondRipple
#undef m_sGlobal
#undef m_sLeaf1
#undef m_sLeaf2
#undef m_sRolling
#undef m_sShadows
#undef m_vAmbient
#undef m_vAmbientColor
#undef m_vAnchor
#undef m_vCameraDirection
#undef m_vCameraPosition
#undef m_vDiffuse
#undef m_vDiffuseColor
#undef m_vDir
#undef m_vDirLight
#undef m_vDirection
#undef m_vHueVariationColor
#undef m_vLavaCustomBaseTreeParams
#undef m_vLavaCustomMaterialParams
#undef m_vLodRefPosition
#undef m_vOffset
#undef m_vShadowMapRanges
#undef m_vShadowMapTexelOffset
#undef m_vSpecular
#undef m_vSpecularColor
#undef m_vTransmission
#undef m_vTransmissionColor
#undef m_vViewport
#undef m_vViewportInverse
#undef main
#undef FOLIAGE_PREVIOUS_DECL

cbuffer FoliageHistory : register(b8) { uint foliage_history; }
cbuffer FoliagePreviousFrame : register(b10) { float4 foliage_previous_frame[269]; }

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : POSITION0,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD7,
  float4 v9 : TEXCOORD8,
  out float4 o0 : SV_POSITION0,
  out float4 o1 : TEXCOORD0,
  out float4 o2 : TEXCOORD1,
  out float3 o3 : TEXCOORD2,
  out float3 o4 : TEXCOORD3,
  out float4 o5 : TEXCOORD4,
  out float4 o6 : TEXCOORD5,
  out float4 o7 : TEXCOORD6,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  EvaluateFoliageCurrent(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, o0, o1, o2, o3, o4, o5, o6, o7);
  motion_history = foliage_history;
  previous_clip = float4(0, 0, 0, -1);
  if (foliage_history != 0) {
    float4 previous_o0;
    float4 previous_o1;
    float4 previous_o2;
    float3 previous_o3;
    float3 previous_o4;
    float4 previous_o5;
    float4 previous_o6;
    float4 previous_o7;
    EvaluateFoliagePrevious(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, previous_o0, previous_o1, previous_o2, previous_o3, previous_o4, previous_o5, previous_o6, previous_o7);
    previous_clip = previous_o0;
    previous_clip.xy -= foliage_previous_frame[15].xy * previous_clip.w;
  }
}
