/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <d3d9.h>
#include <wrl/client.h>
#include <sstream>
#include <unordered_map>

#include "../../utils/command_action.hpp"
#include "../../utils/data.hpp"
#include "./taa_camera.hpp"
#include "./taa_jitter.hpp"
#include "./taa_resolve.hpp"
#include "./dlaa.hpp"
#include "./taa_motion.hpp"
#include "./native_draw.hpp"
#include "./taa_performance.hpp"

namespace acbrotherhood::taa {

inline float capture_enabled = 0.f;
inline float confidence_preview = 0.f;
inline float dump_resolve = 0.f;
inline float enabled = 1.f;
inline float debug_view = 0.f;
inline float rcas_strength = 0.f;
// Frame-latched internal modes retain the resolve shader's existing contract.
inline float mode = 1.f;

inline bool UseObjectMotion() {
  return object_motion_enabled != 0.f || mode == 4.f;
}

// Native camera reprojection with optional rigid and skeletal motion replay.
struct __declspec(uuid("524af7c1-6944-46ca-875e-2acb70ec8f32")) DeviceData {
  Microsoft::WRL::ComPtr<IDirect3DTexture9> depth;
  Matrix camera = {};
  Matrix previous_camera = {};
  Matrix current_to_previous_clip = {};
  UINT width = 0, height = 0;
  UINT previous_width = 0, previous_height = 0;
  unsigned camera_draws = 0;
  unsigned frame = 0;
  bool conflicting_cameras = false;
  bool scene_seen = false;
  bool previous_valid = false;
  bool current_valid = false;
  ComPtr<IDirect3DSurface9> main_depth_surface;
  ComPtr<IDirect3DSurface9> main_color_surface;
  struct ProjectionShader {
    ComPtr<IDirect3DVertexShader9> shader;
    bool supported = false;
  };
  std::unordered_map<IDirect3DVertexShader9*, ProjectionShader> projection_shaders;
  ResolveResources resolve;
  std::unique_ptr<acbrotherhood::dlaa::State> dlaa;
  unsigned active_backend = 1;
  Matrix original_projection = {};
  std::array<float, 2> jitter = {}, previous_jitter = {};
  unsigned active_mode = 0;
  unsigned jitter_draws = 0, unsupported_draws = 0;
  bool jitter_applied = false;
  bool resolving = false;
  IDirect3DDevice9* draw_wrapper = nullptr;
  ULONGLONG scene_time = 0;
  MotionState object_motion;
  Performance performance;
  IDirect3DVertexBuffer9* up_vertices = nullptr;
  UINT up_stride = 0;
  IDirect3DIndexBuffer9* up_indices = nullptr;
  reshade::api::primitive_topology topology = reshade::api::primitive_topology::undefined;
  // Native MSAA uses a separate single-sample R32F depth prepass. Its DSV is
  // retained only for clear invalidation, never reused after a possible discard.
  ComPtr<IDirect3DTexture9> msaa_depth_texture;
  ComPtr<IDirect3DSurface9> msaa_depth_surface;
  unsigned msaa_depth_draws = 0;
  // Identities verified by the previous LUT input; contents are never reused.
  // Keep these across Present so the FIRST depth draw receives the same jitter
  // as the MSAA color pass. Current-frame capture still proves their validity.
  ComPtr<IDirect3DSurface9> verified_msaa_depth_target, verified_msaa_depth_surface;
  unsigned depth_jitter_draws = 0, msaa_depth_unjittered_draws = 0;
  D3DMULTISAMPLE_TYPE scene_samples = D3DMULTISAMPLE_NONE;
  struct DepthDraw {
    ComPtr<IDirect3DVertexBuffer9> vertices;
    ComPtr<IDirect3DIndexBuffer9> indices;
    Matrix clip;
    std::array<uint64_t, 2> writes;
  };
  std::unordered_multimap<MotionMesh, DepthDraw, MotionMeshHash> msaa_depth_geometry;
};

// Depth and material programs have different declarations/secondary streams,
// but share their position/index range. Pair that range AND its clip transform.
inline MotionMesh PositionMesh(MotionMesh mesh) {
  mesh.declaration = mesh.shader = mesh.secondary_vertices = mesh.secondary_offset = mesh.secondary_stride = 0;
  return mesh;
}

inline void OnBindVertexBuffers(reshade::api::command_list* cmd_list, uint32_t first, uint32_t count,
                                const reshade::api::resource* buffers, const uint64_t*, const uint32_t* strides) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9 || first != 0 || count == 0) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device());
  if (data == nullptr) return;
  data->up_vertices = nullptr;
  ComPtr<IDirect3DVertexBuffer9> current;
  UINT offset = 0, stride = 0;
  auto* native = reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native());
  if (buffers[0].handle != 0 && strides != nullptr && SUCCEEDED(native->GetStreamSource(0, &current, &offset, &stride))
      && reinterpret_cast<uintptr_t>(current.Get()) != buffers[0].handle) {
    data->up_vertices = reinterpret_cast<IDirect3DVertexBuffer9*>(buffers[0].handle);
    data->up_stride = strides[0];
  }
}

inline void OnBindIndexBuffer(reshade::api::command_list* cmd_list, reshade::api::resource buffer, uint64_t, uint32_t) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device());
  if (data == nullptr) return;
  data->up_indices = nullptr;
  ComPtr<IDirect3DIndexBuffer9> current;
  auto* native = reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native());
  if (buffer.handle != 0 && SUCCEEDED(native->GetIndices(&current))
      && reinterpret_cast<uintptr_t>(current.Get()) != buffer.handle) {
    data->up_indices = reinterpret_cast<IDirect3DIndexBuffer9*>(buffer.handle);
  }
}

// ReShade's generic indexed-draw event omits MinVertexIndex / NumVertices.
// Preserve that native range around its wrapper call so partial ring-buffer
// uploads can be validated without reading WRITEONLY index buffers.
struct IndexedGeometryRange {
  IDirect3DDevice9* wrapper = nullptr;
  INT base = 0;
  UINT min = 0, count = 0, first = 0, primitives = 0;
  D3DPRIMITIVETYPE topology = D3DPT_TRIANGLELIST;
};
inline thread_local IndexedGeometryRange indexed_geometry_range;

inline HRESULT STDMETHODCALLTYPE DrawIndexedGeometry(IDirect3DDevice9* wrapper, D3DPRIMITIVETYPE topology,
                                                       INT base, UINT min, UINT count, UINT first, UINT primitives) {
  const auto previous = indexed_geometry_range;
  indexed_geometry_range = {wrapper, base, min, count, first, primitives, topology};
  const HRESULT result = acbrotherhood::native_draw::Original<decltype(&DrawIndexedGeometry)>(wrapper, 82)(wrapper, topology, base, min, count, first, primitives);
  indexed_geometry_range = previous;
  return result;
}

inline void OnBindPipelineStates(reshade::api::command_list* cmd_list, uint32_t count,
                                 const reshade::api::dynamic_state* states, const uint32_t* values) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device());
  if (!data) return;
  for (uint32_t i = 0; i < count; ++i) {
    if (states[i] == reshade::api::dynamic_state::primitive_topology) data->topology = reshade::api::primitive_topology(values[i]);
  }
}

inline void OnMapGeometry(reshade::api::device* device, reshade::api::resource resource, uint64_t offset, uint64_t size,
                          reshade::api::map_access access, void** mapping) {
  if (device->get_api() != reshade::api::device_api::d3d9
      || access == reshade::api::map_access::read_only || offset > UINT_MAX || (size > UINT_MAX && size != UINT64_MAX)) return;
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (!data || data->resolving || !mapping || !*mapping) return;
  auto* native_resource = reinterpret_cast<IDirect3DResource9*>(resource.handle);
  const bool capture = UseObjectMotion() && (mode == 1.f || mode == 4.f);
  if (!capture && data->draw_wrapper) return;
  if (capture) {
    if (auto write = data->object_motion.buffer_writes.find(uintptr_t(resource.handle)); write != data->object_motion.buffer_writes.end())
      ++write->second;
  }
  if (native_resource->GetType() != D3DRTYPE_VERTEXBUFFER) return;
  // Only application-created buffers have this wrapper marker. ReShade's UP
  // emulation emits a map event with existing CPU vertex data, not a driver
  // mapping; redirecting that pointer would replace the vertices with stale data.
  constexpr GUID wrapper_guid = {0xf1006e9a, 0x1c51, 0x4af4, {0xac, 0xef, 0x36, 0x05, 0xd2, 0xd4, 0xc8, 0xee}};
  IDirect3DDevice9* wrapper = nullptr;
  DWORD bytes = sizeof(wrapper);
  const bool application_mapping = SUCCEEDED(native_resource->GetPrivateData(wrapper_guid, &wrapper, &bytes))
                                   && bytes == sizeof(wrapper) && wrapper;
  if (!data->draw_wrapper && application_mapping
      && acbrotherhood::native_draw::Install(wrapper, 82, reinterpret_cast<void*>(&DrawIndexedGeometry))) {
    data->draw_wrapper = wrapper;
    if (acbrotherhood::native_draw::InstallImmediate(wrapper, reinterpret_cast<IDirect3DDevice9*>(device->get_native())))
      reshade::log::message(reshade::log::level::info, "Brotherhood TAA: reset-safe immediate draw uploads installed.");
    else
      reshade::log::message(reshade::log::level::warning, "Brotherhood TAA: immediate draw upload hooks unavailable.");
  }
  if (!capture) return;
  data->object_motion.geometry->Map(static_cast<IDirect3DVertexBuffer9*>(native_resource), UINT(offset), UINT(size), *mapping,
                                    access == reshade::api::map_access::write_discard, application_mapping ? mapping : nullptr);
}

