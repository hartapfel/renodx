// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include <array>
#include <cstring>
#include <iostream>
#include <stdexcept>
#include "../clouds/ray_state.hpp"
void Require(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
int main() {
  try {
    const std::array<uint8_t, 4> original{1, 2, 3, 4}, patched{5, 6, 7, 8};
    const D3D12_EXPORT_DESC exports[] = {{L"RenamedRay", L"NativeRay", D3D12_EXPORT_FLAG_NONE}};
    const D3D12_DXIL_LIBRARY_DESC library{{original.data(), original.size()}, 1, exports};
    const D3D12_GLOBAL_ROOT_SIGNATURE global{reinterpret_cast<ID3D12RootSignature*>(0x1000)};
    const D3D12_LOCAL_ROOT_SIGNATURE local{reinterpret_cast<ID3D12RootSignature*>(0x2000)};
    const D3D12_RAYTRACING_SHADER_CONFIG shader_config{128, 32};
    const D3D12_RAYTRACING_PIPELINE_CONFIG1 pipeline_config{8, D3D12_RAYTRACING_PIPELINE_FLAG_SKIP_PROCEDURAL_PRIMITIVES};
    const D3D12_EXISTING_COLLECTION_DESC collection{reinterpret_cast<ID3D12StateObject*>(0x3000), 1, exports};
    const wchar_t* names[] = {L"RenamedRay"};
    std::array<D3D12_STATE_SUBOBJECT, 8> objects{{
        {D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE, &global},
        {D3D12_STATE_SUBOBJECT_TYPE_LOCAL_ROOT_SIGNATURE, &local},
        {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY, &library},
        {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG, &shader_config},
        {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG1, &pipeline_config},
        {D3D12_STATE_SUBOBJECT_TYPE_EXISTING_COLLECTION, &collection}}};
    const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION local_association{&objects[1], 1, names};
    const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION shader_association{&objects[3], 1, names};
    objects[6] = {D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION, &local_association};
    objects[7] = {D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION, &shader_association};
    const auto baseline = objects;
    const D3D12_STATE_OBJECT_DESC source{D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE, uint32_t(objects.size()), objects.data()};
    hartapfelfx::clouds::RayState state(source, [&](std::span<const uint8_t> code) -> std::span<const uint8_t> {
      Require(code.size() == original.size() && std::memcmp(code.data(), original.data(), original.size()) == 0, "Native library changed before adapter");
      return patched;
    });
    Require(state.changed && state.descriptor.NumSubobjects == source.NumSubobjects && state.descriptor.Type == source.Type, "State-object topology changed");
    for (uint32_t index : {0u, 1u, 3u, 4u, 5u})
      Require(state.descriptor.pSubobjects[index].Type == objects[index].Type && state.descriptor.pSubobjects[index].pDesc == objects[index].pDesc, "Native root/configuration/collection changed");
    const auto& replacement = *static_cast<const D3D12_DXIL_LIBRARY_DESC*>(state.descriptor.pSubobjects[2].pDesc);
    Require(replacement.DXILLibrary.pShaderBytecode == patched.data() && replacement.DXILLibrary.BytecodeLength == patched.size(), "Library was not replaced");
    Require(replacement.NumExports == library.NumExports && replacement.pExports == exports, "Native export names or renames changed");
    for (auto [index, target] : {std::pair{6u, 1u}, std::pair{7u, 3u}}) {
      const auto& association = *static_cast<const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION*>(state.descriptor.pSubobjects[index].pDesc);
      Require(association.pSubobjectToAssociate == &state.descriptor.pSubobjects[target], "Native association target was not rebased");
      Require(association.NumExports == 1 && association.pExports == names, "Native association export list changed");
    }
    Require(std::memcmp(baseline.data(), objects.data(), sizeof(objects)) == 0, "Adapter mutated caller-owned descriptors");
    hartapfelfx::clouds::RayState untouched(source, [](auto) { return std::span<const uint8_t>{}; });
    Require(!untouched.changed && untouched.descriptor.pSubobjects == source.pSubobjects, "Unmatched native state object changed");
    std::cout << "PASS native ray roots, library exports/renames, collections, shader/pipeline configuration, local/config associations and unmatched identity\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
