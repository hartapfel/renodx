// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include <array>
#include <cstring>
#include <iostream>
#include <stdexcept>
#include "../clouds/ray_state.hpp"
#include "../lighting/graphics/raytracing/state.hpp"
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
    witcher3graphics::raytracing::StateDescription fog;
    const witcher3graphics::raytracing::LibraryReplacement fog_library{
        renodx::utils::hash::ComputeCRC32(original.data(), original.size()), original.size(), patched,
        witcher3graphics::raytracing::LibraryPurpose::fog};
    Require(fog.Replace(source, {&fog_library, 1}), "Additive fog state was not admitted");
    Require(fog.Get()->NumSubobjects == source.NumSubobjects + 1, "Fog library was not added separately");
    Require(fog.Get()->pSubobjects[2].pDesc == &library, "Fog adapter altered native library/export identity");
    Require(fog.FogExports().size() == 1 && fog.FogExports()[0] == L"RenamedRay", "Fog selector discarded native export rename");
    const auto& added = *static_cast<const D3D12_DXIL_LIBRARY_DESC*>(fog.Get()->pSubobjects[source.NumSubobjects].pDesc);
    Require(added.NumExports == 1 && std::wcscmp(added.pExports[0].Name, L"HartapfelVolumeLocalRGS") == 0,
            "Additive fog export lost");
    const auto& fog_local = *static_cast<const D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION*>(fog.Get()->pSubobjects[6].pDesc);
    Require(fog_local.pSubobjectToAssociate == &fog.Get()->pSubobjects[1] && fog_local.pExports == names,
            "Adding fog invalidated a native local-root association");
    Require(std::memcmp(baseline.data(), objects.data(), sizeof(objects)) == 0, "Fog adapter mutated native state description");
    const std::array<uint8_t,4> pt_original{9,10,11,12};
    const D3D12_DXIL_LIBRARY_DESC pt_library{{pt_original.data(),pt_original.size()},0,nullptr};
    const D3D12_STATE_SUBOBJECT combined_objects[]={{D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&library},
        {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&pt_library}};
    const D3D12_STATE_OBJECT_DESC combined{D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE,2,combined_objects};
    static constexpr const wchar_t* pt_names[]={L"PTRGSFinal",L"PTRGSWithSERFinal"};
    const witcher3graphics::raytracing::LibraryReplacement combined_replacements[]={fog_library,
        {renodx::utils::hash::ComputeCRC32(pt_original.data(),pt_original.size()),pt_original.size(),patched,
         witcher3graphics::raytracing::LibraryPurpose::fog,pt_names}};
    Require(fog.Replace(combined,combined_replacements) && fog.Get()->NumSubobjects==3 && fog.FogExports().size()==3,
            "Combined RT/PT state duplicated fog helper or lost generator names");
    Require(fog.Replace(combined,combined_replacements,UINT32_MAX,false) && fog.Get()->NumSubobjects==2 && fog.FogExports().size()==3,
            "Inherited fog helper was added again instead of preserving PT selection metadata");
    hartapfelfx::clouds::RayState untouched(source, [](auto) { return std::span<const uint8_t>{}; });
    Require(!untouched.changed && untouched.descriptor.pSubobjects == source.pSubobjects, "Unmatched native state object changed");
    std::cout << "PASS native ray roots, library exports/renames, collections, shader/pipeline configuration, local/config associations and unmatched identity\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