inline void OnUnmapGeometry(reshade::api::device* device, reshade::api::resource resource) {
  if (device->get_api() != reshade::api::device_api::d3d9) return;
  if (auto* data = renodx::utils::data::Get<DeviceData>(device); data && !data->resolving) data->object_motion.geometry->Unmap(uintptr_t(resource.handle));
}

inline void OnDestroyGeometry(reshade::api::device* device, reshade::api::resource resource) {
  if (device->get_api() != reshade::api::device_api::d3d9) return;
  if (auto* data = renodx::utils::data::Get<DeviceData>(device); data && !data->resolving) {
    data->object_motion.geometry->Retire(uintptr_t(resource.handle));
    data->object_motion.buffer_writes.erase(uintptr_t(resource.handle));
  }
}

inline constexpr auto CaptureObjectMotion = []<typename Context> requires ((Context::ArgumentType::COMMAND_TYPE & renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW) != 0)
    (Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if (!UseObjectMotion() || acbrotherhood::native_draw::immediate_draw_depth
      || context.cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return {};
  auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  if (!data || (data->active_mode != 1 && data->active_mode != 4) || data->scene_seen || data->resolving) return {};
  const MotionShader* profile = nullptr;
  for (const auto& shader : MOTION_SHADERS) if (shader.hash == context.matched_shader_hash) profile = &shader;
  if (!profile) return {};
  Performance::CpuScope timer(capture_enabled != 0.f ? &data->performance.cpu_ticks[Performance::CAPTURE] : nullptr);
  const auto reached = [&](unsigned stage) {
    ++data->object_motion.capture_stages[stage];
    ++data->object_motion.profile_stages[profile - MOTION_SHADERS][stage];
  };
  reached(0);
  if (!data->main_depth_surface || data->object_motion.current.size() >= 2048
      || data->topology != reshade::api::primitive_topology::triangle_list
      || context.arguments.instance_count != 1 || context.arguments.first_instance != 0) return {};
  reached(1);
  if (auto* up = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device()); up && up->up_vertices) return {};
  reached(2);
  auto* native = reinterpret_cast<IDirect3DDevice9*>(context.cmd_list->get_native());
  ComPtr<IDirect3DSurface9> depth, color;
  D3DSURFACE_DESC desc;
  D3DVIEWPORT9 viewport;
  BOOL deconstruction = TRUE;
  if (FAILED(native->GetDepthStencilSurface(&depth)) || depth != data->main_depth_surface) return {};
  reached(3);
  // Opaque scene submissions continue after MRT1 is detached. They still write
  // this exact scene color/depth pair; requiring the R32 attachment loses them.
  if (FAILED(native->GetRenderTarget(0, &color)) || !color || color != data->main_color_surface || FAILED(color->GetDesc(&desc))
      || !IsSceneFormat(desc.Format) || desc.Width != data->previous_width || desc.Height != data->previous_height
      || desc.MultiSampleType != data->scene_samples) return {};
  reached(4);
  if (FAILED(native->GetViewport(&viewport)) || viewport.X || viewport.Y
      || !std::isfinite(viewport.MinZ) || !std::isfinite(viewport.MaxZ)
      || viewport.MinZ < 0.f || viewport.MaxZ > 1.f || viewport.MinZ >= viewport.MaxZ
      || viewport.Width != desc.Width || viewport.Height != desc.Height
      || FAILED(native->GetVertexShaderConstantB(15, &deconstruction, 1)) || deconstruction) return {};
  DWORD value;
  MotionDraw draw;
  reached(5);
  for (const auto state : {D3DRS_SCISSORTESTENABLE, D3DRS_CLIPPLANEENABLE}) {
    if (FAILED(native->GetRenderState(state, &value)) || value != 0) return {};
  }
  if (!CaptureMotionRasterState(native, &draw)) return {};
  // The MSAA replay uses private depth and cannot reproduce native stencil.
  if (data->scene_samples != D3DMULTISAMPLE_NONE && draw.stencil_function != D3DCMP_ALWAYS) return {};
  // A color-only material pass may reuse an earlier depth prepass. Replay's
  // native EQUAL test still requires its geometry to be the visible surface.
  if (FAILED(native->GetRenderState(D3DRS_ZENABLE, &value)) || value != TRUE) return {};
  if (FAILED(native->GetRenderState(D3DRS_COLORWRITEENABLE, &value)) || (value & 7) != 7) return {};
  reached(6);
  ComPtr<IDirect3DPixelShader9> pixel;
  if (FAILED(native->GetPixelShader(&pixel)) || !pixel) return {};
  const auto& pixel_properties = GetMotionPixelShader(&data->object_motion, pixel);
  if (pixel_properties.clip_semantic != -1 && pixel_properties.clip_semantic != int(profile->clip_semantic)) return {};
  reached(7);
  UINT frequency = 0;
  draw.mesh.shader = context.matched_shader_hash;
  draw.skinned = profile->skinned;
  draw.packed_position = profile->packed_position;
  draw.wind = profile->wind;
  draw.displaced = profile->displaced;
  draw.tree = profile->tree;
  if (draw.tree) {
    if (FAILED(native->GetVertexShaderConstantF(95, draw.bones.data(), 125))
        || FAILED(native->GetVertexShaderConstantF(12, draw.tree_eye.data(), 1))) return {};
    for (unsigned reg = 95; reg < 220; ++reg) {
      const bool used = reg == 96 || reg == 120 || (reg >= 100 && reg <= 105)
                        || (draw.tree == 1 ? (reg >= 150 && reg <= 205) || (reg >= 207 && reg <= 211) : reg >= 213);
      for (unsigned component = 0; component < 4; ++component) {
        float& value = draw.bones[(reg - 95) * 4 + component];
        if (!used) value = 0.f;
        else if (!std::isfinite(value)) return {};
      }
    }
    for (float value : draw.tree_eye) if (!std::isfinite(value)) return {};
  }
  if (draw.displaced) {
    float displacement[4];
    if (FAILED(native->GetVertexShaderConstantF(100, displacement, 1)) || !std::isfinite(displacement[0])) return {};
    draw.displacement = displacement[0];
  }
  if (draw.wind) {
    if (FAILED(native->GetVertexShaderConstantF(13, draw.wind_origin.data(), 1))
        || FAILED(native->GetVertexShaderConstantF(100, draw.wind_constants.data(), 6))) return {};
    for (float component : draw.wind_origin) if (!std::isfinite(component)) return {};
    for (float component : draw.wind_constants) if (!std::isfinite(component)) return {};
  }
  if (draw.skinned || draw.packed_position) draw.alpha_uv_scale = {16.f, 16.f};
  if (profile->scaled_uv) {
    float scale[4];
    if (FAILED(native->GetVertexShaderConstantF(100, scale, 1)) || !std::isfinite(scale[0]) || !std::isfinite(scale[1])) return {};
    draw.alpha_uv_scale = {16.f * scale[0], 16.f * scale[1]};
  }
  if (FAILED(native->GetRenderState(D3DRS_ALPHATESTENABLE, &value))) return {};
  if (value || draw.translucent) {
    if (value) {
      if (FAILED(native->GetRenderState(D3DRS_ALPHAFUNC, &draw.alpha_function))
          || FAILED(native->GetRenderState(D3DRS_ALPHAREF, &draw.alpha_reference))
          || draw.alpha_function < D3DCMP_NEVER || draw.alpha_function > D3DCMP_ALWAYS || draw.alpha_reference > 255) return {};
    }
    if (draw.alpha_function != D3DCMP_ALWAYS || draw.translucent) {
      const auto& opacity = pixel_properties.opacity;
      if (opacity.sampler < 0 || opacity.sampler >= 16 || opacity.uv_semantic != profile->uv_semantic) return {};
      // Material opacity must use the audited color lane, not a clip-coordinate
      // lane that happens to share COLOR semantics in another vertex layout.
      if (opacity.vertex_alpha && (profile->color == MotionColor::CLIP || opacity.color_semantic != profile->color_semantic)) return {};
      draw.vertex_alpha = opacity.vertex_alpha && profile->color == MotionColor::VERTEX;
      draw.position_alpha = opacity.vertex_alpha && profile->color == MotionColor::POSITION;
      draw.saturate_alpha = opacity.saturate;
      draw.vertex_alpha_first = opacity.vertex_first;
      if (opacity.vertex_alpha && profile->color == MotionColor::WIND) {
        float distance[4], fade[12], lod[4];
        if (FAILED(native->GetVertexShaderConstantF(95, distance, 1)) || FAILED(native->GetVertexShaderConstantF(107, fade, 3))
            || FAILED(native->GetVertexShaderConstantF(30, lod, 1))) return {};
        draw.constant_vertex_alpha = std::clamp(distance[0] * fade[0] + fade[4], 0.f, 1.f) * std::clamp(lod[0] + fade[8], 0.f, 1.f);
        if (!std::isfinite(draw.constant_vertex_alpha)) return {};
      }
      if (opacity.constant >= 0) {
        float constant[4];
        if (FAILED(native->GetPixelShaderConstantF(opacity.constant / 4, constant, 1))
            || !std::isfinite(constant[opacity.constant % 4])) return {};
        draw.alpha_scale = constant[opacity.constant % 4];
      }
      if (opacity.final_constant >= 0) {
        float constant[4];
        if (FAILED(native->GetPixelShaderConstantF(opacity.final_constant / 4, constant, 1))
            || !std::isfinite(constant[opacity.final_constant % 4])) return {};
        draw.alpha_final_scale = constant[opacity.final_constant % 4];
      }
      for (unsigned component = 0; component < 2; ++component) if (opacity.uv_constants[component] >= 0) {
        float constant[4];
        const unsigned index = opacity.uv_constants[component];
        if (FAILED(native->GetPixelShaderConstantF(index / 4, constant, 1)) || !std::isfinite(constant[index % 4])) return {};
        draw.alpha_pixel_uv_scale[component] = constant[index % 4];
      }
      ComPtr<IDirect3DBaseTexture9> texture;
      D3DSURFACE_DESC alpha_desc;
      if (FAILED(native->GetTexture(opacity.sampler, &texture)) || !texture
          || FAILED(texture.As(&draw.alpha_texture)) || FAILED(draw.alpha_texture->GetLevelDesc(0, &alpha_desc))) return {};
      // Keep texture alpha in its audited normalized domain before modifiers.
      switch (alpha_desc.Format) {
        case D3DFMT_A8R8G8B8: case D3DFMT_X8R8G8B8: case D3DFMT_A8B8G8R8: case D3DFMT_X8B8G8R8:
        case D3DFMT_A8: case D3DFMT_A4R4G4B4: case D3DFMT_A1R5G5B5:
        case D3DFMT_DXT1: case D3DFMT_DXT3: case D3DFMT_DXT5: break;
        default: return {};
      }
      for (unsigned state = 1; state < draw.alpha_sampler_states.size(); ++state) {
        if (FAILED(native->GetSamplerState(opacity.sampler, D3DSAMPLERSTATETYPE(state), &draw.alpha_sampler_states[state]))) return {};
      }
    }
  }
  reached(8);
  if (FAILED(native->GetStreamSource(0, &draw.vertices, &draw.mesh.offset, &draw.mesh.stride)) || !draw.vertices || !draw.mesh.stride
      || FAILED(native->GetStreamSourceFreq(0, &frequency)) || frequency != 1
      || FAILED(native->GetVertexDeclaration(&draw.declaration)) || !draw.declaration) return {};
  D3DVERTEXBUFFER_DESC vertex_desc;
  if (FAILED(draw.vertices->GetDesc(&vertex_desc)) || vertex_desc.Size <= draw.mesh.offset) return {};
  if (draw.tree && (vertex_desc.Usage & D3DUSAGE_DYNAMIC)) return {};
  reached(9);
  UINT source_streams = 0;
  draw.motion_declaration = GetMotionDeclaration(native, &data->object_motion, draw.declaration.Get(), draw.skinned, draw.vertex_alpha, draw.displaced, (vertex_desc.Usage & D3DUSAGE_DYNAMIC) != 0, draw.tree, &source_streams);
  if (!draw.motion_declaration) return {};
  D3DVERTEXBUFFER_DESC secondary_desc = {};
  if (source_streams & 2u) {
    if (FAILED(native->GetStreamSource(1, &draw.secondary_vertices, &draw.mesh.secondary_offset, &draw.mesh.secondary_stride))
        || !draw.secondary_vertices || !draw.mesh.secondary_stride
        || FAILED(native->GetStreamSourceFreq(1, &frequency)) || frequency != 1
        || FAILED(draw.secondary_vertices->GetDesc(&secondary_desc)) || (secondary_desc.Usage & D3DUSAGE_DYNAMIC)
        || secondary_desc.Size <= draw.mesh.secondary_offset) return {};
    draw.mesh.secondary_vertices = reinterpret_cast<uintptr_t>(draw.secondary_vertices.Get());
  }
  reached(10);
  using Args = typename Context::ArgumentType;
  if constexpr (std::is_same_v<Args, renodx::utils::command_action::DrawIndexedArguments>) {
    draw.mesh.indexed = true;
    draw.mesh.count = context.arguments.index_count;
    draw.mesh.first = context.arguments.first_index;
    draw.mesh.base_vertex = context.arguments.vertex_offset;
    if (FAILED(native->GetIndices(&draw.indices)) || !draw.indices) return {};
    D3DINDEXBUFFER_DESC index_desc;
    if (FAILED(draw.indices->GetDesc(&index_desc)) || (index_desc.Usage & D3DUSAGE_DYNAMIC)) return {};
    const uint64_t index_size = index_desc.Format == D3DFMT_INDEX16 ? 2 : 4;
    if ((uint64_t(draw.mesh.first) + draw.mesh.count) * index_size > index_desc.Size) return {};
  } else {
    draw.mesh.count = context.arguments.vertex_count;
    draw.mesh.first = context.arguments.first_vertex;
  }
  if (!draw.mesh.count || draw.mesh.count % 3) return {};
  const int64_t available_vertices = (vertex_desc.Size - draw.mesh.offset) / draw.mesh.stride - int64_t(draw.mesh.base_vertex);
  if (available_vertices <= 0 || available_vertices > UINT_MAX) return {};
  draw.vertex_count = UINT(available_vertices);
  if (!draw.mesh.indexed && uint64_t(draw.mesh.first) + draw.mesh.count > draw.vertex_count) return {};
  if (vertex_desc.Usage & D3DUSAGE_DYNAMIC) {
    int64_t first_vertex = draw.mesh.first;
    UINT vertex_count = draw.mesh.count;
    if (draw.mesh.indexed) {
      const auto& range = indexed_geometry_range;
      if (!range.wrapper || range.wrapper != data->draw_wrapper || range.topology != D3DPT_TRIANGLELIST
          || range.base != draw.mesh.base_vertex || range.first != draw.mesh.first || uint64_t(range.primitives) * 3 != draw.mesh.count) {
        ++data->object_motion.mutable_misses;
        return {};
      }
      first_vertex = int64_t(range.base) + range.min;
      vertex_count = range.count;
      draw.vertex_min = range.min;
    }
    const int64_t begin = int64_t(draw.mesh.offset) + first_vertex * draw.mesh.stride;
    const uint64_t bytes = uint64_t(vertex_count) * draw.mesh.stride;
    if (first_vertex < 0 || begin < 0 || begin >= vertex_desc.Size || !bytes || bytes > vertex_desc.Size - begin || draw.vertex_min > INT_MAX) return {};
    if (draw.secondary_vertices) {
      const uint64_t secondary_begin = uint64_t(draw.mesh.secondary_offset) + uint64_t(first_vertex) * draw.mesh.secondary_stride;
      const uint64_t secondary_bytes = uint64_t(vertex_count) * draw.mesh.secondary_stride;
      if (secondary_begin >= secondary_desc.Size || secondary_bytes > secondary_desc.Size - secondary_begin) return {};
      draw.mesh.secondary_offset = UINT(secondary_begin);
    }
    draw.geometry = data->object_motion.geometry->Snapshot(native, draw.vertices.Get(), UINT(begin), UINT(bytes));
    if (!draw.geometry) { ++data->object_motion.mutable_misses; return {}; }
    draw.source_vertices = draw.vertices;
    draw.vertices = draw.geometry->vertices;
    draw.vertex_count = vertex_count;
    ++data->object_motion.mutable_draws;
  }
  draw.mesh.vertices = reinterpret_cast<uintptr_t>(draw.source_vertices ? draw.source_vertices.Get() : draw.vertices.Get());
  draw.mesh.indices = reinterpret_cast<uintptr_t>(draw.indices.Get());
  draw.mesh.declaration = reinterpret_cast<uintptr_t>(draw.declaration.Get());
  if (draw.geometry) {
    // Rotating upload buffers and offsets are storage, not object identity.
    // Static index topology plus the vertex layout/range identifies the mesh;
    // repeated instances still require an unambiguous pose match.
    draw.mesh.vertices = 0;
    draw.mesh.offset = draw.vertex_count;
    draw.mesh.base_vertex = INT(draw.vertex_min);
    if (!draw.mesh.indexed) draw.mesh.first = 0;
  }
  reached(11);
  std::array<std::array<float, 4>, 19> vertex_constants;
  if (FAILED(native->GetVertexShaderConstantF(0, vertex_constants[0].data(), UINT(vertex_constants.size())))
      || (draw.skinned && FAILED(native->GetVertexShaderConstantF(120, draw.bones.data(), 126)))) return {};
  std::memcpy(&draw.clip, vertex_constants[0].data(), sizeof(Matrix));
  std::memcpy(&draw.world, vertex_constants[8].data(), sizeof(Matrix));
  draw.clip_plane = vertex_constants[18];
  draw.unjittered_clip = data->jitter_applied ? data->original_projection : draw.clip;
  if (pixel_properties.clip_semantic == -1) draw.clip_plane = {0.f, 0.f, 0.f, -1.f};
  for (const auto& row : draw.world.m) for (float component : row) if (!std::isfinite(component)) return {};
  for (const auto& row : draw.clip.m) for (float component : row) if (!std::isfinite(component)) return {};
  for (float component : draw.clip_plane) if (!std::isfinite(component)) return {};
  if (draw.skinned) for (float component : draw.bones) if (!std::isfinite(component)) return {};
  if (draw.geometry && !draw.skinned && !draw.packed_position && !draw.wind && !draw.tree) {
    D3DVERTEXELEMENT9 elements[MAXD3DDECLLENGTH + 1];
    UINT count = std::size(elements);
    if (SUCCEEDED(draw.declaration->GetDeclaration(elements, &count))) {
      for (UINT i = 0; i < count; ++i) {
        const auto& element = elements[i];
        if (element.Stream != 0 || element.Usage != D3DDECLUSAGE_POSITION || element.UsageIndex != 0
            || (element.Type != D3DDECLTYPE_FLOAT3 && element.Type != D3DDECLTYPE_FLOAT4)
            || element.Offset + 3 * sizeof(float) > draw.mesh.stride) continue;
        // This immutable range contains the exact native float positions.
        // Average in double precision before transforming into world space;
        // large map coordinates otherwise introduce jitter in the anchor.
        if (!draw.vertex_count || size_t(draw.vertex_count) * draw.mesh.stride != draw.geometry->data.size()) return {};
        std::array<double, 3> center = {};
        for (UINT vertex = 0; vertex < draw.vertex_count; ++vertex) {
          float position[3];
          std::memcpy(position, draw.geometry->data.data() + size_t(vertex) * draw.mesh.stride + element.Offset, sizeof(position));
          for (unsigned component = 0; component < 3; ++component) {
            if (!std::isfinite(position[component])) return {};
            center[component] += position[component];
          }
        }
        for (double& component : center) component /= draw.vertex_count;
        draw.geometry_center.emplace();
        for (unsigned row = 0; row < 3; ++row) {
          (*draw.geometry_center)[row] = float(draw.world.m[row][0] * center[0] + draw.world.m[row][1] * center[1]
                                             + draw.world.m[row][2] * center[2] + draw.world.m[row][3]);
          if (!std::isfinite((*draw.geometry_center)[row])) return {};
        }
        break;
      }
    }
  }
  native->GetRenderState(D3DRS_CULLMODE, &draw.cull);
  native->GetRenderState(D3DRS_DEPTHBIAS, &draw.bias);
  native->GetRenderState(D3DRS_SLOPESCALEDEPTHBIAS, &draw.slope_bias);
  draw.min_depth = viewport.MinZ;
  draw.max_depth = viewport.MaxZ;
  if (!draw.skinned && !draw.wind && !draw.tree && !draw.displaced && !draw.geometry && !draw.translucent
      && draw.bias == 0 && draw.slope_bias == 0
      && data->camera_draws != 0 && !data->conflicting_cameras
      && pixel_properties.depth_color_semantic == int(1 - profile->color_semantic)) {
    ComPtr<IDirect3DSurface9> native_depth;
    ComPtr<IDirect3DTexture9> native_depth_texture;
    DWORD writes_depth = 0, writes_red = 0, blend = TRUE;
    bool scene_depth_available = false;
    if (data->scene_samples != D3DMULTISAMPLE_NONE && data->msaa_depth_draws >= 2 && data->depth == data->msaa_depth_texture) {
      const auto [first, last] = data->msaa_depth_geometry.equal_range(PositionMesh(draw.mesh));
      for (auto found = first; found != last; ++found) {
        if (std::memcmp(&found->second.clip, &draw.unjittered_clip, sizeof(Matrix)) != 0) continue;
        const auto vertices = data->object_motion.buffer_writes.find(draw.mesh.vertices);
        const auto indices = data->object_motion.buffer_writes.find(draw.mesh.indices);
        scene_depth_available = vertices != data->object_motion.buffer_writes.end() && vertices->second == found->second.writes[0]
            && (!draw.mesh.indexed || (indices != data->object_motion.buffer_writes.end() && indices->second == found->second.writes[1]));
        if (scene_depth_available) break;
      }
    } else if (data->scene_samples == D3DMULTISAMPLE_NONE) {
      scene_depth_available = SUCCEEDED(native->GetRenderTarget(1, &native_depth)) && native_depth
            && SUCCEEDED(native_depth->GetContainer(IID_PPV_ARGS(&native_depth_texture))) && native_depth_texture == data->depth
            && SUCCEEDED(native->GetRenderState(D3DRS_COLORWRITEENABLE1, &writes_red)) && (writes_red & D3DCOLORWRITEENABLE_RED);
    }
    draw.camera_static_candidate = scene_depth_available
        && SUCCEEDED(native->GetRenderState(D3DRS_ZWRITEENABLE, &writes_depth)) && writes_depth
        && SUCCEEDED(native->GetRenderState(D3DRS_ALPHABLENDENABLE, &blend)) && !blend;
    // Rigid positions use c8-c10, with an affine homogeneous row; c11 is not
    // consistently an affine row in the original vertex shaders.
    for (unsigned row = 0; row < 4 && draw.camera_static_candidate; ++row) {
      for (unsigned column = 0; column < 4; ++column) {
        double expected = column == 3 ? data->camera.m[row][3] : 0.;
        double magnitude = std::abs(expected);
        for (unsigned i = 0; i < 3; ++i) {
          const double term = double(data->camera.m[row][i]) * draw.world.m[i][column];
          expected += term;
          magnitude += std::abs(term);
        }
        if (std::abs(expected - draw.unjittered_clip.m[row][column]) > 2.e-5 * std::max(1., magnitude))
          draw.camera_static_candidate = false;
      }
    }
    if (draw.camera_static_candidate) {
      const std::array<uintptr_t, 3> buffers = {draw.mesh.vertices, draw.mesh.secondary_vertices, draw.mesh.indices};
      for (size_t i = 0; i < buffers.size(); ++i) if (buffers[i]) {
        auto write = data->object_motion.buffer_writes.find(buffers[i]);
        if (write == data->object_motion.buffer_writes.end() && data->object_motion.buffer_writes.size() < 4096)
          write = data->object_motion.buffer_writes.emplace(buffers[i], 0).first;
        if (write == data->object_motion.buffer_writes.end()) draw.camera_static_candidate = false;
        else draw.buffer_writes[i] = write->second;
      }
    }
  }
  data->object_motion.current.push_back(std::move(draw));
  reached(12);
  return {};
};

