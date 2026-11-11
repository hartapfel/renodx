// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <d3d12.h>
#include <cstdint>
#include <algorithm>
#include <span>
#include <string>
#include <vector>
#include "../../../../../utils/hash.hpp"

namespace witcher3graphics::raytracing {
enum class LibraryPurpose { water, reflection, global_probe, local_probe, fog };
struct LibraryReplacement {
  uint32_t hash;
  size_t original_size;
  std::span<const uint8_t> code;
  LibraryPurpose purpose = LibraryPurpose::water;
  std::span<const wchar_t* const> default_exports{};
};

// Preserve the native state-object contract, including export renames, local
// roots and inherited collections. Generic pipeline reconstruction loses some
// of these associations. Storage lasts through CreateStateObject/AddToStateObject.
class StateDescription {
 public:
  StateDescription() = default;
  StateDescription(const StateDescription&) = delete;
  StateDescription& operator=(const StateDescription&) = delete;
  bool Replace(const D3D12_STATE_OBJECT_DESC& native, std::span<const LibraryReplacement> replacements,
      uint32_t eligible = UINT32_MAX, bool add_fog_library = true) {
    changed_ = false;
    mask_ = 0;
    bool changed = false;
    uint32_t mask = 0;
    objects_.clear(); libraries_.clear(); associations_.clear(); fog_exports_.clear();
    if (!native.pSubobjects || native.NumSubobjects == 0 || native.NumSubobjects > 4096 || replacements.size() > 32) return false;
    objects_.assign(native.pSubobjects, native.pSubobjects + native.NumSubobjects);
    objects_.reserve(native.NumSubobjects + replacements.size());
    libraries_.reserve(native.NumSubobjects + replacements.size()); associations_.reserve(native.NumSubobjects);
    std::vector<uint32_t> additions;
    for (uint32_t object_index = 0; object_index < native.NumSubobjects; ++object_index) {
      auto& object = objects_[object_index];
      if (!object.pDesc) return false;
      if (object.Type == D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY) {
        const auto& library = *static_cast<const D3D12_DXIL_LIBRARY_DESC*>(object.pDesc);
        if (!library.DXILLibrary.pShaderBytecode || !library.DXILLibrary.BytecodeLength) continue;
        for (uint32_t index = 0; index < replacements.size(); ++index) {
          if ((eligible & (1u << index)) == 0) continue;
          const auto& replacement = replacements[index];
          if (replacement.code.empty() || replacement.original_size != library.DXILLibrary.BytecodeLength) continue;
          if (renodx::utils::hash::ComputeCRC32(static_cast<const uint8_t*>(library.DXILLibrary.pShaderBytecode),
                  library.DXILLibrary.BytecodeLength) != replacement.hash) continue;
          if (replacement.purpose == LibraryPurpose::fog) {
            if (library.NumExports > 4096 || (library.NumExports && !library.pExports)) return false;
            if (!library.NumExports) {
              if (replacement.default_exports.empty()) fog_exports_.emplace_back(L"LocalShadowsRGS");
              else for (const auto* name : replacement.default_exports) fog_exports_.emplace_back(name);
            }
            for (UINT i = 0; i < library.NumExports; ++i)
              if (library.pExports[i].Name) fog_exports_.emplace_back(library.pExports[i].Name);
            // Add a ray generator, retaining the native library byte for byte.
            // Its shadow payload is consumed by the existing native hit/miss
            // shaders and their original shader-table/local-root contract.
            if (add_fog_library && std::none_of(additions.begin(), additions.end(), [&](uint32_t previous) {
                  return replacements[previous].code.data() == replacement.code.data()
                      && replacements[previous].code.size() == replacement.code.size();
                })) additions.push_back(index);
          } else {
            libraries_.push_back(library);
            libraries_.back().DXILLibrary = {replacement.code.data(), replacement.code.size()};
            object.pDesc = &libraries_.back();
          }
          changed = true;
          mask |= 1u << index;
          break;
        }
      } else if (object.Type == D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION) {
        const auto& association = *static_cast<const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION*>(object.pDesc);
        const uintptr_t start = reinterpret_cast<uintptr_t>(native.pSubobjects);
        const uintptr_t target = reinterpret_cast<uintptr_t>(association.pSubobjectToAssociate);
        if (target < start || target - start >= native.NumSubobjects * sizeof(D3D12_STATE_SUBOBJECT)
            || (target - start) % sizeof(D3D12_STATE_SUBOBJECT) != 0) return false;
        associations_.push_back(association);
        associations_.back().pSubobjectToAssociate = &objects_[(target - start) / sizeof(D3D12_STATE_SUBOBJECT)];
        object.pDesc = &associations_.back();
      }
    }
    static constexpr D3D12_EXPORT_DESC fog_export{L"HartapfelVolumeLocalRGS", nullptr, D3D12_EXPORT_FLAG_NONE};
    for (uint32_t index : additions) {
      libraries_.push_back({{replacements[index].code.data(), replacements[index].code.size()}, 1, &fog_export});
      objects_.push_back({D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY, &libraries_.back()});
    }
    desc_ = {native.Type, UINT(objects_.size()), objects_.data()};
    changed_ = changed;
    mask_ = mask;
    return changed_;
  }
  const D3D12_STATE_OBJECT_DESC* Get() const { return changed_ ? &desc_ : nullptr; }
  uint32_t Mask() const { return mask_; }
  const std::vector<std::wstring>& FogExports() const { return fog_exports_; }

 private:
  D3D12_STATE_OBJECT_DESC desc_{};
  std::vector<D3D12_STATE_SUBOBJECT> objects_;
  std::vector<D3D12_DXIL_LIBRARY_DESC> libraries_;
  std::vector<D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION> associations_;
  std::vector<std::wstring> fog_exports_;
  bool changed_ = false;
  uint32_t mask_ = 0;
};
}  // namespace witcher3graphics::raytracing
