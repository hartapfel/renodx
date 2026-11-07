// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Weather-selectable 1x128 cloud-height atlas. Native weather layer 4 was
// captured in rain; layer 2 is the current fair-cloud reference. The latter
// retains its previous vertical envelope exactly.
RWTexture2DArray<float4> profile : register(u0);
[numthreads(8,1,1)] void main(uint3 id : SV_DispatchThreadID) {
  if(id.x>=128u || id.z>=16u)return;
  float height=(id.x+.5f)/128.f;
  float storm=id.z==4u?1.f:0.f;
  float top=1.f-smoothstep(.55f+.1f*storm,1.f,height);
  profile[id]=float4(height,top,storm,1.f);
}