inline constexpr auto ApplyJitter = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if (acbrotherhood::native_draw::immediate_draw_depth
      || context.cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return {};
  auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  if (!data || data->active_mode != 1 || data->resolving || data->scene_seen || !data->previous_valid
      || !data->main_depth_surface || data->resolve.failed) return {};
  Performance::CpuScope timer(capture_enabled != 0.f ? &data->performance.cpu_ticks[Performance::JITTER] : nullptr);
  if (auto* up = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device()); up && up->up_vertices) return {};
  auto* native = reinterpret_cast<IDirect3DDevice9*>(context.cmd_list->get_native());
  ComPtr<IDirect3DSurface9> depth, color;
  D3DSURFACE_DESC color_desc;
  D3DVIEWPORT9 viewport;
  DWORD depth_enabled = 0;
  if (FAILED(native->GetDepthStencilSurface(&depth)) || !depth
      || (depth != data->main_depth_surface
          && (data->scene_samples == D3DMULTISAMPLE_NONE || depth != data->verified_msaa_depth_surface))
      || FAILED(native->GetRenderTarget(0, &color)) || !color) return {};
  const bool depth_prepass = data->scene_samples != D3DMULTISAMPLE_NONE
                             && depth == data->verified_msaa_depth_surface && color == data->verified_msaa_depth_target;
  if (!depth_prepass && (depth != data->main_depth_surface || color != data->main_color_surface)) return {};
  // Never jitter only the color pass if the verified prepass was skipped,
  // replaced or cleared this frame. Such frames reacquire the pass identities.
  if (!depth_prepass && data->scene_samples != D3DMULTISAMPLE_NONE
      && (data->msaa_depth_draws < 2 || data->msaa_depth_unjittered_draws || !data->depth_jitter_draws)) return {};
  if (FAILED(color->GetDesc(&color_desc))
      || color_desc.MultiSampleType != (depth_prepass ? D3DMULTISAMPLE_NONE : data->scene_samples)
      || FAILED(native->GetViewport(&viewport)) || viewport.X != 0 || viewport.Y != 0
      || viewport.Width != data->previous_width || viewport.Height != data->previous_height
      || FAILED(native->GetRenderState(D3DRS_ZENABLE, &depth_enabled)) || !depth_enabled) return {};
  // Native Draw*UP needs separate replay handling; leave those paths untouched.
  ComPtr<IDirect3DVertexBuffer9> vertices;
  UINT offset, stride;
  if (FAILED(native->GetStreamSource(0, &vertices, &offset, &stride)) || !vertices) return {};
  ComPtr<IDirect3DVertexShader9> shader;
  if (FAILED(native->GetVertexShader(&shader)) || !shader) return {};
  auto found = data->projection_shaders.find(shader.Get());
  if (found == data->projection_shaders.end()) {
    UINT size = 0;
    if (FAILED(shader->GetFunction(nullptr, &size)) || size == 0 || size % sizeof(DWORD)) return {};
    std::vector<DWORD> code(size / sizeof(DWORD));
    if (FAILED(shader->GetFunction(code.data(), &size))) return {};
    if (data->projection_shaders.size() >= 512) data->projection_shaders.clear();
    found = data->projection_shaders.emplace(shader.Get(), DeviceData::ProjectionShader{shader, HasProjection(code)}).first;
  }
  if (!found->second.supported) {
    ++data->unsupported_draws;
    return {};
  }
  if (FAILED(native->GetVertexShaderConstantF(0, &data->original_projection.m[0][0], 4))) return {};
  Matrix jittered = data->original_projection;
  for (unsigned column = 0; column < 4; ++column) {
    jittered.m[0][column] += 2.f * data->jitter[0] / viewport.Width * jittered.m[3][column];
    jittered.m[1][column] -= 2.f * data->jitter[1] / viewport.Height * jittered.m[3][column];
  }
  if (FAILED(native->SetVertexShaderConstantF(0, &jittered.m[0][0], 4))) return {};
  data->jitter_applied = true;
  if (depth_prepass) ++data->depth_jitter_draws;
  else ++data->jitter_draws;
  return {.post_callback = [](Context& context, const void*) {
    auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
    Performance::CpuScope timer(capture_enabled != 0.f ? &data->performance.cpu_ticks[Performance::JITTER] : nullptr);
    reinterpret_cast<IDirect3DDevice9*>(context.cmd_list->get_native())->SetVertexShaderConstantF(0, &data->original_projection.m[0][0], 4);
    data->jitter_applied = false;
  }};
};

