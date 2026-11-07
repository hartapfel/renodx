// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <span>
#include "native/0x02320E1A.hpp"
#include "native/0x35E6FF87.hpp"
#include "native/0x365A4FCA.hpp"
#include "native/0x4A7A44D6.hpp"
#include "native/0x52A112DE.hpp"
#include "native/0x806C62A8.hpp"
#include "native/0x9DF5AF93.hpp"
#include "native/0xD2C88922.hpp"
#include "native/0xEAAAC84D.hpp"
#include "native/0xF751BDFE.hpp"
#include "native/0x47BC87E1.hpp"
#include "native/0x6D655BE6.hpp"
#include "native/0xA3019513.hpp"
#include "native/0xAA89D644.hpp"
#include "native/0xF2FA912E.hpp"

namespace hartapfelfx::clouds::native {
inline std::span<const uint8_t> RayLibrary(uint32_t hash) {
  switch (hash) {
    case 0x47BC87E1u: return shader_47BC87E1;
    case 0x6D655BE6u: return shader_6D655BE6;
    case 0xA3019513u: return shader_A3019513;
    case 0xAA89D644u: return shader_AA89D644;
    case 0xF2FA912Eu: return shader_F2FA912E;
    default: return {};
  }
}
}  // namespace hartapfelfx::clouds::native
