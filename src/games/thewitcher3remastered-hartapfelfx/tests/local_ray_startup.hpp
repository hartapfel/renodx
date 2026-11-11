// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "../fog/light_range.hpp"
inline api::resource_view structured_probe_view{};
inline bool ObserveStructuredProbe(api::device*, uint32_t count, const api::descriptor_table_update* updates) {
  for(uint32_t index=0;index<count;++index)
    if(updates[index].count==1 && updates[index].descriptors
        && (updates[index].type==api::descriptor_type::texture_shader_resource_view
            || updates[index].type==api::descriptor_type::buffer_shader_resource_view))
      structured_probe_view=*static_cast<const api::resource_view*>(updates[index].descriptors);
  return false;
}
// Create the actual native local-shadow library through the loaded addons.
// Keep its global signature's audited register ranges and require the additive
// fog export, so an optional-adapter fallback cannot pass this test silently.
inline void NativeFogRayPipeline(ID3D12Device* device, const std::filesystem::path& libraries,
                                  const std::filesystem::path& probes, const std::filesystem::path& embed) {
  D3D12_ROOT_PARAMETER parameters[4]{};
  parameters[0].ParameterType=D3D12_ROOT_PARAMETER_TYPE_SRV; parameters[0].Descriptor={0,1};
  D3D12_DESCRIPTOR_RANGE ranges[]={
    {D3D12_DESCRIPTOR_RANGE_TYPE_CBV,1,12,2,0}, {D3D12_DESCRIPTOR_RANGE_TYPE_CBV,2,0,1,1},
    {D3D12_DESCRIPTOR_RANGE_TYPE_CBV,1,1,0,3}, {D3D12_DESCRIPTOR_RANGE_TYPE_UAV,27,0,1,4},
    {D3D12_DESCRIPTOR_RANGE_TYPE_SRV,40,4,1,31}, {D3D12_DESCRIPTOR_RANGE_TYPE_SRV,64,0,2,71}};
  parameters[1].ParameterType=D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE; parameters[1].DescriptorTable={6,ranges};
  D3D12_DESCRIPTOR_RANGE sampler{D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER,3,0,1,0};
  parameters[2].ParameterType=D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE; parameters[2].DescriptorTable={1,&sampler};
  parameters[3].ParameterType=D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS; parameters[3].Constants={2,1,1};
  D3D12_ROOT_SIGNATURE_DESC desc{4,parameters,0,nullptr,D3D12_ROOT_SIGNATURE_FLAG_NONE};
  ComPtr<ID3DBlob> blob,error; Check(D3D12SerializeRootSignature(&desc,D3D_ROOT_SIGNATURE_VERSION_1,&blob,&error));
  ComPtr<ID3D12RootSignature> root; Check(device->CreateRootSignature(0,blob->GetBufferPointer(),blob->GetBufferSize(),IID_PPV_ARGS(&root)));
  const auto native=Read(libraries/"0x25AB4BF4.library.cso"), fixture=Read(probes/"local-ray-native.cso");
  const D3D12_EXPORT_DESC native_export{L"NativeLocalShadowAlias",L"LocalShadowsRGS",D3D12_EXPORT_FLAG_NONE};
  D3D12_DXIL_LIBRARY_DESC code[]={{{native.data(),native.size()},1,&native_export},{{fixture.data(),fixture.size()},0,nullptr}};
  D3D12_GLOBAL_ROOT_SIGNATURE global{root.Get()};
  D3D12_HIT_GROUP_DESC hit{L"LocalShadowHit",D3D12_HIT_GROUP_TYPE_TRIANGLES,L"LocalShadowAH",nullptr,nullptr};
  D3D12_RAYTRACING_SHADER_CONFIG config{20,8}; D3D12_RAYTRACING_PIPELINE_CONFIG pipeline{1};
  D3D12_STATE_SUBOBJECT objects[]={
    {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&code[0]}, {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&code[1]},
    {D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE,&global}, {D3D12_STATE_SUBOBJECT_TYPE_HIT_GROUP,&hit},
    {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG,&config}, {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG,&pipeline}};
  D3D12_STATE_OBJECT_DESC state_desc{D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE,UINT(std::size(objects)),objects};
  ComPtr<ID3D12Device5> ray_device; Check(device->QueryInterface(IID_PPV_ARGS(&ray_device)));
  ComPtr<ID3D12StateObject> state; Check(ray_device->CreateStateObject(&state_desc,IID_PPV_ARGS(&state)));
  ComPtr<ID3D12StateObjectProperties> properties; Check(state.As(&properties));
  if(!properties->GetShaderIdentifier(L"NativeLocalShadowAlias") || !properties->GetShaderIdentifier(L"HartapfelVolumeLocalRGS"))
    throw std::runtime_error("Native local-shadow/fog additive state fell back or lost exports");
  // Reproduce the live sequence: a normal compute PSO sends stage::all, and
  // the existing cloud scope restores DXR through the API without a second
  // native SetPipelineState1 notification. The fog tracker must keep its ray
  // state instead of querying the compute PSO as an ID3D12StateObject.
  auto compute_root=Root(device,true,0);
  const auto compute_code=Read(embed/"0xF7F00005.cso");
  D3D12_COMPUTE_PIPELINE_STATE_DESC compute_desc{}; compute_desc.pRootSignature=compute_root.Get();
  compute_desc.CS={compute_code.data(),compute_code.size()};
  ComPtr<ID3D12PipelineState> compute; Check(device->CreateComputePipelineState(&compute_desc,IID_PPV_ARGS(&compute)));
  std::array<uint8_t,5632> frame_data{};
  auto frame=RuntimeBuffer(device,frame_data.size(),D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,frame_data.data());
  std::array<uint8_t,64> record{}; std::memcpy(record.data(),properties->GetShaderIdentifier(L"NativeLocalShadowAlias"),32);
  auto sbt=RuntimeBuffer(device,record.size(),D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,record.data());
  D3D12_DESCRIPTOR_HEAP_DESC heap_desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV,135,D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE,0};
  ComPtr<ID3D12DescriptorHeap> heap; Check(device->CreateDescriptorHeap(&heap_desc,IID_PPV_ARGS(&heap)));
  D3D12_CONSTANT_BUFFER_VIEW_DESC cbv{frame->GetGPUVirtualAddress(),UINT(frame_data.size())};
  device->CreateConstantBufferView(&cbv,heap->GetCPUDescriptorHandleForHeapStart());
  // Native RT camera data lives in CameraCB, not the unused camera fields of
  // SharedPixelConsts. Leave that environment buffer zero to reproduce the
  // actual game's valid native binding contract.
  std::array<uint8_t,1792> camera_data{};
  auto camera=RuntimeBuffer(device,camera_data.size(),D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,camera_data.data());
  D3D12_CONSTANT_BUFFER_VIEW_DESC camera_cbv{camera->GetGPUVirtualAddress(),UINT(camera_data.size())};
  auto camera_slot=heap->GetCPUDescriptorHandleForHeapStart();
  camera_slot.ptr+=device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  device->CreateConstantBufferView(&camera_cbv,camera_slot);
  D3D12_HEAP_PROPERTIES texture_heap{}; texture_heap.Type=D3D12_HEAP_TYPE_DEFAULT;
  D3D12_RESOURCE_DESC depth_desc{}; depth_desc.Dimension=D3D12_RESOURCE_DIMENSION_TEXTURE2D;
  depth_desc.Width=depth_desc.Height=depth_desc.DepthOrArraySize=depth_desc.MipLevels=depth_desc.SampleDesc.Count=1;
  depth_desc.Format=DXGI_FORMAT_R32_FLOAT;
  ComPtr<ID3D12Resource> depth; Check(device->CreateCommittedResource(&texture_heap,D3D12_HEAP_FLAG_NONE,&depth_desc,
      D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE,nullptr,IID_PPV_ARGS(&depth)));
  D3D12_SHADER_RESOURCE_VIEW_DESC depth_view{}; depth_view.Format=DXGI_FORMAT_R32_FLOAT;
  depth_view.ViewDimension=D3D12_SRV_DIMENSION_TEXTURE2D; depth_view.Shader4ComponentMapping=D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
  depth_view.Texture2D.MipLevels=1;
  auto depth_slot=heap->GetCPUDescriptorHandleForHeapStart();
  depth_slot.ptr+=32*device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  device->CreateShaderResourceView(depth.Get(),&depth_view,depth_slot);
  auto light_buffer=RuntimeBuffer(device,4096,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
  D3D12_SHADER_RESOURCE_VIEW_DESC light_view{}; light_view.Format=DXGI_FORMAT_UNKNOWN;
  light_view.ViewDimension=D3D12_SRV_DIMENSION_BUFFER; light_view.Shader4ComponentMapping=D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
  light_view.Buffer.FirstElement=2; light_view.Buffer.NumElements=4; light_view.Buffer.StructureByteStride=160;
  auto light_slot=depth_slot; light_slot.ptr+=device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);
  structured_probe_view={};
  reshade::register_event<reshade::addon_event::update_descriptor_tables>(ObserveStructuredProbe);
  device->CreateShaderResourceView(light_buffer.Get(),&light_view,light_slot);
  reshade::unregister_event<reshade::addon_event::update_descriptor_tables>(ObserveStructuredProbe);
  if(!structured_probe_view.handle)throw std::runtime_error("Missing native structured-view observation");
  const auto native_view=cloud_host_device->get_resource_view_desc(structured_probe_view);
  const auto range=hartapfelfx::fog::DecodeLocalLightRange(native_view,4096);
  std::cout<<"Structured view offset/raw-size/decoded-offset/count="<<native_view.buffer.offset<<"/"
      <<native_view.buffer.size<<"/"<<range.byte_offset<<"/"<<range.count<<std::endl;
  if(range.byte_offset!=320 || range.count!=4)throw std::runtime_error("Native structured light view lost element offset/count/stride");
  auto invalid_view=native_view; invalid_view.buffer.offset=UINT64_MAX;
  if(hartapfelfx::fog::DecodeLocalLightRange(invalid_view,4096).count)throw std::runtime_error("Structured light view accepted out-of-range first element");
  std::cout<<"PASS actual ReShade structured-light metadata, stride and nonzero first-element range"<<std::endl;
  ComPtr<ID3D12CommandAllocator> allocator; Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT,IID_PPV_ARGS(&allocator)));
  ComPtr<ID3D12GraphicsCommandList4> command; Check(device->CreateCommandList(0,D3D12_COMMAND_LIST_TYPE_DIRECT,allocator.Get(),nullptr,IID_PPV_ARGS(&command)));
  auto* api_command=cloud_host_command;
  ID3D12DescriptorHeap* heaps[]={heap.Get()}; command->SetDescriptorHeaps(1,heaps);
  command->SetComputeRootSignature(root.Get()); command->SetComputeRootDescriptorTable(1,heap->GetGPUDescriptorHandleForHeapStart());
  command->SetPipelineState1(state.Get()); command->SetPipelineState(compute.Get());
  api_command->bind_pipeline(api::pipeline_stage::all_ray_tracing,{reinterpret_cast<uint64_t>(state.Get())});
  D3D12_DISPATCH_RAYS_DESC dispatch{}; dispatch.RayGenerationShaderRecord={sbt->GetGPUVirtualAddress(),32};
  command->DispatchRays(&dispatch);
  const GUID recording{0xfe1ce642u^0x57484658u,0xa9f5,0x4c2c,{0xa6,0x85,0x71,0xe2,0xfa,0x37,0xbd,0xbf}};
  uint64_t pointer=0; api_command->get_private_data(reinterpret_cast<const uint8_t*>(&recording),&pointer);
  std::array<uint64_t,2> captured{};
  if(pointer)std::memcpy(captured.data(),reinterpret_cast<const uint8_t*>(pointer)+sizeof(api::pipeline),sizeof(captured));
  if(!captured[0] || captured[1]<=captured[0])throw std::runtime_error("Cloud compute scope lost native fog ray capture");
  // PT performs local visibility inside PTRGS rather than requiring the
  // standalone LocalShadowsRGS. This state deliberately omits that library.
  const auto pt_code=Read(libraries/"0x47BC87E1.library.cso");
  D3D12_DXIL_LIBRARY_DESC pt_library{{pt_code.data(),pt_code.size()},0,nullptr};
  objects[0].pDesc=&pt_library;
  ComPtr<ID3D12StateObject> pt_state; Check(ray_device->CreateStateObject(&state_desc,IID_PPV_ARGS(&pt_state)));
  ComPtr<ID3D12StateObjectProperties> pt_properties; Check(pt_state.As(&pt_properties));
  if(!pt_properties->GetShaderIdentifier(L"HartapfelVolumeLocalRGS") || !pt_properties->GetShaderIdentifier(L"PTRGSFinal")
      || !pt_properties->GetShaderIdentifier(L"PTRGSWithSERFinal"))throw std::runtime_error("Native PT/SER state lost fog ray support");
  std::array<uint8_t,64> pt_record{}; std::memcpy(pt_record.data(),pt_properties->GetShaderIdentifier(L"PTRGSFinal"),32);
  auto pt_sbt=RuntimeBuffer(device,pt_record.size(),D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ,pt_record.data());
  command->SetPipelineState1(pt_state.Get()); command->SetPipelineState(compute.Get());
  api_command->bind_pipeline(api::pipeline_stage::all_ray_tracing,{reinterpret_cast<uint64_t>(pt_state.Get())});
  dispatch.RayGenerationShaderRecord={pt_sbt->GetGPUVirtualAddress(),32}; command->DispatchRays(&dispatch);
  std::memcpy(captured.data(),reinterpret_cast<const uint8_t*>(pointer)+sizeof(api::pipeline),sizeof(captured));
  if(captured[1]-captured[0]<3*sizeof(std::shared_ptr<void>))throw std::runtime_error("PT/SER native shader aliases were not captured");
  Check(command->Close());
  std::cout<<"PASS native PT/SER pipeline without LocalShadowsRGS, compatible GbufferPayload/SBT and fog capture"<<std::endl;
  std::cout<<"PASS native fog ray capture after ordinary compute PSO + API DXR restoration"<<std::endl;
  std::cout<<"PASS actual native LocalShadowsRGS library + additive fog ray generator, native global signature and 20-byte shadow ABI"<<std::endl;
}