inline void OnInitDevice(reshade::api::device* device) {
  if (device->get_api() == reshade::api::device_api::d3d9) renodx::utils::data::Create<DeviceData>(device);
}

inline void OnDestroyDevice(reshade::api::device* device) {
  if (device->get_api() != reshade::api::device_api::d3d9) return;
  if (auto* data = renodx::utils::data::Get<DeviceData>(device)) {
    data->resolving = true;
    if (data->draw_wrapper) acbrotherhood::native_draw::Uninstall(data->draw_wrapper);
  }
  renodx::utils::data::Delete<DeviceData>(device);
}

inline void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  // Release every default-pool reference before native Reset, including when
  // no Present occurs between a material draw and a graphics settings change.
  if (auto* data = renodx::utils::data::Get<DeviceData>(swapchain->get_device())) {
    const auto topology = data->topology;
    auto* wrapper = data->draw_wrapper;
    acbrotherhood::native_draw::ResetImmediate(wrapper);
    *data = {};
    data->draw_wrapper = wrapper;
    // D3D9 passes topology with each draw; ReShade may only announce changes.
    data->topology = topology;
  }
}

// Audited PS 65A612BE writes interpolated clip.z / clip.w to COLOR0.xyz.
// It also occurs in shadows, so require an R32F texture and matching 1x DSV.
// The later MSAA camera anchor and LUT must bind this exact texture at s8.
inline constexpr auto CaptureMsaaDepth = []<typename Context> requires ((Context::ArgumentType::COMMAND_TYPE & renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW) != 0)
    (Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if ((capture_enabled == 0.f && mode == 0.f) || context.cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return {};
  auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  if (!data || data->resolving || data->scene_seen) return {};
  auto* native = reinterpret_cast<IDirect3DDevice9*>(context.cmd_list->get_native());
  ComPtr<IDirect3DSurface9> target, depth;
  ComPtr<IDirect3DTexture9> texture;
  D3DSURFACE_DESC desc, depth_desc;
  D3DVIEWPORT9 viewport;
  DWORD enabled = 0, writes = 0;
  if (FAILED(native->GetRenderTarget(0, &target)) || !target || FAILED(target->GetDesc(&desc))
      || desc.Format != D3DFMT_R32F || desc.MultiSampleType != D3DMULTISAMPLE_NONE
      || FAILED(target->GetContainer(IID_PPV_ARGS(&texture)))
      || FAILED(native->GetDepthStencilSurface(&depth)) || !depth || FAILED(depth->GetDesc(&depth_desc))
      || depth_desc.MultiSampleType != D3DMULTISAMPLE_NONE || depth_desc.Width != desc.Width || depth_desc.Height != desc.Height
      || FAILED(native->GetViewport(&viewport)) || viewport.X || viewport.Y || viewport.Width != desc.Width || viewport.Height != desc.Height
      || FAILED(native->GetRenderState(D3DRS_ZENABLE, &enabled)) || !enabled
      || FAILED(native->GetRenderState(D3DRS_ZWRITEENABLE, &writes)) || !writes) return {};
  if (texture != data->msaa_depth_texture || depth != data->msaa_depth_surface) {
    data->msaa_depth_draws = 0;
    data->msaa_depth_unjittered_draws = 0;
    data->msaa_depth_geometry.clear();
  }
  data->msaa_depth_texture = texture;
  data->msaa_depth_surface = depth;
  ++data->msaa_depth_draws;
  if (!data->jitter_applied) ++data->msaa_depth_unjittered_draws;
  // Only a draw proven present in this prepass may use the static replay
  // omission. Later color-only meshes still need vectors to supply their depth.
  if (!UseObjectMotion() || data->msaa_depth_geometry.size() >= 2048
      || data->object_motion.buffer_writes.size() >= 4094 || data->up_vertices || acbrotherhood::native_draw::immediate_draw_depth
      || data->topology != reshade::api::primitive_topology::triangle_list
      || context.arguments.instance_count != 1 || context.arguments.first_instance != 0) return {};
  DeviceData::DepthDraw draw;
  MotionMesh mesh;
  D3DVERTEXBUFFER_DESC vertex_desc;
  UINT frequency = 0;
  if (FAILED(native->GetStreamSource(0, &draw.vertices, &mesh.offset, &mesh.stride)) || !draw.vertices
      || FAILED(draw.vertices->GetDesc(&vertex_desc)) || (vertex_desc.Usage & D3DUSAGE_DYNAMIC)
      || FAILED(native->GetStreamSourceFreq(0, &frequency)) || frequency != 1
      || FAILED(native->GetVertexShaderConstantF(0, &draw.clip.m[0][0], 4))) return {};
  // Static omission compares physical transforms, not the temporal sample.
  if (data->jitter_applied) draw.clip = data->original_projection;
  mesh.vertices = reinterpret_cast<uintptr_t>(draw.vertices.Get());
  if constexpr (Context::ArgumentType::COMMAND_TYPE == renodx::utils::command_action::COMMAND_TYPE_DRAW_INDEXED) {
    mesh.indexed = true;
    mesh.count = context.arguments.index_count;
    mesh.first = context.arguments.first_index;
    mesh.base_vertex = context.arguments.vertex_offset;
    D3DINDEXBUFFER_DESC index_desc;
    if (FAILED(native->GetIndices(&draw.indices)) || !draw.indices || FAILED(draw.indices->GetDesc(&index_desc))
        || (index_desc.Usage & D3DUSAGE_DYNAMIC)) return {};
    mesh.indices = reinterpret_cast<uintptr_t>(draw.indices.Get());
    draw.writes[1] = data->object_motion.buffer_writes.try_emplace(mesh.indices, 0).first->second;
  } else {
    mesh.count = context.arguments.vertex_count;
    mesh.first = context.arguments.first_vertex;
  }
  draw.writes[0] = data->object_motion.buffer_writes.try_emplace(mesh.vertices, 0).first->second;
  data->msaa_depth_geometry.emplace(PositionMesh(mesh), std::move(draw));
  return {};
};

inline bool OnClearDepth(reshade::api::command_list* cmd_list, reshade::api::resource_view view,
                         const float* depth, const uint8_t*, uint32_t, const reshade::api::rect*) {
  if (depth && cmd_list->get_device()->get_api() == reshade::api::device_api::d3d9) {
    if (auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device()); data && !data->resolving
        && view.handle == reinterpret_cast<uintptr_t>(data->msaa_depth_surface.Get())) {
      data->msaa_depth_draws = 0;
      data->depth_jitter_draws = data->msaa_depth_unjittered_draws = 0;
      data->msaa_depth_geometry.clear();
    }
  }
  return false;
}

