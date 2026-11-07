// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Hardware-texture mip chain for the owned Perlin-Worley shape volume.
Texture3D<float4> source : register(t0);
RWTexture3D<float4> destination : register(u0);
[numthreads(4, 4, 4)] void main(uint3 id : SV_DispatchThreadID) {
  uint width, height, depth;
  destination.GetDimensions(width, height, depth);
  if (any(id >= uint3(width, height, depth))) return;
  float4 value = 0.f;
  [unroll] for (uint z = 0; z < 2; ++z)
    [unroll] for (uint y = 0; y < 2; ++y)
      [unroll] for (uint x = 0; x < 2; ++x)
        value += source.Load(int4(id * 2 + uint3(x, y, z), 0));
  destination[id] = value * .125f;
}
