// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <d3d12.h>
#include <cstdint>
#include <span>
#include <vector>

namespace hartapfelfx::clouds {
// Retain the native descriptor graph, including local roots, export renames,
// collections and per-export configuration. ReShade's flattened pipeline API
// does not retain every native ray-tracing association.
class RayState {
 public:
  template <typename Replace>
  RayState(const D3D12_STATE_OBJECT_DESC& native, Replace replace) : descriptor(native) {
    objects_.assign(native.pSubobjects, native.pSubobjects + native.NumSubobjects);
    libraries_.reserve(native.NumSubobjects);
    associations_.reserve(native.NumSubobjects);
    for (auto& object : objects_) {
      if (object.Type != D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY) continue;
      const auto& library = *static_cast<const D3D12_DXIL_LIBRARY_DESC*>(object.pDesc);
      const auto code = replace(std::span(static_cast<const uint8_t*>(library.DXILLibrary.pShaderBytecode), library.DXILLibrary.BytecodeLength));
      if (code.empty()) continue;
      auto& copy = libraries_.emplace_back(library);
      copy.DXILLibrary = {code.data(), code.size()};
      object.pDesc = &copy;
      changed = true;
    }
    if (!changed) return;
    for (auto& object : objects_) {
      if (object.Type != D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION) continue;
      auto& copy = associations_.emplace_back(*static_cast<const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION*>(object.pDesc));
      const auto address = reinterpret_cast<uintptr_t>(copy.pSubobjectToAssociate);
      const auto first = reinterpret_cast<uintptr_t>(native.pSubobjects);
      if (address >= first && address - first < objects_.size() * sizeof(D3D12_STATE_SUBOBJECT)
          && (address - first) % sizeof(D3D12_STATE_SUBOBJECT) == 0)
        copy.pSubobjectToAssociate = objects_.data() + (address - first) / sizeof(D3D12_STATE_SUBOBJECT);
      object.pDesc = &copy;
    }
    descriptor.pSubobjects = objects_.data();
  }
  RayState(const RayState&) = delete;
  RayState& operator=(const RayState&) = delete;
  D3D12_STATE_OBJECT_DESC descriptor;
  bool changed = false;

 private:
  std::vector<D3D12_STATE_SUBOBJECT> objects_;
  std::vector<D3D12_DXIL_LIBRARY_DESC> libraries_;
  std::vector<D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION> associations_;
};
}  // namespace hartapfelfx::clouds