inline constexpr auto CaptureCamera = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if ((capture_enabled == 0.f && mode == 0.f) || context.cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return {};
  auto* data = renodx::utils::data::Get<DeviceData>(context.cmd_list->get_device());
  if (data == nullptr || data->scene_seen || data->conflicting_cameras) return {};
  Performance::CpuScope timer(capture_enabled != 0.f ? &data->performance.cpu_ticks[Performance::CAMERA] : nullptr);
  auto* native = reinterpret_cast<IDirect3DDevice9*>(context.cmd_list->get_native());
  Microsoft::WRL::ComPtr<IDirect3DSurface9> color, depth;
  D3DSURFACE_DESC color_desc = {}, depth_desc = {};
  BOOL deconstruction = TRUE;
  if (FAILED(native->GetRenderTarget(0, &color)) || !color || FAILED(color->GetDesc(&color_desc))
      || !IsSceneFormat(color_desc.Format)
      || FAILED(native->GetVertexShaderConstantB(15, &deconstruction, 1)) || deconstruction) return {};

  Microsoft::WRL::ComPtr<IDirect3DTexture9> depth_texture;
  if (color_desc.MultiSampleType == D3DMULTISAMPLE_NONE) {
    if (FAILED(native->GetRenderTarget(1, &depth)) || !depth || FAILED(depth->GetDesc(&depth_desc))
        || FAILED(depth->GetContainer(IID_PPV_ARGS(&depth_texture)))) return {};
  } else {
    ComPtr<IDirect3DBaseTexture9> bound;
    if (data->msaa_depth_draws < 2 || !data->msaa_depth_texture || !data->msaa_depth_surface
        || FAILED(native->GetTexture(8, &bound)) || bound.Get() != data->msaa_depth_texture.Get()
        || FAILED(data->msaa_depth_texture->GetLevelDesc(0, &depth_desc))) return {};
    depth_texture = data->msaa_depth_texture;
  }
  if (depth_desc.Format != D3DFMT_R32F || depth_desc.MultiSampleType != D3DMULTISAMPLE_NONE
      || color_desc.Width != depth_desc.Width || color_desc.Height != depth_desc.Height) return {};

  Matrix world, world_view_projection, camera, inverse_camera;
  if (FAILED(native->GetVertexShaderConstantF(0, &world_view_projection.m[0][0], 4))
      || FAILED(native->GetVertexShaderConstantF(8, &world.m[0][0], 4))) return {};
  if (data->jitter_applied) world_view_projection = data->original_projection;
  if (!MultiplyByInverse(world_view_projection, world, &camera) || !Invert(camera, &inverse_camera)) return {};

  if (data->camera_draws != 0 && (data->depth.Get() != depth_texture.Get() || !SameCamera(data->camera, camera))) {
    data->conflicting_cameras = true;
    return {};
  }
  data->camera = camera;
  data->depth = depth_texture;
  data->width = color_desc.Width;
  data->height = color_desc.Height;
  if (data->scene_samples != color_desc.MultiSampleType || (data->main_color_surface && data->main_color_surface != color)) {
    data->previous_valid = false;
    data->resolve.valid = false;
    data->object_motion.current.clear();
    data->object_motion.previous.clear();
    // A prepass may already have used this frame's jitter. Preserve that fact
    // until OnScene can reject an incomplete pair; never relabel it as zero.
    data->previous_jitter = {};
  }
  data->scene_samples = color_desc.MultiSampleType;
  ++data->camera_draws;
  native->GetDepthStencilSurface(data->main_depth_surface.ReleaseAndGetAddressOf());
  data->main_color_surface = color;
  return {};
};

