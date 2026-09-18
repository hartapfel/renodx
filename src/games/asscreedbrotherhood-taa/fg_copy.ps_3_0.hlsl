/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
sampler2D source_texture : register(s0);
float4 main(float2 uv : TEXCOORD0) : COLOR0 { return tex2D(source_texture, uv); }
