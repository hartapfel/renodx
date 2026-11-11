// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Executes the production fog ray generator against real triangle acceleration
// structures, without a camera depth texture or native surface shadow mask.
#include <d3d12.h>
#include <d3d12sdklayers.h>
#include <DirectXPackedVector.h>
#include <wrl/client.h>
#include <array>
#include <bit>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <vector>
#include "../shared.h"
#include "../fog/ray_local.generated.hpp"
using Microsoft::WRL::ComPtr;
void Check(HRESULT hr) { if (FAILED(hr)) throw std::runtime_error("D3D12 HRESULT " + std::to_string(hr)); }
ComPtr<ID3D12Resource> Buffer(ID3D12Device* device, uint64_t bytes, D3D12_HEAP_TYPE heap_type, D3D12_RESOURCE_STATES state) {
  D3D12_HEAP_PROPERTIES heap{}; heap.Type = heap_type;
  D3D12_RESOURCE_DESC desc{}; desc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER; desc.Width = bytes;
  desc.Height = desc.DepthOrArraySize = desc.MipLevels = desc.SampleDesc.Count = 1; desc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
  if (heap_type == D3D12_HEAP_TYPE_DEFAULT) desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
  ComPtr<ID3D12Resource> result;
  Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc, state, nullptr, IID_PPV_ARGS(&result)));
  return result;
}
void Upload(ID3D12Resource* resource, const void* bytes, size_t count) {
  void* data = nullptr; D3D12_RANGE empty{}; Check(resource->Map(0, &empty, &data));
  std::memcpy(data, bytes, count); resource->Unmap(0, nullptr);
}
int main(int argc, char** argv) {
  try {
    if (argc != 2) throw std::runtime_error("Expected local-ray fixture library");
    ComPtr<ID3D12Debug> debug;
    if (SUCCEEDED(D3D12GetDebugInterface(IID_PPV_ARGS(&debug)))) debug->EnableDebugLayer();
    ComPtr<ID3D12Device5> device; Check(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_1, IID_PPV_ARGS(&device)));
    ComPtr<ID3D12InfoQueue> messages; device.As(&messages);
    D3D12_ROOT_PARAMETER roots[10]{};
    for (uint32_t i=0;i<4;++i) { roots[i].ParameterType=D3D12_ROOT_PARAMETER_TYPE_CBV; roots[i].Descriptor={i,61}; }
    roots[4].ParameterType=D3D12_ROOT_PARAMETER_TYPE_UAV; roots[4].Descriptor={0,61};
    roots[5].ParameterType=roots[6].ParameterType=roots[7].ParameterType=D3D12_ROOT_PARAMETER_TYPE_SRV;
    roots[5].Descriptor={0,61}; roots[6].Descriptor={1,61}; roots[7].Descriptor={0,1};
    D3D12_DESCRIPTOR_RANGE cookie_range{D3D12_DESCRIPTOR_RANGE_TYPE_SRV,1,42,2,0};
    roots[8].ParameterType=D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE; roots[8].DescriptorTable={1,&cookie_range};
    roots[9].ParameterType=D3D12_ROOT_PARAMETER_TYPE_CBV; roots[9].Descriptor={4,61};
    D3D12_STATIC_SAMPLER_DESC sampler{}; sampler.Filter=D3D12_FILTER_MIN_MAG_MIP_LINEAR;
    sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D12_TEXTURE_ADDRESS_MODE_WRAP;
    sampler.MaxLOD=D3D12_FLOAT32_MAX; sampler.ComparisonFunc=D3D12_COMPARISON_FUNC_ALWAYS; sampler.RegisterSpace=1;
    D3D12_ROOT_SIGNATURE_DESC root_desc{10,roots,1,&sampler,D3D12_ROOT_SIGNATURE_FLAG_NONE};
    ComPtr<ID3DBlob> serialized,error; Check(D3D12SerializeRootSignature(&root_desc,D3D_ROOT_SIGNATURE_VERSION_1,&serialized,&error));
    ComPtr<ID3D12RootSignature> root; Check(device->CreateRootSignature(0,serialized->GetBufferPointer(),serialized->GetBufferSize(),IID_PPV_ARGS(&root)));
    std::ifstream input(argv[1],std::ios::binary); if(!input)throw std::runtime_error("Missing fixture");
    std::vector<char> fixture{std::istreambuf_iterator<char>(input),{}};
    const D3D12_EXPORT_DESC volume_export{L"HartapfelVolumeLocalRGS",nullptr,D3D12_EXPORT_FLAG_NONE};
    D3D12_DXIL_LIBRARY_DESC libraries[]={{{hartapfelfx::fog::rays::local_code,sizeof(hartapfelfx::fog::rays::local_code)},1,&volume_export},{{fixture.data(),fixture.size()},0,nullptr}};
    D3D12_GLOBAL_ROOT_SIGNATURE global{root.Get()};
    D3D12_HIT_GROUP_DESC hit{L"LocalShadowHit",D3D12_HIT_GROUP_TYPE_TRIANGLES,L"LocalShadowAH",nullptr,nullptr};
    D3D12_RAYTRACING_SHADER_CONFIG config{20,8}; D3D12_RAYTRACING_PIPELINE_CONFIG pipeline{1};
    D3D12_STATE_SUBOBJECT objects[]={
      {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&libraries[0]}, {D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&libraries[1]},
      {D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE,&global}, {D3D12_STATE_SUBOBJECT_TYPE_HIT_GROUP,&hit},
      {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG,&config}, {D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG,&pipeline}};
    D3D12_STATE_OBJECT_DESC state_desc{D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE,UINT(std::size(objects)),objects};
    ComPtr<ID3D12StateObject> state; Check(device->CreateStateObject(&state_desc,IID_PPV_ARGS(&state)));
    ComPtr<ID3D12StateObjectProperties> properties; Check(state.As(&properties));
    std::array<uint8_t,256> sbt{};
    for(auto [offset,name]:{std::pair{0u,L"HartapfelVolumeLocalRGS"},{64u,L"LocalShadowMS"},{128u,L"LocalShadowHit"},{192u,L"LocalShadowsRGS"}}) {
      const void* id=properties->GetShaderIdentifier(name); if(!id)throw std::runtime_error("Missing shader identifier");
      std::memcpy(sbt.data()+offset,id,32);
    }
    auto table=Buffer(device.Get(),256,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ); Upload(table.Get(),sbt.data(),sbt.size());
    auto frame=Buffer(device.Get(),5632,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    auto native_frame=Buffer(device.Get(),65536,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    auto lighting=Buffer(device.Get(),57600,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    auto settings=Buffer(device.Get(),1024,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    auto second_settings=Buffer(device.Get(),1024,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    auto lights=Buffer(device.Get(),256,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    auto source=Buffer(device.Get(),1536,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    auto output=Buffer(device.Get(),1536,D3D12_HEAP_TYPE_DEFAULT,D3D12_RESOURCE_STATE_COPY_DEST);
    auto readback=Buffer(device.Get(),1536,D3D12_HEAP_TYPE_READBACK,D3D12_RESOURCE_STATE_COPY_DEST);
    D3D12_DESCRIPTOR_HEAP_DESC heap_desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV,1,D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE,0};
    ComPtr<ID3D12DescriptorHeap> heap; Check(device->CreateDescriptorHeap(&heap_desc,IID_PPV_ARGS(&heap)));
    D3D12_SHADER_RESOURCE_VIEW_DESC cookie{}; cookie.Format=DXGI_FORMAT_R8G8B8A8_UNORM; cookie.ViewDimension=D3D12_SRV_DIMENSION_TEXTURE2DARRAY;
    cookie.Shader4ComponentMapping=D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING; cookie.Texture2DArray.MipLevels=cookie.Texture2DArray.ArraySize=1;
    device->CreateShaderResourceView(nullptr,&cookie,heap->GetCPUDescriptorHandleForHeapStart());
    auto vertices=Buffer(device.Get(),256,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    D3D12_RAYTRACING_GEOMETRY_DESC geometry{}; geometry.Type=D3D12_RAYTRACING_GEOMETRY_TYPE_TRIANGLES;
    geometry.Triangles.VertexBuffer={vertices->GetGPUVirtualAddress(),12}; geometry.Triangles.VertexCount=3; geometry.Triangles.VertexFormat=DXGI_FORMAT_R32G32B32_FLOAT;
    D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS bottom{}; bottom.Type=D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL;
    bottom.DescsLayout=D3D12_ELEMENTS_LAYOUT_ARRAY; bottom.NumDescs=1; bottom.pGeometryDescs=&geometry;
    D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO bottom_size{}; device->GetRaytracingAccelerationStructurePrebuildInfo(&bottom,&bottom_size);
    auto blas=Buffer(device.Get(),bottom_size.ResultDataMaxSizeInBytes,D3D12_HEAP_TYPE_DEFAULT,D3D12_RESOURCE_STATE_RAYTRACING_ACCELERATION_STRUCTURE);
    auto instance=Buffer(device.Get(),256,D3D12_HEAP_TYPE_UPLOAD,D3D12_RESOURCE_STATE_GENERIC_READ);
    D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS top{}; top.Type=D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL;
    top.DescsLayout=D3D12_ELEMENTS_LAYOUT_ARRAY; top.NumDescs=1; top.InstanceDescs=instance->GetGPUVirtualAddress();
    D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO top_size{}; device->GetRaytracingAccelerationStructurePrebuildInfo(&top,&top_size);
    auto tlas=Buffer(device.Get(),top_size.ResultDataMaxSizeInBytes,D3D12_HEAP_TYPE_DEFAULT,D3D12_RESOURCE_STATE_RAYTRACING_ACCELERATION_STRUCTURE);
    auto scratch=Buffer(device.Get(),std::max(bottom_size.ScratchDataSizeInBytes,top_size.ScratchDataSizeInBytes),D3D12_HEAP_TYPE_DEFAULT,D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    D3D12_COMMAND_QUEUE_DESC queue_desc{}; ComPtr<ID3D12CommandQueue> queue; Check(device->CreateCommandQueue(&queue_desc,IID_PPV_ARGS(&queue)));
    ComPtr<ID3D12CommandAllocator> allocator; Check(device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT,IID_PPV_ARGS(&allocator)));
    ComPtr<ID3D12GraphicsCommandList4> cmd; Check(device->CreateCommandList(0,D3D12_COMMAND_LIST_TYPE_DIRECT,allocator.Get(),nullptr,IID_PPV_ARGS(&cmd))); Check(cmd->Close());
    ComPtr<ID3D12Fence> fence; Check(device->CreateFence(0,D3D12_FENCE_FLAG_NONE,IID_PPV_ARGS(&fence)));
    uint64_t serial=0; std::array<float,4> clear{};
    for(uint32_t test=0;test<18;++test) for(uint32_t quality=0;quality<4;++quality) {
      std::array<std::array<float,4>,341> camera{}; camera[0]={2,-3,0,1}; camera[20]={0,0,1,1}; camera[286]={1,2,3,4}; camera[43][0]=.001f;
      std::array<uint8_t,1536> initial{};
      const uint32_t valid=FOG_FRAME_VALID,cell[2]={0,0x3c000000};
      std::memcpy(initial.data()+1016,&valid,4); std::memcpy(initial.data()+64,camera[0].data(),16);
      std::memcpy(initial.data()+912,camera[286].data(),16); std::memcpy(initial.data()+FOG_HEADER_BYTES,cell,8);
      if(test==10)initial[912]^=1;
      Upload(source.Get(),initial.data(),initial.size()); Upload(frame.Get(),camera.data(),sizeof(camera));
      std::array<std::array<float,4>,102> ray_camera{};
      ray_camera[8]=camera[0];
      if(test==8)ray_camera[8][0]+=1.f;
      if(test==9) { ray_camera[17][0]+=.001f; ray_camera[18][1]-=.001f; }
      if(test==11)ray_camera[8]={};
      if(test==12||test==13)ray_camera[78][0]=.25f;
      if(test>=15) { ray_camera[79][0]=std::bit_cast<float>(test==16?0u:1u); ray_camera[79][2]=.25f; }
      Upload(native_frame.Get(),ray_camera.data(),sizeof(ray_camera));
      std::array<uint32_t,14400> native_light{}; native_light[67*4+1]=1; Upload(lighting.Get(),native_light.data(),sizeof(native_light));
      std::array<uint8_t,1024> parameters{};
      ShaderInjectData fx{1,1,1,0,0,1,1,1}; VolumeLightData beam{1,1,0,0,0,1,1,FOG_LIGHT_VALID,0,float(quality)};
      std::memcpy(parameters.data(),&fx,sizeof(fx)); std::memcpy(parameters.data()+160,&beam,sizeof(beam));
      const uint32_t grid[8]={1,1,1,0,0,0,0,0},available[4]={1,1,0,0};
      std::memcpy(parameters.data()+256,grid,sizeof(grid)); std::memcpy(parameters.data()+288,sbt.data()+192,32);
      std::memcpy(parameters.data()+320,available,sizeof(available)); if(test==5||test==7)parameters[288]^=1;
      Upload(settings.Get(),parameters.data(),parameters.size());
      const uint32_t second_token=2; std::memcpy(parameters.data()+324,&second_token,4);
      if(test==7)parameters[288]^=1;
      Upload(second_settings.Get(),parameters.data(),parameters.size());
      std::array<std::array<float,4>,10> light{}; light[0]={0,0,5,2000}; light[3]={10,2,1,0};
      if(test==6)light[3][3]=std::bit_cast<float>(0x80000000u);
      if(test==17) { light[5][2]=1.f; for(uint32_t row=7;row<=8;++row)for(float& packed:light[row])packed=std::bit_cast<float>(0x100000u); }
      Upload(lights.Get(),light.data(),sizeof(light));
      const float wall_z=test>=12?(test==13?5.5f:5.02f):test==2?2.f:test==3?900.f:10.f;
      float triangle[9]={-100,-100,wall_z,100,-100,wall_z,0,100,wall_z};
      if(test==6)for(uint32_t axis=0;axis<3;++axis)std::swap(triangle[3+axis],triangle[6+axis]);
      Upload(vertices.Get(),triangle,sizeof(triangle));
      D3D12_RAYTRACING_INSTANCE_DESC inst{}; inst.Transform[0][0]=inst.Transform[1][1]=inst.Transform[2][2]=1;
      inst.InstanceID=test==0||test==4||test==7||test==9?0:1; inst.InstanceMask=255; inst.AccelerationStructure=blas->GetGPUVirtualAddress(); Upload(instance.Get(),&inst,sizeof(inst));
      Check(allocator->Reset()); Check(cmd->Reset(allocator.Get(),nullptr));
      D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC build{}; build.Inputs=bottom; build.DestAccelerationStructureData=blas->GetGPUVirtualAddress(); build.ScratchAccelerationStructureData=scratch->GetGPUVirtualAddress(); cmd->BuildRaytracingAccelerationStructure(&build,0,nullptr);
      D3D12_RESOURCE_BARRIER order{}; order.Type=D3D12_RESOURCE_BARRIER_TYPE_UAV; cmd->ResourceBarrier(1,&order);
      build.Inputs=top; build.DestAccelerationStructureData=tlas->GetGPUVirtualAddress(); cmd->BuildRaytracingAccelerationStructure(&build,0,nullptr); cmd->ResourceBarrier(1,&order);
      cmd->CopyBufferRegion(output.Get(),0,source.Get(),0,initial.size());
      D3D12_RESOURCE_BARRIER transition{}; transition.Type=D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
      transition.Transition={output.Get(),D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,D3D12_RESOURCE_STATE_COPY_DEST,D3D12_RESOURCE_STATE_UNORDERED_ACCESS}; cmd->ResourceBarrier(1,&transition);
      cmd->SetComputeRootSignature(root.Get()); cmd->SetPipelineState1(state.Get());
      cmd->SetComputeRootConstantBufferView(0,frame->GetGPUVirtualAddress()); cmd->SetComputeRootConstantBufferView(1,lighting->GetGPUVirtualAddress());
      cmd->SetComputeRootConstantBufferView(2,settings->GetGPUVirtualAddress()); cmd->SetComputeRootConstantBufferView(3,settings->GetGPUVirtualAddress()+256);
      cmd->SetComputeRootUnorderedAccessView(4,output->GetGPUVirtualAddress()); cmd->SetComputeRootShaderResourceView(5,lights->GetGPUVirtualAddress());
      cmd->SetComputeRootShaderResourceView(6,table->GetGPUVirtualAddress()+192); cmd->SetComputeRootShaderResourceView(7,tlas->GetGPUVirtualAddress());
      ID3D12DescriptorHeap* heaps[]={heap.Get()}; cmd->SetDescriptorHeaps(1,heaps); cmd->SetComputeRootDescriptorTable(8,heap->GetGPUDescriptorHandleForHeapStart());
      cmd->SetComputeRootConstantBufferView(9,native_frame->GetGPUVirtualAddress());
      D3D12_DISPATCH_RAYS_DESC dispatch{}; dispatch.RayGenerationShaderRecord={table->GetGPUVirtualAddress(),32};
      dispatch.MissShaderTable={table->GetGPUVirtualAddress()+64,32,32}; dispatch.HitGroupTable={table->GetGPUVirtualAddress()+128,32,32};
      dispatch.Width=dispatch.Height=dispatch.Depth=1; cmd->DispatchRays(&dispatch);
      if(test==4||test==7) {
        cmd->ResourceBarrier(1,&order);
        cmd->SetComputeRootConstantBufferView(3,second_settings->GetGPUVirtualAddress()+256);
        cmd->DispatchRays(&dispatch);
      }
      transition.Transition.StateBefore=D3D12_RESOURCE_STATE_UNORDERED_ACCESS; transition.Transition.StateAfter=D3D12_RESOURCE_STATE_COPY_SOURCE; cmd->ResourceBarrier(1,&transition);
      cmd->CopyResource(readback.Get(),output.Get()); transition.Transition.StateBefore=D3D12_RESOURCE_STATE_COPY_SOURCE; transition.Transition.StateAfter=D3D12_RESOURCE_STATE_COPY_DEST; cmd->ResourceBarrier(1,&transition);
      Check(cmd->Close()); ID3D12CommandList* lists[]={cmd.Get()}; queue->ExecuteCommandLists(1,lists); Check(queue->Signal(fence.Get(),++serial));
      HANDLE done=CreateEvent(nullptr,FALSE,FALSE,nullptr); Check(fence->SetEventOnCompletion(serial,done));
      if(WaitForSingleObject(done,60000)!=WAIT_OBJECT_0)throw std::runtime_error("Fog ray GPU timeout"); CloseHandle(done); Check(device->GetDeviceRemovedReason());
      void* mapped=nullptr; Check(readback->Map(0,nullptr,&mapped)); uint16_t half; std::memcpy(&half,static_cast<uint8_t*>(mapped)+FOG_HEADER_BYTES,2);
      const float energy=DirectX::PackedVector::XMConvertHalfToFloat(half); readback->Unmap(0,nullptr);
      const bool blocked=test==1||test==5||test==6||test==8||test==10||test==11||test==13||test==14||test==16||test==17;
      if(!std::isfinite(energy)||(blocked?energy!=0:energy<=0))throw std::runtime_error("World shadow/alpha/endpoint/selection regression case "+std::to_string(test));
      if(test==0)clear[quality]=energy;
      if((test==4||test==7||test==9)&&energy!=clear[quality])throw std::runtime_error("GPU candidate selection or independent PT jitter changed local energy");
    }
    if(messages) for(uint64_t i=0;i<messages->GetNumStoredMessages();++i) {
      SIZE_T size=0; messages->GetMessage(i,nullptr,&size); std::vector<uint8_t> bytes(size); auto* message=reinterpret_cast<D3D12_MESSAGE*>(bytes.data());
      Check(messages->GetMessage(i,message,&size)); if(message->Severity<=D3D12_MESSAGE_SEVERITY_ERROR)throw std::runtime_error(message->pDescription);
    }
    std::cout<<"PASS production fog rays: opaque world blocker, alpha rejection, finite emitter endpoint, geometry beyond cell, repeatability, GPU export selection, two-sided light flag; all four qualities, no screen depth; debug layer "<<(debug?"enabled":"unavailable")<<'\n';
  }catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}
}