inline void OnScene(reshade::api::command_list* cmd_list) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  auto* native = reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native());
  // on_drawn makes command_action replay this draw. For native Draw*UP,
  // ReShade exposes the uploaded vertices through an event but does not bind
  // that temporary buffer. Bind it even with TAA Off, before state capture.
  if (auto* up = renodx::utils::data::Get<DeviceData>(cmd_list->get_device()); up && up->up_vertices) {
    native->SetStreamSource(0, up->up_vertices, 0, up->up_stride);
    if (up->up_indices) native->SetIndices(up->up_indices);
  }
  auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device());
  if (data == nullptr) return;
  if (capture_enabled == 0.f && mode == 0.f) {
    const auto topology = data->topology;
    auto* wrapper = data->draw_wrapper;
    *data = {};
    data->draw_wrapper = wrapper;
    data->topology = topology;
    return;
  }
  // A second scene pass is ambiguous; never reuse a first pass's camera.
  if (data->scene_seen) {
    data->current_valid = false;
    return;
  }
  data->scene_seen = true;
  Microsoft::WRL::ComPtr<IDirect3DBaseTexture9> scene, bound_depth;
  Microsoft::WRL::ComPtr<IDirect3DTexture9> scene_texture;
  D3DSURFACE_DESC desc = {};
  Matrix inverse_camera;
  // s8 is stale with respect to the LUT shader, but this capture proves it is
  // exactly the R32 MRT written by the verified material draws this frame.
  data->current_valid = data->camera_draws >= 2 && !data->conflicting_cameras
                        && (data->scene_samples == D3DMULTISAMPLE_NONE || data->msaa_depth_draws >= 2)
                        && (!(data->depth_jitter_draws || (data->scene_samples != D3DMULTISAMPLE_NONE && data->jitter_draws))
                            || (data->scene_samples != D3DMULTISAMPLE_NONE && data->depth_jitter_draws && data->jitter_draws
                                && !data->msaa_depth_unjittered_draws))
                        && SUCCEEDED(native->GetTexture(0, &scene)) && scene
                        && SUCCEEDED(scene.As(&scene_texture))
                        && SUCCEEDED(scene_texture->GetLevelDesc(0, &desc))
                        && IsSceneFormat(desc.Format)
                        && desc.Width == data->width && desc.Height == data->height
                        && SUCCEEDED(native->GetTexture(8, &bound_depth))
                        && bound_depth.Get() == data->depth.Get()
                        && Invert(data->camera, &inverse_camera);
  // A new target may have bypassed ApplyJitter. Resolve and motion replay must
  // use the actual sample offset, including the unjittered warm-up frame.
  if (!data->jitter_draws && !data->depth_jitter_draws) data->jitter = {};
  data->current_to_previous_clip = {};
  const ULONGLONG now = GetTickCount64();
  const bool pair_valid = data->current_valid && data->previous_valid && now - data->scene_time < 250
                          && data->width == data->previous_width && data->height == data->previous_height
                          && MultiplyByInverse(data->previous_camera, data->camera, &data->current_to_previous_clip);
  data->scene_time = now;
  // Test projected points, not matrix coefficients: lateral camera translation
  // can make coefficients large while distant geometry barely moves on screen.
  bool continuous = pair_valid;
  if (continuous) {
    for (const float corner : {-0.5f, 0.f, 0.5f}) {
      float projected[4] = {};
      for (unsigned row = 0; row < 4; ++row) {
        projected[row] = data->current_to_previous_clip.m[row][0] * corner
                         + data->current_to_previous_clip.m[row][1] * corner
                         + data->current_to_previous_clip.m[row][2] * 0.99f
                         + data->current_to_previous_clip.m[row][3];
      }
      if (projected[3] <= 1.e-6f || std::abs(projected[0] / projected[3] - corner) > 1.5f
          || std::abs(projected[1] / projected[3] - corner) > 1.5f) continuous = false;
    }
  }
  if (data->current_valid && data->active_mode != 0) {
    data->resolving = true;
    if (capture_enabled != 0.f) data->performance.BeginGpu(native);
    data->object_motion.ready = false;
    if (UseObjectMotion() && (data->active_mode == 1 || data->active_mode == 4)) {
      Performance::CpuScope timer(capture_enabled != 0.f ? &data->performance.cpu_ticks[Performance::MOTION] : nullptr);
      RenderObjectMotion(native, &data->object_motion, data->main_depth_surface.Get(),
                         data->width, data->height, data->jitter, continuous,
                         data->scene_samples != D3DMULTISAMPLE_NONE ? data->depth.Get() : nullptr);
    }
    if (capture_enabled != 0.f) data->performance.EndMotionGpu();
    {
      Performance::CpuScope timer(capture_enabled != 0.f ? &data->performance.cpu_ticks[Performance::RESOLVE] : nullptr);
      const bool capture_inputs = data->active_mode == 1 && dump_resolve != 0.f;
      if (capture_inputs) dump_resolve = 0.f;
      Matrix sky_reprojection = data->current_to_previous_clip;
      SkyReprojection(data->previous_camera, data->camera, &sky_reprojection);
      bool resolved = false;
      const auto previous_dlaa_status = acbrotherhood::dlaa::status.load();
      if (data->active_backend == 2) {
        if (data->scene_samples != D3DMULTISAMPLE_NONE || data->active_mode != 1
            || (confidence_preview != 0.f && confidence_preview != 3.f)) {
          data->dlaa.reset();
          acbrotherhood::dlaa::status = data->scene_samples != D3DMULTISAMPLE_NONE
                                          ? acbrotherhood::dlaa::Status::msaa : acbrotherhood::dlaa::Status::diagnostic;
        } else {
          resolved = acbrotherhood::dlaa::Resolve(native, &data->dlaa, scene_texture.Get(), data->depth.Get(),
                        data->object_motion.ready ? data->object_motion.resources.texture.Get() : nullptr,
                        data->current_to_previous_clip, sky_reprojection, data->width, data->height,
                        data->jitter, data->frame, continuous, confidence_preview == 3.f, rcas_strength);
          // Release native TAA history once DLAA takes over. Recreate it only
          // if the helper fails or the selected mode needs the TAA fallback.
          if (resolved) data->resolve = {};
        }
      }
      if (previous_dlaa_status != acbrotherhood::dlaa::status.load()) {
        std::ostringstream message;
        message << "Brotherhood DLAA: " << acbrotherhood::dlaa::StatusText()
                << " stage=" << acbrotherhood::dlaa::error_stage << " error=0x" << std::hex << acbrotherhood::dlaa::error_code;
        reshade::log::message(reshade::log::level::info, message.str().c_str());
      }
      if (!resolved && !Resolve(native, &data->resolve, scene_texture.Get(), data->depth.Get(), data->current_to_previous_clip,
                 data->width, data->height, data->jitter, data->previous_jitter,
                 data->active_mode == 1 ? continuous : pair_valid, data->active_mode,
                 data->object_motion.ready ? data->object_motion.resources.texture.Get() : nullptr,
                 unsigned(confidence_preview), capture_inputs, &sky_reprojection, data->scene_samples != D3DMULTISAMPLE_NONE, rcas_strength)) {
        if (data->frame % 120 == 0) reshade::log::message(reshade::log::level::warning, "Brotherhood TAA: resolve failed; retaining native scene.");
      }
      if (capture_inputs)
        reshade::log::message(data->resolve.capture_succeeded ? reshade::log::level::info : reshade::log::level::warning,
                             data->resolve.capture_succeeded ? "Brotherhood TAA: resolve capture complete in renodx-dev/taa-capture."
                                                             : "Brotherhood TAA: resolve capture failed; incomplete files must not be replayed.");
    }
    if (capture_enabled != 0.f) data->performance.EndGpu();
    data->resolving = false;
  } else {
    data->resolve.valid = false;
  }
  if (capture_enabled != 0.f) ++data->performance.frames;
  if (data->frame % 120 == 0) {
    std::ostringstream message;
    message << "Brotherhood TAA input capture: draws=" << data->camera_draws << " cameraConflict=" << data->conflicting_cameras
            << " current=" << data->current_valid << " consecutivePair=" << pair_valid
            << " size=" << data->width << 'x' << data->height << " jitterDraws=" << data->jitter_draws
            << " msaa=" << unsigned(data->scene_samples) << " depthPrepass=" << data->msaa_depth_draws
            << " depthJitter=" << data->depth_jitter_draws << " depthUnjittered=" << data->msaa_depth_unjittered_draws
            << " unsupportedDraws=" << data->unsupported_draws << " resolve=" << data->resolve.valid
            << " historyPair=" << continuous << " objectDraws=" << data->object_motion.current.size()
            << " rootMotion=" << data->object_motion.root_motion_draws
            << " cameraOnlyDraws=" << data->object_motion.camera_only_draws
            << " rigidMotion=" << data->object_motion.matched_rigid << " skinMotion=" << data->object_motion.matched_skin
            << " unmatchedMotion=" << data->object_motion.unmatched << " motionReady=" << data->object_motion.ready << " motionStages=";
    for (unsigned count : data->object_motion.capture_stages) message << count << ',';
    message << " motionMatchMiss=" << data->object_motion.rejected_matches[0] << ',' << data->object_motion.rejected_matches[1];
    message << " mutableDraws=" << data->object_motion.mutable_draws << " mutableMiss=" << data->object_motion.mutable_misses
            << " geometryBytes=" << data->object_motion.geometry->gpu_bytes->load()
            << " uploadShadowBytes=" << data->object_motion.geometry->upload_bytes
            << " uploadBytes(redirected,direct)=" << data->object_motion.geometry->redirected_upload_bytes
            << ',' << data->object_motion.geometry->direct_capture_bytes;
    message << " motionShaderCache=" << data->object_motion.pixel_shaders.size()
            << " shaderParses=" << data->object_motion.shader_cache_misses
            << " paletteRows=" << data->object_motion.resources.palette_height;
    if (capture_enabled != 0.f) {
      message << " cpuMs(capture,jitter,camera,motion,resolve)=";
      for (unsigned stage = 0; stage < Performance::CPU_STAGE_COUNT; ++stage)
        message << data->performance.CpuMilliseconds(Performance::CpuStage(stage)) << ',';
      message << " gpuSamples=" << data->performance.gpu_frames;
      if (data->performance.gpu_frames)
        message << " gpuMs(motion,resolve)=" << data->performance.motion_gpu_ms / data->performance.gpu_frames
                << ',' << data->performance.resolve_gpu_ms / data->performance.gpu_frames;
      data->performance.ResetTotals();
    }
    if (capture_enabled != 0.f && data->active_mode == 4) {
      for (size_t i = 0; i < std::size(MOTION_SHADERS); ++i) {
        const auto& stages = data->object_motion.profile_stages[i];
        if (!stages[0]) continue;
        message << " motionProfile[" << std::hex << MOTION_SHADERS[i].hash << std::dec << "]=";
        for (unsigned count : stages) message << count << ',';
      }
      unsigned samples = 0;
      for (size_t i = 0; i < data->object_motion.matches.size() && samples < 3; ++i) if (data->object_motion.matches[i] < 0) {
        const auto& draw = data->object_motion.current[i];
        unsigned old_mesh = 0, old_world = 0, new_mesh = 0, new_world = 0;
        for (const auto& pose : data->object_motion.previous) if (pose.mesh == draw.mesh) { ++old_mesh; if (SameMotionWorld(draw, pose)) ++old_world; }
        for (const auto& pose : data->object_motion.current) if (pose.mesh == draw.mesh) { ++new_mesh; if (SameMotionWorld(draw, pose)) ++new_world; }
        message << " unmatched[" << std::hex << draw.mesh.shader << std::dec << "]=" << new_mesh << '/' << old_mesh << '/' << new_world << '/' << old_world;
        ++samples;
      }
    }
    message << " cameraRows=";
    for (const auto& row : data->camera.m) for (const auto value : row) message << value << ',';
    reshade::log::message(reshade::log::level::info, message.str().c_str());
  }
  data->depth.Reset();
}

