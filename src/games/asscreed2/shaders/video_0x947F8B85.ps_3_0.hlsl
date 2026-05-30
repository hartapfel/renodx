#include ".././common.hlsli"

float4 consts;
sampler2D tex0;

float4 main(float2 texcoord : TEXCOORD) : COLOR
{
	float4 o;

	float4 r0;
	r0 = tex2D(tex0, texcoord.xy);

        float3 video_rgb = r0.xyz;
        if (CUSTOM_VIDEO_HDR == 1.f) {
          const float safe_peak_white_nits = max(RENODX_PEAK_WHITE_NITS, 100.f);
          const float safe_diffuse_white_nits = max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
          const float video_peak = safe_peak_white_nits / (safe_diffuse_white_nits / 100.f);

          float3 hdr_video = renodx::tonemap::inverse::bt2446a::BT709(video_rgb, 100.f, video_peak);
          hdr_video /= safe_diffuse_white_nits;
          video_rgb = ClampAndRenderIntermediatePass(max(0.f, hdr_video));
        }

	o.xyz = video_rgb;
	o.w = consts.w;

	return o;
}
