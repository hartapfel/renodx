// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <include/reshade_api.hpp>

namespace hartapfelfx::fog {
struct LocalLightRange {
  uint64_t byte_offset = 0;
  uint32_t count = 0;
};
// Current ReShade metadata reports a byte offset and NumElements/stride in
// the two DWORDs that older headers expose as a single uint64_t size. The
// older D3D12 backend reports FirstElement/NumElements without the stride.
// The native LightParams ABI is independently verified as 160 bytes.
inline LocalLightRange DecodeLocalLightRange(const reshade::api::resource_view_desc& view, uint64_t bytes) {
  const uint32_t stride = uint32_t(view.buffer.size >> 32), count = uint32_t(view.buffer.size);
  if (view.type != reshade::api::resource_view_type::buffer || view.format != reshade::api::format::unknown
      || (stride != 0 && stride != 160) || (!stride && view.buffer.offset > bytes / 160u)) return {};
  const uint64_t offset = stride ? view.buffer.offset : view.buffer.offset * 160u;
  return offset <= bytes && offset % 160u == 0 && count <= (bytes - offset) / 160u
             ? LocalLightRange{offset, count} : LocalLightRange{};
}
}  // namespace hartapfelfx::fog