inline void OnPresent(reshade::api::command_queue*, reshade::api::swapchain* swapchain,
                      const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  auto* data = renodx::utils::data::Get<DeviceData>(swapchain->get_device());
  if (!data) return;
  mode = enabled == 0.f ? 0.f : debug_view == 1.f ? 2.f : 1.f;
  confidence_preview = enabled == 0.f ? 0.f : debug_view == 2.f ? 3.f
                        : debug_view == 3.f ? 1.f : debug_view == 4.f ? 2.f : 0.f;
  if (capture_enabled == 0.f) data->performance = {};
  RestoreScene(reinterpret_cast<IDirect3DDevice9*>(swapchain->get_device()->get_native()), &data->resolve);
  if (data->dlaa) data->dlaa->RestoreScene(reinterpret_cast<IDirect3DDevice9*>(swapchain->get_device()->get_native()));
  data->previous_valid = (capture_enabled != 0.f || mode != 0.f) && data->scene_seen && data->current_valid;
  data->previous_camera = data->camera;
  data->previous_width = data->width;
  data->previous_height = data->height;
  data->verified_msaa_depth_target.Reset();
  data->verified_msaa_depth_surface.Reset();
  if (data->previous_valid && data->scene_samples != D3DMULTISAMPLE_NONE && data->msaa_depth_texture) {
    data->msaa_depth_texture->GetSurfaceLevel(0, &data->verified_msaa_depth_target);
    data->verified_msaa_depth_surface = data->msaa_depth_surface;
  }
  data->depth.Reset();
  data->camera_draws = 0;
  data->msaa_depth_texture.Reset();
  data->msaa_depth_surface.Reset();
  data->msaa_depth_draws = 0;
  data->depth_jitter_draws = data->msaa_depth_unjittered_draws = 0;
  data->msaa_depth_geometry.clear();
  data->object_motion.current.swap(data->object_motion.previous);
  data->object_motion.current.clear();
  data->object_motion.capture_stages = {};
  data->object_motion.profile_stages = {};
  data->object_motion.mutable_draws = data->object_motion.mutable_misses = 0;
  data->object_motion.shader_cache_misses = 0;
  data->object_motion.geometry->Retire();
  data->scene_seen = data->current_valid = data->conflicting_cameras = false;
  data->previous_jitter = data->jitter_draws != 0 ? data->jitter : std::array<float, 2>{};
  data->jitter_draws = data->unsupported_draws = 0;
  if (data->active_mode != unsigned(mode) || data->active_backend != unsigned(enabled)) {
    data->resolve = {};
    data->dlaa.reset();
    acbrotherhood::dlaa::status = acbrotherhood::dlaa::Status::idle;
    data->object_motion = {};
    data->previous_valid = false;
    data->active_mode = unsigned(mode);
    data->active_backend = unsigned(enabled);
  }
  if (!UseObjectMotion()) data->object_motion = {};
  ++data->frame;
  data->jitter = data->active_mode == 1 && data->previous_valid && !data->resolve.failed
                     ? Jitter(data->frame) : std::array<float, 2>{};
  // MSAA already samples geometric coverage across the pixel. A half-sized
  // temporal footprint adds eight shading phases without as much resampling
  // blur on its resolved thin edges. Both passes consume this exact value.
  if (data->scene_samples != D3DMULTISAMPLE_NONE) for (float& offset : data->jitter) offset *= 0.5f;
}

