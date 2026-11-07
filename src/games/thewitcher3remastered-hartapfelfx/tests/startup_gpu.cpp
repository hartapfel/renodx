// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Isolated addon-loading/root-signature smoke test. Never launches a game.
#include <d3d12.h>
#include <d3d12sdklayers.h>
#include <d3d12shader.h>
#include <dxcapi.h>
#include <dxgi1_6.h>
#include <wrl/client.h>
#include <bit>
#include <atomic>
#include <filesystem>
#include <fstream>
#include <include/reshade.hpp>
#include <iostream>
#include <vector>
#ifdef HARTAPFELFX_TEST_AGILITY
extern "C" __declspec(dllexport) const UINT D3D12SDKVersion = HARTAPFELFX_TEST_AGILITY;
extern "C" __declspec(dllexport) const char* D3D12SDKPath = ".\\D3D12_0\\";
#endif
#include "../fog/binding_layout.hpp"
using Microsoft::WRL::ComPtr;
namespace api = reshade::api;
std::atomic_uint32_t access_violations = 0;
LONG WINAPI TrackAccessViolations(EXCEPTION_POINTERS* exception) {
  if (exception->ExceptionRecord->ExceptionCode == EXCEPTION_ACCESS_VIOLATION) ++access_violations;
  return EXCEPTION_CONTINUE_SEARCH;
}
uint32_t extended_layouts = 0, unrelated_layouts = 0;
uint32_t private_volume_root = UINT32_MAX;
void InspectLayout(api::device*, uint32_t count, const api::pipeline_layout_param* params, api::pipeline_layout) {
  bool frame = false, light = false, volume = false, hdr = false;
  const hartapfelfx::fog::BindingLayout layout(count, params);
  for (uint32_t index = 0; index < layout.parameters.size(); ++index)
    for (const auto& range : layout.parameters[index].ranges) {
      frame |= range.type == api::descriptor_type::constant_buffer && range.dx_register_index == 12 && range.dx_register_space == 0;
      light |= range.type == api::descriptor_type::constant_buffer && range.dx_register_index == 13 && range.dx_register_space == 0;
      volume |= range.dx_register_space == 71;
      hdr |= range.dx_register_space == 50;
      if (range.dx_register_space == 71 && range.dx_register_index == 0 && range.type == api::descriptor_type::buffer_shader_resource_view)
        private_volume_root = index;
    }
  if (frame && light && volume && hdr) ++extended_layouts;
  if (!frame && !light && !volume) ++unrelated_layouts;
}
void Check(HRESULT hr) {
  if (FAILED(hr)) { std::cerr << "D3D12 HRESULT " << hr << std::endl; throw std::runtime_error("D3D12 HRESULT " + std::to_string(hr)); }
}
std::vector<char> Read(const std::filesystem::path& path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) throw std::runtime_error("Missing shader " + path.string());
  return {std::istreambuf_iterator<char>(input), {}};
}
ComPtr<ID3D12RootSignature> Root(ID3D12Device* device, bool common, uint32_t padding, bool local = false, uint32_t comparison_mask = 0, bool explicit_hdr = false, bool table_constants = false) {
  std::vector<D3D12_ROOT_PARAMETER> roots;
  const D3D12_DESCRIPTOR_RANGE cbvs{D3D12_DESCRIPTOR_RANGE_TYPE_CBV, 15, 1, 0, 0};
  if (common)
    for (uint32_t i = 0; i < (table_constants ? 1u : 14u); ++i) {
      D3D12_ROOT_PARAMETER parameter{};
      parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
      parameter.Descriptor = {i, 0};
      roots.push_back(parameter);
    }
  if (table_constants) {
    D3D12_ROOT_PARAMETER parameter{};
    parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
    parameter.DescriptorTable = {1, &cbvs};
    roots.push_back(parameter);
  }
  D3D12_DESCRIPTOR_RANGE ranges[2] = {{D3D12_DESCRIPTOR_RANGE_TYPE_SRV, 128, 0, 0, 0}, {D3D12_DESCRIPTOR_RANGE_TYPE_UAV, 8, 0, 0, 0}};
  for (const auto& range : ranges) {
    D3D12_ROOT_PARAMETER parameter{};
    parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
    parameter.DescriptorTable = {1, &range};
    roots.push_back(parameter);
  }
  if (padding) {
    D3D12_ROOT_PARAMETER parameter{};
    parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS;
    parameter.Constants = {0, 99, padding};
    roots.push_back(parameter);
  }
  if (explicit_hdr) {
    D3D12_ROOT_PARAMETER parameter{};
    parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
    parameter.Descriptor = {13, 50};
    roots.push_back(parameter);
  }
  D3D12_STATIC_SAMPLER_DESC samplers[16]{};
  for (uint32_t i = 0; i < 16; ++i) {
    auto& sampler = samplers[i];
    sampler.ShaderRegister = i;
    sampler.Filter = (comparison_mask & (1u << i)) ? D3D12_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR : D3D12_FILTER_MIN_MAG_MIP_LINEAR;
    sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D12_TEXTURE_ADDRESS_MODE_CLAMP;
    sampler.ComparisonFunc = D3D12_COMPARISON_FUNC_ALWAYS;
    sampler.MaxLOD = D3D12_FLOAT32_MAX;
  }
  D3D12_ROOT_SIGNATURE_DESC desc{uint32_t(roots.size()), roots.data(), local ? 0u : 16u, local ? nullptr : samplers, local ? D3D12_ROOT_SIGNATURE_FLAG_LOCAL_ROOT_SIGNATURE : D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT};
  ComPtr<ID3DBlob> blob, error;
  Check(D3D12SerializeRootSignature(&desc, D3D_ROOT_SIGNATURE_VERSION_1, &blob, &error));
  ComPtr<ID3D12RootSignature> root;
  Check(device->CreateRootSignature(0, blob->GetBufferPointer(), blob->GetBufferSize(), IID_PPV_ARGS(&root)));
  return root;
}
#include "runtime_gpu.hpp"
#include "cloud_runtime_gpu.hpp"
int main(int argc, char** argv) {
  try {
    if (argc != 5 && argc != 7) throw std::runtime_error("Expected original/production shaders, fog probe/width, optional ray libraries/cloud probes");
    void* exception_observer = AddVectoredExceptionHandler(1, TrackAccessViolations);
    if (!exception_observer) throw std::runtime_error("Could not install driver-exception observer");
    ComPtr<IDXGIFactory6> factory;
    Check(CreateDXGIFactory1(IID_PPV_ARGS(&factory)));
    if (!reshade::register_addon(GetModuleHandle(nullptr))) throw std::runtime_error("ReShade host registration failed");
    reshade::register_event<reshade::addon_event::init_pipeline_layout>(InspectLayout);
    reshade::register_event<reshade::addon_event::init_pipeline_layout>(CloudInspectLayout);
    reshade::register_event<reshade::addon_event::init_command_list>(CloudInspectCommand);
    reshade::register_event<reshade::addon_event::init_device>(CloudInspectDevice);
    {
      ComPtr<ID3D12Device> device;
      Check(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&device)));
      auto common = Root(device.Get(), true, 0);
      auto unrelated = Root(device.Get(), false, 0);
      auto full = Root(device.Get(), true, 32);
      auto local = Root(device.Get(), false, 0, true);
      std::cout << "Root layouts extended=" << extended_layouts << " unrelated=" << unrelated_layouts << std::endl;
      auto vs = Read(std::filesystem::path(argv[1]) / "0x0C1350D8.vs_6_3.cso");
      auto ps = Read(std::filesystem::path(argv[1]) / "0x73E21194.ps_6_6.cso");
      D3D12_GRAPHICS_PIPELINE_STATE_DESC desc{};
      desc.pRootSignature = common.Get();
      desc.VS = {vs.data(), vs.size()};
      desc.PS = {ps.data(), ps.size()};
      desc.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID;
      desc.RasterizerState.CullMode = D3D12_CULL_MODE_NONE;
      desc.RasterizerState.DepthClipEnable = TRUE;
      desc.SampleMask = UINT_MAX;
      desc.SampleDesc.Count = 1;
      desc.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
      D3D12_INPUT_ELEMENT_DESC position{"POSITION", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 0, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0};
      desc.InputLayout = {&position, 1};
      desc.NumRenderTargets = 1;
      desc.RTVFormats[0] = DXGI_FORMAT_R16G16B16A16_FLOAT;
      desc.DepthStencilState.DepthFunc = D3D12_COMPARISON_FUNC_ALWAYS;
      desc.DepthStencilState.FrontFace = {D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_STENCIL_OP_KEEP, D3D12_COMPARISON_FUNC_ALWAYS};
      desc.DepthStencilState.BackFace = desc.DepthStencilState.FrontFace;
      for (auto& target : desc.BlendState.RenderTarget) {
        target.SrcBlend = target.SrcBlendAlpha = D3D12_BLEND_ONE;
        target.DestBlend = target.DestBlendAlpha = D3D12_BLEND_ZERO;
        target.BlendOp = target.BlendOpAlpha = D3D12_BLEND_OP_ADD;
        target.LogicOp = D3D12_LOGIC_OP_NOOP;
        target.RenderTargetWriteMask = D3D12_COLOR_WRITE_ENABLE_ALL;
      }
      ComPtr<ID3D12PipelineState> pipeline;
      Check(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&pipeline)));
      // Reflect every captured receiver's actual vertex signature. Standalone
      // pixel compilation cannot validate inter-stage register linkage.
      auto compiler = LoadLibraryW(L"dxcompiler.dll");
      if (!compiler) throw std::runtime_error("Missing staged DXC reflection library");
      auto create_instance = reinterpret_cast<DxcCreateInstanceProc>(GetProcAddress(compiler, "DxcCreateInstance"));
      if (!create_instance) throw std::runtime_error("DXC factory unavailable");
      ComPtr<IDxcUtils> reflection_utils;
      Check(create_instance(CLSID_DxcUtils, IID_PPV_ARGS(&reflection_utils)));
      const std::pair<const char*, const char*> receivers[] = {
          {"0x0C1350D8.vs_6_3.cso", "0x73E21194"},
          {"0x2AEA8F51.vs_6_3.cso", "0x95CC19A8"},
          {"0x33B5635D.vs_6_3.cso", "0x6208DA88"},
          {"0x3ACAF2F9.vs_6_3.cso", "0x57F658BC"},
          {"0x4B7763FA.vs_6_3.cso", "0xCEE2035A"},
          {"0x81EAA494.vs_6_3.cso", "0xC60F2B46"},
          {"0x972185D4.vs_6_3.cso", "0x9550E75E"},
          {"0xB5373B9F.vs_6_3.cso", "0x683213A3"},
          {"0xC4CBD1E4.vs_6_3.cso", "0xB7D286D5"},
          {"0xCCD2CA86.vs_6_3.cso", "0x449D3390"},
          {"0xD7E9A3B4.vs_6_3.cso", "0x57F658BC"},
          {"0xF20F0978.vs_6_3.cso", "0xBF0CA052"}};
      const DXGI_FORMAT input_formats[3][4] = {
          {DXGI_FORMAT_R32_UINT, DXGI_FORMAT_R32G32_UINT, DXGI_FORMAT_R32G32B32_UINT, DXGI_FORMAT_R32G32B32A32_UINT},
          {DXGI_FORMAT_R32_SINT, DXGI_FORMAT_R32G32_SINT, DXGI_FORMAT_R32G32B32_SINT, DXGI_FORMAT_R32G32B32A32_SINT},
          {DXGI_FORMAT_R32_FLOAT, DXGI_FORMAT_R32G32_FLOAT, DXGI_FORMAT_R32G32B32_FLOAT, DXGI_FORMAT_R32G32B32A32_FLOAT}};
      auto water_hull = Read(std::filesystem::path(argv[1]) / "0xCDAFBC8A.hs_6_3.cso");
      auto water_domain = Read(std::filesystem::path(argv[1]) / "0xFDAA9A66.ds_6_3.cso");
      uint32_t receiver_failures = 0;
      for (const auto& [vertex_name, pixel_hash] : receivers) {
        auto vertex = Read(std::filesystem::path(argv[1]) / vertex_name);
        auto original = Read(std::filesystem::path(argv[1]) / (std::string(pixel_hash) + ".ps_6_6.cso"));
        auto replacement = Read(std::filesystem::path(argv[2]) / (std::string(pixel_hash) + ".cso"));
        DxcBuffer vertex_buffer{vertex.data(), vertex.size(), 0}, pixel_buffer{original.data(), original.size(), 0};
        ComPtr<ID3D12ShaderReflection> vertex_reflection, pixel_reflection;
        Check(reflection_utils->CreateReflection(&vertex_buffer, IID_PPV_ARGS(&vertex_reflection)));
        Check(reflection_utils->CreateReflection(&pixel_buffer, IID_PPV_ARGS(&pixel_reflection)));
        D3D12_SHADER_DESC vertex_desc{}, pixel_desc{};
        Check(vertex_reflection->GetDesc(&vertex_desc));
        Check(pixel_reflection->GetDesc(&pixel_desc));
        std::vector<D3D12_INPUT_ELEMENT_DESC> inputs;
        for (uint32_t i = 0; i < vertex_desc.InputParameters; ++i) {
          D3D12_SIGNATURE_PARAMETER_DESC input{};
          Check(vertex_reflection->GetInputParameterDesc(i, &input));
          if (input.SystemValueType != D3D_NAME_UNDEFINED) continue;
          const uint32_t components = std::popcount(uint32_t(input.Mask));
          if (input.ComponentType < 1 || input.ComponentType > 3 || components == 0 || components > 4) throw std::runtime_error("Unsupported native vertex input format");
          inputs.push_back({input.SemanticName, input.SemanticIndex, input_formats[input.ComponentType - 1][components - 1], 0, D3D12_APPEND_ALIGNED_ELEMENT, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0});
        }
        uint32_t comparison_mask = 0;
        for (auto* reflection : {vertex_reflection.Get(), pixel_reflection.Get()}) {
          D3D12_SHADER_DESC shader{};
          Check(reflection->GetDesc(&shader));
          for (uint32_t i = 0; i < shader.BoundResources; ++i) {
            D3D12_SHADER_INPUT_BIND_DESC resource{};
            Check(reflection->GetResourceBindingDesc(i, &resource));
            if (resource.Type == D3D_SIT_SAMPLER && (resource.uFlags & D3D_SIF_COMPARISON_SAMPLER) != 0 && resource.BindPoint < 16) comparison_mask |= 1u << resource.BindPoint;
          }
        }
        auto receiver_root = comparison_mask ? Root(device.Get(), true, 0, false, comparison_mask) : common;
        desc.pRootSignature = receiver_root.Get();
        const bool water = std::string_view(pixel_hash) == "0xC60F2B46";
        desc.HS = water ? D3D12_SHADER_BYTECODE{water_hull.data(), water_hull.size()} : D3D12_SHADER_BYTECODE{};
        desc.DS = water ? D3D12_SHADER_BYTECODE{water_domain.data(), water_domain.size()} : D3D12_SHADER_BYTECODE{};
        desc.PrimitiveTopologyType = water ? D3D12_PRIMITIVE_TOPOLOGY_TYPE_PATCH : D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
        desc.VS = {vertex.data(), vertex.size()};
        desc.InputLayout = {inputs.data(), uint32_t(inputs.size())};
        desc.NumRenderTargets = 0;
        std::fill(std::begin(desc.RTVFormats), std::end(desc.RTVFormats), DXGI_FORMAT_UNKNOWN);
        for (uint32_t i = 0; i < pixel_desc.OutputParameters; ++i) {
          D3D12_SIGNATURE_PARAMETER_DESC output{};
          Check(pixel_reflection->GetOutputParameterDesc(i, &output));
          if (output.SystemValueType != D3D_NAME_TARGET) continue;
          desc.NumRenderTargets = std::max(desc.NumRenderTargets, output.SemanticIndex + 1);
          desc.RTVFormats[output.SemanticIndex] = output.ComponentType == D3D_REGISTER_COMPONENT_UINT32 ? DXGI_FORMAT_R32G32B32A32_UINT : DXGI_FORMAT_R16G16B16A16_FLOAT;
        }
        std::cout << "Checking original pipeline " << pixel_hash << " / " << vertex_name << std::endl;
        desc.PS = {original.data(), original.size()};
        pipeline.Reset();
        Check(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&pipeline)));
        std::cout << "Checking native receiver linkage " << pixel_hash << " / " << vertex_name << std::endl;
        desc.PS = {replacement.data(), replacement.size()};
        pipeline.Reset();
        const auto result = device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&pipeline));
        if (FAILED(result)) {
          ++receiver_failures;
          std::cout << "FAILED receiver " << pixel_hash << " MRT=" << desc.NumRenderTargets << " comparisons=" << comparison_mask << " HRESULT=" << result << std::endl;
        }
      }
      if (receiver_failures) throw std::runtime_error("Native receiver linkage failures " + std::to_string(receiver_failures));
      desc.pRootSignature = common.Get();
      auto fullscreen = Read(std::filesystem::path(argv[2]) / "0xF7F00001.cso");
      desc.InputLayout = {};
      desc.VS = {fullscreen.data(), fullscreen.size()};
      desc.NumRenderTargets = 0;
      std::fill(std::begin(desc.RTVFormats), std::end(desc.RTVFormats), DXGI_FORMAT_UNKNOWN);
      for (const auto* name : {"0xF7F00002.cso", "0xF7F00004.cso", "0xF7F00007.cso", "0xF7F00008.cso"}) {
        auto code = Read(std::filesystem::path(argv[2]) / name);
        desc.PS = {code.data(), code.size()};
        pipeline.Reset();
        Check(device->CreateGraphicsPipelineState(&desc, IID_PPV_ARGS(&pipeline)));
      }
      for (const auto* name : {"0xF7F00003.cso", "0xF7F00005.cso", "0xF7F00006.cso"}) {
        auto code = Read(std::filesystem::path(argv[2]) / name);
        D3D12_COMPUTE_PIPELINE_STATE_DESC compute{};
        compute.pRootSignature = common.Get();
        compute.CS = {code.data(), code.size()};
        pipeline.Reset();
        Check(device->CreateComputePipelineState(&compute, IID_PPV_ARGS(&pipeline)));
      }
      if (extended_layouts == 0 || unrelated_layouts < 2) throw std::runtime_error("Expected scoped fog/HDR root extensions and untouched unrelated/local layouts");
      if (private_volume_root == UINT32_MAX) throw std::runtime_error("Missing private fog source root");
      RuntimeFrames(device.Get(), common.Get(), desc, argv[1], argv[3], private_volume_root, uint32_t(std::stoul(argv[4])));
      if (argc == 7) CloudRuntime(device.Get(), argv[1], argv[2], argv[5], argv[6], reflection_utils.Get());
    }
    reshade::unregister_event<reshade::addon_event::init_pipeline_layout>(InspectLayout);
    reshade::unregister_event<reshade::addon_event::init_pipeline_layout>(CloudInspectLayout);
    reshade::unregister_event<reshade::addon_event::init_command_list>(CloudInspectCommand);
    reshade::unregister_event<reshade::addon_event::init_device>(CloudInspectDevice);
    reshade::unregister_addon(GetModuleHandle(nullptr));
    RemoveVectoredExceptionHandler(exception_observer);
    if (access_violations) throw std::runtime_error("Driver access violations during compatibility test " + std::to_string(access_violations.load()));
    std::cout << "PASS: actual fog/HDR addons loaded, 12 native receiver pairs and private fog PSOs created, common/near-limit/unrelated/local root layouts survived. Extended=" << extended_layouts << " unrelated=" << unrelated_layouts << '\n';
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