inline void OnSceneDrawn(reshade::api::command_list* cmd_list) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  if (auto* data = renodx::utils::data::Get<DeviceData>(cmd_list->get_device())) {
    RestoreScene(reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native()), &data->resolve);
    if (data->dlaa) data->dlaa->RestoreScene(reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native()));
  }
  if (auto* up = renodx::utils::data::Get<DeviceData>(cmd_list->get_device()); up && up->up_vertices) {
    auto* native = reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native());
    native->SetStreamSource(0, nullptr, 0, 0);
    if (up->up_indices) native->SetIndices(nullptr);
    up->up_vertices = nullptr;
    up->up_indices = nullptr;
  }
}

// command_action runs vertex callbacks before pixel callbacks across addons.
// Resolve the LUT input before any HDR replacement is selected, in either DLL
// load order. The original or HDR LUT shader still performs the actual draw.
inline constexpr auto OnLut = []<typename Context>(Context& context) -> renodx::utils::command_action::CallbackResult<Context> {
  if ((mode == 0.f && capture_enabled == 0.f)
      || context.cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9
      || renodx::utils::shader::GetCurrentPixelShaderHash(renodx::utils::command_action::GetShaderState(&context)) != 0x48DCE479u) return {};
  OnScene(context.cmd_list);
  return {.post_callback = [](Context& context, const void*) { OnSceneDrawn(context.cmd_list); }};
};

inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    renodx::utils::shader::Use(reason);
    reshade::register_event<reshade::addon_event::bind_vertex_buffers>(OnBindVertexBuffers);
    reshade::register_event<reshade::addon_event::bind_index_buffer>(OnBindIndexBuffer);
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::register_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::register_event<reshade::addon_event::present>(OnPresent);
    reshade::register_event<reshade::addon_event::bind_pipeline_states>(OnBindPipelineStates);
    reshade::register_event<reshade::addon_event::map_buffer_region>(OnMapGeometry);
    reshade::register_event<reshade::addon_event::unmap_buffer_region>(OnUnmapGeometry);
    reshade::register_event<reshade::addon_event::destroy_resource>(OnDestroyGeometry);
    reshade::register_event<reshade::addon_event::clear_depth_stencil_view>(OnClearDepth);
    renodx::utils::command_action::Register(ApplyJitter, {.command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});
    renodx::utils::command_action::Register(CaptureCamera, {
        .shader_hash = 0x4B000956u,
        .command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});
    renodx::utils::command_action::Register(CaptureMsaaDepth, {.shader_hash = 0x65A612BEu, .command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});
    renodx::utils::command_action::Register(OnLut, {.shader_hash = 0x9CB80815u, .command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});
    for (const auto& shader : MOTION_SHADERS) {
      renodx::utils::command_action::Register(CaptureObjectMotion, {.shader_hash = shader.hash, .command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});
    }
    renodx::utils::command_action::Use(reason);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::bind_vertex_buffers>(OnBindVertexBuffers);
    reshade::unregister_event<reshade::addon_event::bind_index_buffer>(OnBindIndexBuffer);
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
    reshade::unregister_event<reshade::addon_event::present>(OnPresent);
    reshade::unregister_event<reshade::addon_event::bind_pipeline_states>(OnBindPipelineStates);
    reshade::unregister_event<reshade::addon_event::map_buffer_region>(OnMapGeometry);
    reshade::unregister_event<reshade::addon_event::unmap_buffer_region>(OnUnmapGeometry);
    reshade::unregister_event<reshade::addon_event::destroy_resource>(OnDestroyGeometry);
    reshade::unregister_event<reshade::addon_event::clear_depth_stencil_view>(OnClearDepth);
    renodx::utils::command_action::Unregister(OnLut);
    renodx::utils::command_action::Unregister(CaptureObjectMotion);
    renodx::utils::command_action::Unregister(CaptureCamera);
    renodx::utils::command_action::Unregister(CaptureMsaaDepth);
    renodx::utils::command_action::Unregister(ApplyJitter);
    renodx::utils::command_action::Use(reason);
    renodx::utils::shader::Use(reason);
    acbrotherhood::native_draw::Uninstall();
  }
}

}  // namespace acbrotherhood::taa
