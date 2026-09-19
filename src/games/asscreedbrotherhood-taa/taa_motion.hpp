/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <iterator>

#include <array>
#include <bit>
#include <iterator>
#include <optional>
#include <span>
#include <unordered_map>
#include <vector>
#include <d3d9.h>
#include <wrl/client.h>
#include <embed/shaders.h>
#include "./taa_camera.hpp"
#include "./taa_geometry.hpp"

namespace acbrotherhood::taa {
using Microsoft::WRL::ComPtr;
inline float object_motion_enabled = 1.f;
enum class MotionColor { CLIP, WHITE, VERTEX, WIND, POSITION };

struct MotionShader {
  uint32_t hash;
  bool skinned, packed_position;
  unsigned clip_semantic;
  bool scaled_uv;
  MotionColor color = MotionColor::CLIP;
  unsigned uv_semantic = 0;
  unsigned color_semantic = 1;
  bool wind = false;
  bool displaced = false;
  unsigned tree = 0;
};
inline constexpr MotionShader MOTION_SHADERS[] = {
    {0x4B000956u, false, false, 1, false, MotionColor::VERTEX}, {0xCFF33597u, false, false, 1, false},
    {0x6ADF3971u, true, false, 1, false, MotionColor::POSITION}, {0x73550BE7u, true, false, 1, false}, {0x91F6EBFAu, true, false, 1, false},
    {0x7B3AA462u, false, true, 1, false, MotionColor::VERTEX}, {0xCBFA98A8u, false, true, 1, false, MotionColor::WHITE},
    {0x490226E1u, false, true, 1, false}, {0xCF25236Fu, false, true, 1, false, MotionColor::WHITE},
    {0x6810707Fu, false, true, 2, true, MotionColor::VERTEX}, {0x160DC1A8u, false, true, 2, true, MotionColor::WHITE},
    {0x72582374u, false, true, 2, false, MotionColor::VERTEX, 1, 0},
    {0x967139C2u, false, true, 2, false, MotionColor::WHITE, 1, 0},
    {0xBDF4BDE9u, false, true, 2, false, MotionColor::WIND, 1, 0, true},
    {0x89CCF177u, true, false, 1, false, MotionColor::POSITION, 0, 1, false, true},
    {0x37DFB300u, false, true, 1, false, MotionColor::VERTEX},
    {0xFC8CBBF0u, false, true, 2, true, MotionColor::VERTEX},
    {0xF53BF32Fu, false, false, 2, false, MotionColor::WIND, 1, 0, true, false, 1},
    {0x9E55FEF3u, false, false, 2, false, MotionColor::WIND, 1, 0, true, false, 2},
};

struct MotionMesh {
  uintptr_t vertices = 0, indices = 0, declaration = 0;
  uintptr_t secondary_vertices = 0;
  UINT secondary_offset = 0, secondary_stride = 0;
  UINT shader = 0, offset = 0, stride = 0, count = 0, first = 0;
  INT base_vertex = 0;
  bool indexed = false;
  bool operator==(const MotionMesh&) const = default;
};

struct MotionMeshHash {
  size_t operator()(const MotionMesh& mesh) const {
    size_t hash = 0;
    for (const uintptr_t value : {mesh.vertices, mesh.indices, mesh.declaration, uintptr_t(mesh.shader),
                                  mesh.secondary_vertices, uintptr_t(mesh.secondary_offset), uintptr_t(mesh.secondary_stride),
                                  uintptr_t(mesh.offset), uintptr_t(mesh.stride), uintptr_t(mesh.count),
                                  uintptr_t(mesh.first), uintptr_t(mesh.base_vertex), uintptr_t(mesh.indexed)}) {
      hash ^= value + 0x9e3779b9u + (hash << 6) + (hash >> 2);
    }
    return hash;
  }
};

struct MotionDraw {
  MotionMesh mesh;
  // References prevent reused COM addresses from impersonating last frame's mesh.
  ComPtr<IDirect3DVertexBuffer9> vertices;
  ComPtr<IDirect3DVertexBuffer9> source_vertices;
  ComPtr<IDirect3DVertexBuffer9> secondary_vertices;
  std::shared_ptr<GeometrySnapshot> geometry;
  ComPtr<IDirect3DIndexBuffer9> indices;
  ComPtr<IDirect3DVertexDeclaration9> declaration;
  ComPtr<IDirect3DVertexDeclaration9> motion_declaration;
  ComPtr<IDirect3DTexture9> alpha_texture;
  std::array<DWORD, 14> alpha_sampler_states = {};
  DWORD alpha_function = D3DCMP_ALWAYS, alpha_reference = 0;
  std::array<float, 2> alpha_uv_scale = {1.f, 1.f};
  std::array<float, 2> alpha_pixel_uv_scale = {1.f, 1.f};
  float alpha_scale = 1.f;
  float alpha_final_scale = 1.f;
  float constant_vertex_alpha = 1.f;
  bool vertex_alpha = false, saturate_alpha = false;
  bool vertex_alpha_first = false;
  bool position_alpha = false;
  Matrix clip = {}, unjittered_clip = {}, world = {};
  std::array<float, 4> clip_plane = {};
  std::array<float, 504> bones = {};
  std::array<float, 24> wind_constants = {};
  std::array<float, 4> wind_origin = {};
  UINT vertex_count = 0;
  UINT vertex_min = 0;
  DWORD cull = D3DCULL_CCW, bias = 0, slope_bias = 0;
  DWORD stencil_function = D3DCMP_ALWAYS, stencil_reference = 0, stencil_mask = 0xff;
  DWORD depth_function = D3DCMP_EQUAL;
  bool translucent = false;
  float min_depth = 0.f, max_depth = 1.f;
  bool skinned = false, packed_position = false;
  bool wind = false;
  bool displaced = false;
  float displacement = 0.f;
  unsigned tree = 0;
  std::array<float, 4> tree_eye = {};
  std::optional<std::array<float, 3>> geometry_center;
  // Only unchanged rigid draws that write the native scene-depth MRT can be
  // omitted. Late color-only, animated and ambiguous geometry still replays.
  bool camera_static_candidate = false;
  bool camera_only = false;
  std::array<uint64_t, 3> buffer_writes = {};
  // A returning skin submesh may lack its own previous pose while other parts
  // still identify the actor. This index supplies only that actor's old WVP.
  int root_match = -1;
};

inline bool SameMotionWorld(const MotionDraw& a, const MotionDraw& b) {
  // The rigid variants use only c8-c10 for world position. c11 carries an
  // unrelated normal-plane row in these layouts and cannot identify an instance.
  return std::memcmp(&a.world, &b.world, sizeof(float) * (a.skinned ? 16 : 12)) == 0
         && a.geometry_center == b.geometry_center;
}

inline bool MotionWithinStep(const MotionDraw& a, const MotionDraw& b) {
  // A unique candidate inside a small world-space step can retain animation
  // history while walking. Reject overlapping candidates rather than choose
  // the nearest member of a crowd. Depth validation remains mandatory.
  float distance_squared = 0.f;
  if (a.geometry_center.has_value() != b.geometry_center.has_value()) return false;
  for (unsigned row = 0; row < 3; ++row) {
    // CPU-deformed clothing can share an identity world matrix across NPCs.
    // Its captured vertices supply the spatial anchor instead of that matrix.
    const float delta = a.geometry_center ? (*a.geometry_center)[row] - (*b.geometry_center)[row]
                                          : a.world.m[row][3] - b.world.m[row][3];
    distance_squared += delta * delta;
    for (unsigned column = 0; column < 3; ++column)
      if (std::abs(a.world.m[row][column] - b.world.m[row][column]) > .35f) return false;
  }
  return std::isfinite(distance_squared) && distance_squared <= .0625f;
}

// Identical multipass draws share one pose. Repeated instances require a
// unique unchanged transform or a mutually unique bounded movement step.
inline std::vector<int> MatchMotionDraws(const std::vector<MotionDraw>& current, const std::vector<MotionDraw>& previous,
                                       std::array<unsigned, 2>* rejected = nullptr) {
  if (rejected) *rejected = {};
  using PoseGroups = std::unordered_multimap<MotionMesh, int, MotionMeshHash>;
  const auto group_poses = [](const std::vector<MotionDraw>& draws) {
    PoseGroups groups;
    groups.reserve(draws.size());
    for (size_t i = 0; i < draws.size(); ++i) {
      const auto poses = groups.equal_range(draws[i].mesh);
      bool duplicate = false;
      for (auto pose = poses.first; pose != poses.second; ++pose) {
        const int index = pose->second;
        if (SameMotionWorld(draws[i], draws[index])
            && std::memcmp(&draws[i].unjittered_clip, &draws[index].unjittered_clip, sizeof(Matrix)) == 0
            && (!(draws[i].skinned || draws[i].tree) || draws[i].bones == draws[index].bones)
            && (!draws[i].tree || draws[i].tree_eye == draws[index].tree_eye)
            && (draws[i].geometry == draws[index].geometry
                || (draws[i].geometry && draws[index].geometry && draws[i].geometry->data == draws[index].geometry->data))
            && (!draws[i].displaced || draws[i].displacement == draws[index].displacement)
            && (!draws[i].wind || (draws[i].wind_constants == draws[index].wind_constants && draws[i].wind_origin == draws[index].wind_origin))) {
          duplicate = true;
          break;
        }
      }
      if (!duplicate) groups.emplace(draws[i].mesh, int(i));
    }
    return groups;
  };
  const auto old_groups = group_poses(previous), new_groups = group_poses(current);
  std::vector<int> result(current.size(), -1);
  for (size_t i = 0; i < current.size(); ++i) {
    const auto old_poses = old_groups.equal_range(current[i].mesh);
    if (old_poses.first == old_poses.second) {
      if (rejected) ++(*rejected)[0];
      continue;
    }
    const auto new_poses = new_groups.equal_range(current[i].mesh);
    if (std::next(new_poses.first) == new_poses.second && std::next(old_poses.first) == old_poses.second && !current[i].geometry) {
      result[i] = old_poses.first->second;
      continue;
    }
    unsigned current_matches = 0, previous_matches = 0;
    int previous_index = -1;
    for (auto pose = new_poses.first; pose != new_poses.second; ++pose)
      if (SameMotionWorld(current[i], current[pose->second])) ++current_matches;
    for (auto pose = old_poses.first; pose != old_poses.second; ++pose) if (SameMotionWorld(current[i], previous[pose->second])) {
      ++previous_matches;
      previous_index = pose->second;
    }
    if (current_matches == 1 && previous_matches == 1) result[i] = previous_index;
    else {
      unsigned candidates = 0;
      for (auto pose = old_poses.first; pose != old_poses.second; ++pose) if (MotionWithinStep(current[i], previous[pose->second])) {
        ++candidates;
        previous_index = pose->second;
      }
      if (candidates == 1) {
        unsigned reverse_candidates = 0;
        for (auto pose = new_poses.first; pose != new_poses.second; ++pose)
          if (MotionWithinStep(current[pose->second], previous[previous_index])) ++reverse_candidates;
        if (reverse_candidates == 1) result[i] = previous_index;
      }
      if (result[i] < 0 && rejected) ++(*rejected)[1];
    }
  }
  return result;
}

// Recover body/camera motion for a skin part absent in the preceding capture.
// Never borrow another mesh's bone palette: meshes can remap the same skeleton.
// All directly matched parts at this exact current root must agree on its old
// root. Ambiguous crowds, cloth streams and newly visible whole actors reset.
inline unsigned MatchMotionRoots(std::vector<MotionDraw>* current, const std::vector<MotionDraw>& previous,
                                 const std::vector<int>& matches) {
  unsigned recovered = 0;
  for (size_t i = 0; i < current->size(); ++i) {
    auto& draw = (*current)[i];
    draw.root_match = -1;
    if (matches[i] >= 0 || !draw.skinned || draw.geometry || draw.wind || draw.tree) continue;
    for (size_t peer = 0; peer < current->size(); ++peer) {
      if (matches[peer] < 0) continue;
      const auto& part = (*current)[peer];
      if (!part.skinned || part.geometry || !SameMotionWorld(draw, part)
          || std::memcmp(&draw.unjittered_clip, &part.unjittered_clip, sizeof(Matrix)) != 0) continue;
      const auto& old_part = previous[matches[peer]];
      if (!MotionWithinStep(draw, old_part)
          || (draw.root_match >= 0
              && (!SameMotionWorld(previous[draw.root_match], old_part)
                  || std::memcmp(&previous[draw.root_match].unjittered_clip, &old_part.unjittered_clip, sizeof(Matrix)) != 0))) {
        draw.root_match = -1;
        break;
      }
      draw.root_match = matches[peer];
    }
    if (draw.root_match >= 0) ++recovered;
  }
  return recovered;
}

struct MotionResources {
  ComPtr<IDirect3DTexture9> texture, palette;
  ComPtr<IDirect3DSurface9> msaa_replay_depth;
  ComPtr<IDirect3DVertexShader9> rigid_shader, skin_shader, tree_shader;
  ComPtr<IDirect3DPixelShader9> pixel_shader;
  UINT width = 0, height = 0;
  UINT palette_height = 0;
  bool failed = false;
};

struct MotionOpacity {
  int sampler = -1, constant = -1;
  int final_constant = -1;
  bool vertex_alpha = false, saturate = false;
  bool vertex_first = false;
  unsigned uv_semantic = 0;
  unsigned color_semantic = 0;
  std::array<int, 2> uv_constants = {-1, -1};
};

struct MotionState {
  MotionResources resources;
  std::shared_ptr<GeometryCache> geometry = std::make_shared<GeometryCache>();
  std::vector<MotionDraw> current, previous;
  unsigned matched_rigid = 0, matched_skin = 0, unmatched = 0;
  unsigned camera_only_draws = 0;
  unsigned root_motion_draws = 0;
  std::unordered_map<uintptr_t, uint64_t> buffer_writes;
  std::vector<int> matches;
  std::array<unsigned, 2> rejected_matches = {};
  unsigned mutable_draws = 0, mutable_misses = 0;
  // Cumulative capture stages for the existing input-capture diagnostics.
  std::array<unsigned, 13> capture_stages = {};
  std::array<std::array<unsigned, 13>, std::size(MOTION_SHADERS)> profile_stages = {};
  bool ready = false;
  struct PixelShader {
    ComPtr<IDirect3DPixelShader9> shader;
    int clip_semantic = -2;
    int depth_color_semantic = -1;
    MotionOpacity opacity;
    uint64_t last_used = 0;
  };
  std::unordered_map<IDirect3DPixelShader9*, PixelShader> pixel_shaders;
  uint64_t shader_usage = 0;
  unsigned shader_cache_misses = 0;
  struct Declaration {
    ComPtr<IDirect3DVertexDeclaration9> original;
    std::array<ComPtr<IDirect3DVertexDeclaration9>, 48> motion;
    std::array<bool, 48> attempted = {};
    std::array<UINT, 48> streams = {};
  };
  std::unordered_map<IDirect3DVertexDeclaration9*, Declaration> declarations;
};

inline ComPtr<IDirect3DVertexDeclaration9> GetMotionDeclaration(IDirect3DDevice9* native, MotionState* state,
                                                              IDirect3DVertexDeclaration9* original, bool skinned, bool vertex_alpha = false,
                                                              bool displaced = false, bool mutable_vertices = false, unsigned tree = 0, UINT* source_streams = nullptr) {
  if (source_streams) *source_streams = 0;
  if (tree > 2 || (tree && (skinned || vertex_alpha || displaced || mutable_vertices))) return {};
  auto found = state->declarations.find(original);
  const unsigned variant = unsigned(skinned) + 2 * unsigned(vertex_alpha) + 4 * unsigned(displaced) + 8 * unsigned(mutable_vertices) + 16 * tree;
  if (found == state->declarations.end()) {
    if (state->declarations.size() >= 256) state->declarations.clear();
    found = state->declarations.emplace(original, MotionState::Declaration{original}).first;
  }
  if (found->second.attempted[variant]) {
    if (source_streams) *source_streams = found->second.streams[variant];
    return found->second.motion[variant];
  }
  found->second.attempted[variant] = true;
  // Motion only reads position, skin weights/indices and the cutout UV. Native
  // scenery can carry unused baked lighting in another vertex stream; retaining
  // that stream in the replay declaration would introduce an unrelated binding.
  UINT count = MAXD3DDECLLENGTH;
  D3DVERTEXELEMENT9 elements[MAXD3DDECLLENGTH + 1];
  if (FAILED(original->GetDeclaration(elements, &count))) return {};
  if (tree) {
    std::vector<D3DVERTEXELEMENT9> filtered;
    const unsigned required = tree == 1 ? 0x37u : 0x17u;
    unsigned present = 0;
    for (UINT i = 0; i < count && elements[i].Stream != 0xff; ++i) {
      const auto& element = elements[i];
      if (element.Usage != D3DDECLUSAGE_TEXCOORD || element.UsageIndex > 5 || !(required & (1u << element.UsageIndex))) continue;
      if (element.Stream > 1 || element.Method != D3DDECLMETHOD_DEFAULT) return {};
      found->second.streams[variant] |= 1u << element.Stream;
      present |= 1u << element.UsageIndex;
      filtered.push_back(element);
    }
    if (present != required) return {};
    filtered.push_back(D3DDECL_END());
    native->CreateVertexDeclaration(filtered.data(), &found->second.motion[variant]);
    if (source_streams) *source_streams = found->second.streams[variant];
    return found->second.motion[variant];
  }
  {
    const bool skin = skinned, color = vertex_alpha, displacement = displaced;
    std::vector<D3DVERTEXELEMENT9> motion_elements;
    bool position = false, weights = false, indices = false, has_color = false, normal = false, binormal = false, supported = true;
    for (UINT i = 0; i < count && elements[i].Stream != 0xff; ++i) {
      const auto& element = elements[i];
      if (element.UsageIndex != 0) continue;
      if (element.Usage != D3DDECLUSAGE_POSITION && element.Usage != D3DDECLUSAGE_TEXCOORD
          && !(color && element.Usage == D3DDECLUSAGE_COLOR)
          && !(displacement && (element.Usage == D3DDECLUSAGE_NORMAL || element.Usage == D3DDECLUSAGE_BINORMAL))
          && !(skin && (element.Usage == D3DDECLUSAGE_BLENDWEIGHT || element.Usage == D3DDECLUSAGE_BLENDINDICES))) continue;
      if (element.Stream > 1 || element.Method != D3DDECLMETHOD_DEFAULT) { supported = false; break; }
      found->second.streams[variant] |= 1u << element.Stream;
      if (element.Usage == D3DDECLUSAGE_POSITION) position = true;
      if (element.Usage == D3DDECLUSAGE_COLOR) has_color = true;
      if (element.Usage == D3DDECLUSAGE_NORMAL) normal = element.Type == D3DDECLTYPE_UBYTE4;
      if (element.Usage == D3DDECLUSAGE_BINORMAL) binormal = element.Type == D3DDECLTYPE_UBYTE4;
      if (element.Usage == D3DDECLUSAGE_BLENDWEIGHT) weights = element.Type == D3DDECLTYPE_UBYTE4N || element.Type == D3DDECLTYPE_FLOAT4;
      if (element.Usage == D3DDECLUSAGE_BLENDINDICES) indices = element.Type == D3DDECLTYPE_UBYTE4;
      motion_elements.push_back(element);
      if (mutable_vertices && element.Usage != D3DDECLUSAGE_TEXCOORD && element.Usage != D3DDECLUSAGE_COLOR) {
        D3DVERTEXELEMENT9 previous = element;
        // Stream 1 may contain the game's UV/color or compressed geometry.
        // Only mutable stream-0 inputs come from the saved previous upload.
        previous.Stream = element.Stream == 0 ? 2 : 1;
        previous.Usage = D3DDECLUSAGE_TEXCOORD;
        switch (element.Usage) {
          case D3DDECLUSAGE_POSITION: previous.UsageIndex = 5; break;
          case D3DDECLUSAGE_BLENDWEIGHT: previous.UsageIndex = 6; break;
          case D3DDECLUSAGE_BLENDINDICES: previous.UsageIndex = 7; break;
          case D3DDECLUSAGE_NORMAL: previous.UsageIndex = 8; break;
          case D3DDECLUSAGE_BINORMAL: previous.UsageIndex = 9; break;
        }
        motion_elements.push_back(previous);
      }
    }
    if (supported && position && (!skin || (weights && indices)) && (!color || has_color) && (!displacement || (normal && binormal))) {
      std::stable_sort(motion_elements.begin(), motion_elements.end(), [](const auto& a, const auto& b) { return a.Stream < b.Stream; });
      motion_elements.push_back(D3DDECL_END());
      native->CreateVertexDeclaration(motion_elements.data(), &found->second.motion[variant]);
    }
  }
  if (source_streams) *source_streams = found->second.streams[variant];
  return found->second.motion[variant];
}

inline bool MotionStencilDoesNotCull(IDirect3DDevice9* native) {
  DWORD enabled, function, two_sided;
  if (FAILED(native->GetRenderState(D3DRS_STENCILENABLE, &enabled))) return false;
  if (!enabled) return true;
  // Brotherhood's opaque pass uses ALWAYS/REPLACE to tag stencil. Disabling
  // this write-only stencil operation preserves visibility without modifying
  // the game's final stencil contents during the motion replay.
  if (FAILED(native->GetRenderState(D3DRS_STENCILFUNC, &function)) || function != D3DCMP_ALWAYS
      || FAILED(native->GetRenderState(D3DRS_TWOSIDEDSTENCILMODE, &two_sided))) return false;
  return !two_sided || (SUCCEEDED(native->GetRenderState(D3DRS_CCW_STENCILFUNC, &function)) && function == D3DCMP_ALWAYS);
}

// LOD cross-fades write depth while reading the opaque pass's stencil tag.
// Save that read-only test; replay must neither erase it nor modify the tag.
inline bool CaptureMotionRasterState(IDirect3DDevice9* native, MotionDraw* draw) {
  DWORD enabled, value;
  if (FAILED(native->GetRenderState(D3DRS_ALPHABLENDENABLE, &enabled))) return false;
  if (enabled) {
    DWORD source, destination, write_depth;
    if (FAILED(native->GetRenderState(D3DRS_SRCBLEND, &source))
        || FAILED(native->GetRenderState(D3DRS_DESTBLEND, &destination))
        || FAILED(native->GetRenderState(D3DRS_ZWRITEENABLE, &write_depth))
        || FAILED(native->GetRenderState(D3DRS_BLENDOP, &value)) || value != D3DBLENDOP_ADD) return false;
    if (source == D3DBLEND_SRCALPHA && destination == D3DBLEND_INVSRCALPHA && !write_depth) {
      // Hair/soft cutouts do not own native depth. Match their native visibility
      // test and let the audited material alpha select the dominant surface.
      if (FAILED(native->GetRenderState(D3DRS_ZFUNC, &draw->depth_function))
          || (draw->depth_function != D3DCMP_LESS && draw->depth_function != D3DCMP_LESSEQUAL)) return false;
      draw->translucent = true;
    } else if (source != D3DBLEND_BLENDFACTOR || destination != D3DBLEND_INVBLENDFACTOR || !write_depth) {
      return false;
    }
  }
  if (MotionStencilDoesNotCull(native)) return true;
  // Other stencil writers may encode a different visibility operation.
  for (const auto& [state, expected] : {std::pair{D3DRS_TWOSIDEDSTENCILMODE, DWORD(FALSE)},
                                       {D3DRS_STENCILWRITEMASK, DWORD(0)},
                                       {D3DRS_STENCILFAIL, DWORD(D3DSTENCILOP_KEEP)},
                                       {D3DRS_STENCILZFAIL, DWORD(D3DSTENCILOP_KEEP)},
                                       {D3DRS_STENCILPASS, DWORD(D3DSTENCILOP_KEEP)}}) {
    if (FAILED(native->GetRenderState(state, &value)) || value != expected) return false;
  }
  return SUCCEEDED(native->GetRenderState(D3DRS_STENCILFUNC, &draw->stencil_function))
         && draw->stencil_function >= D3DCMP_NEVER && draw->stencil_function <= D3DCMP_ALWAYS
         && SUCCEEDED(native->GetRenderState(D3DRS_STENCILREF, &draw->stencil_reference))
         && SUCCEEDED(native->GetRenderState(D3DRS_STENCILMASK, &draw->stencil_mask));
}

inline HRESULT CreateMotionWindShader(IDirect3DDevice9* native, std::span<const uint8_t> bytes, IDirect3DVertexShader9** shader) {
  std::vector<DWORD> code(bytes.size() / sizeof(DWORD));
  std::memcpy(code.data(), bytes.data(), bytes.size());
  unsigned replacements = 0;
  // Modern FXC emits sin range-reduction constants one ULP above the game's
  // older compiler. Use its exact literals: replay must pass native depth EQUAL.
  for (size_t i = 1; i < code.size();) {
    const DWORD opcode = code[i] & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) break;
    const size_t length = 1 + (opcode == D3DSIO_COMMENT ? (code[i] & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT
                                                       : (code[i] & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (length > code.size() - i) return D3DERR_INVALIDCALL;
    if (opcode == D3DSIO_DEF && length == 6) for (size_t literal = i + 2; literal < i + length; ++literal) {
      if (code[literal] == std::bit_cast<DWORD>(6.28318548f)) {
        code[literal] = std::bit_cast<DWORD>(6.28318501f);
        ++replacements;
      } else if (code[literal] == std::bit_cast<DWORD>(-3.14159274f)) {
        code[literal] = std::bit_cast<DWORD>(-3.1415925f);
        ++replacements;
      }
    }
    i += length;
  }
  return replacements == 2 ? native->CreateVertexShader(code.data(), shader) : D3DERR_INVALIDCALL;
}

inline int MotionClipSemantic(IDirect3DPixelShader9* shader, MotionOpacity* opacity = nullptr, int* depth_color_semantic = nullptr) {
  if (opacity) *opacity = {};
  if (depth_color_semantic) *depth_color_semantic = -1;
  UINT size = 0;
  if (FAILED(shader->GetFunction(nullptr, &size)) || size % 4 || size < 8) return -2;
  std::vector<DWORD> code(size / 4);
  if (FAILED(shader->GetFunction(code.data(), &size)) || code[0] != D3DPS_VERSION(3, 0)) return -2;
  std::array<int, 16> inputs;
  inputs.fill(-2);
  std::array<int, 16> colors;
  colors.fill(-1);
  struct Term {
    enum Kind { UNKNOWN, LITERAL, CONSTANT, TEXTURE, VERTEX, UV_X, UV_Y, CLIP_Z, INVERSE_CLIP_W, CLIP_DEPTH } kind = UNKNOWN;
    float literal = 0.f;
    MotionOpacity opacity;
  };
  std::array<std::array<Term, 4>, 32> alpha_origins = {};
  std::array<std::array<Term, 4>, 224> constants = {};
  for (unsigned reg = 0; reg < constants.size(); ++reg) for (unsigned component = 0; component < 4; ++component) {
    constants[reg][component].kind = Term::CONSTANT;
    constants[reg][component].opacity.constant = int(reg * 4 + component);
  }
  Term output_alpha;
  Term output_depth;
  unsigned flow_depth = 0;
  bool alpha_flow_supported = true;
  const auto register_type = [](DWORD token) {
    return ((token & D3DSP_REGTYPE_MASK) >> D3DSP_REGTYPE_SHIFT) | ((token & D3DSP_REGTYPE_MASK2) >> D3DSP_REGTYPE_SHIFT2);
  };
  const auto source = [&](DWORD token, unsigned component) -> Term {
    if (token & (D3DSP_SRCMOD_MASK | D3DSHADER_ADDRESSMODE_MASK)) return {};
    const unsigned reg = token & D3DSP_REGNUM_MASK;
    const unsigned swizzle = (token >> (D3DSP_SWIZZLE_SHIFT + 2 * component)) & 3;
    switch (register_type(token)) {
      case D3DSPR_TEMP: if (reg < alpha_origins.size()) return alpha_origins[reg][swizzle]; break;
      case D3DSPR_CONST: if (reg < constants.size()) return constants[reg][swizzle]; break;
      case D3DSPR_INPUT:
        if (reg < colors.size() && colors[reg] >= 0 && swizzle == 3) {
          Term color{Term::VERTEX};
          color.opacity.color_semantic = colors[reg];
          return color;
        }
        if (reg < colors.size() && colors[reg] >= 0 && swizzle == 2) {
          Term z{Term::CLIP_Z};
          z.opacity.color_semantic = colors[reg];
          return z;
        }
        if (reg < inputs.size() && inputs[reg] >= 0 && swizzle < 2) {
          Term uv{swizzle == 0 ? Term::UV_X : Term::UV_Y};
          uv.opacity.uv_semantic = inputs[reg];
          return uv;
        }
        break;
    }
    return {};
  };
  // Accept the native material-alpha product, preserving multiplication order:
  // texture.a * optional material constant * optional vertex alpha. Literal
  // 0/1 lanes in RGB packing MADs do not change the independent alpha lane.
  const auto multiply = [](Term a, Term b) -> Term {
    if (a.kind == Term::INVERSE_CLIP_W) std::swap(a, b);
    if (a.kind == Term::CLIP_Z && b.kind == Term::INVERSE_CLIP_W
        && a.opacity.color_semantic == b.opacity.color_semantic) {
      a.kind = Term::CLIP_DEPTH;
      return a;
    }
    if (a.kind == Term::LITERAL && a.literal == 1.f) return b;
    if (b.kind == Term::LITERAL && b.literal == 1.f) return a;
    if ((a.kind == Term::LITERAL && a.literal == 0.f) || (b.kind == Term::LITERAL && b.literal == 0.f)) return {Term::LITERAL};
    if (a.kind == Term::LITERAL && b.kind == Term::LITERAL) return {Term::LITERAL, a.literal * b.literal};
    if (a.kind == Term::CONSTANT) std::swap(a, b);
    if ((a.kind == Term::UV_X || a.kind == Term::UV_Y) && b.kind == Term::CONSTANT && a.opacity.constant == -1) {
      a.opacity.constant = b.opacity.constant;
      return a;
    }
    if (a.kind == Term::VERTEX && b.kind == Term::CONSTANT && a.opacity.constant == -1) {
      a.opacity.constant = b.opacity.constant;
      return a;
    }
    if (b.kind == Term::TEXTURE) std::swap(a, b);
    if (a.kind != Term::TEXTURE || a.opacity.saturate) return {};
    if (b.kind == Term::CONSTANT && a.opacity.final_constant == -1) {
      if (a.opacity.constant == -1 && !a.opacity.vertex_alpha) a.opacity.constant = b.opacity.constant;
      else a.opacity.final_constant = b.opacity.constant;
      return a;
    }
    if (b.kind == Term::VERTEX && !a.opacity.vertex_alpha && a.opacity.final_constant == -1) {
      if (b.opacity.constant != -1) {
        if (a.opacity.constant != -1) return {};
        a.opacity.constant = b.opacity.constant;
        a.opacity.vertex_first = true;
      }
      a.opacity.vertex_alpha = true;
      a.opacity.color_semantic = b.opacity.color_semantic;
      return a;
    }
    return {};
  };
  const auto add = [](Term a, Term b) -> Term {
    if (a.kind == Term::LITERAL && a.literal == 0.f) return b;
    if (b.kind == Term::LITERAL && b.literal == 0.f) return a;
    if (a.kind == Term::LITERAL && b.kind == Term::LITERAL) return {Term::LITERAL, a.literal + b.literal};
    return {};
  };
  size_t previous_instruction = 0;
  int clip_semantic = -1;
  for (size_t i = 1; i < code.size();) {
    const DWORD opcode = code[i] & D3DSI_OPCODE_MASK;
    if (opcode == D3DSIO_END) {
      if (i + 1 != code.size() || flow_depth) return -2;
      if (opacity && alpha_flow_supported && output_alpha.kind == Term::TEXTURE) *opacity = output_alpha.opacity;
      if (depth_color_semantic && alpha_flow_supported && output_depth.kind == Term::CLIP_DEPTH)
        *depth_color_semantic = int(output_depth.opacity.color_semantic);
      return clip_semantic;
    }
    const size_t length = 1 + (opcode == D3DSIO_COMMENT ? (code[i] & D3DSI_COMMENTSIZE_MASK) >> D3DSI_COMMENTSIZE_SHIFT
                                                       : (code[i] & D3DSI_INSTLENGTH_MASK) >> D3DSI_INSTLENGTH_SHIFT);
    if (length > code.size() - i) return -2;
    if (opcode == D3DSIO_CALL || opcode == D3DSIO_CALLNZ || opcode == D3DSIO_RET || opcode == D3DSIO_LABEL) alpha_flow_supported = false;
    if (opcode == D3DSIO_IF || opcode == D3DSIO_IFC || opcode == D3DSIO_LOOP || opcode == D3DSIO_REP) ++flow_depth;
    if (opcode == D3DSIO_ENDIF || opcode == D3DSIO_ENDLOOP || opcode == D3DSIO_ENDREP) {
      if (!flow_depth) return -2;
      --flow_depth;
    }
    if (opcode == D3DSIO_DCL && length == 3 && (code[i + 1] & D3DSP_DCL_USAGE_MASK) == D3DDECLUSAGE_TEXCOORD) {
      const DWORD input = code[i + 2] & D3DSP_REGNUM_MASK;
      if (input < inputs.size()) inputs[input] = (code[i + 1] & D3DSP_DCL_USAGEINDEX_MASK) >> D3DSP_DCL_USAGEINDEX_SHIFT;
    }
    if (opcode == D3DSIO_DCL && length == 3 && (code[i + 1] & D3DSP_DCL_USAGE_MASK) == D3DDECLUSAGE_COLOR) {
      const DWORD input = code[i + 2] & D3DSP_REGNUM_MASK;
      if (input < colors.size() && register_type(code[i + 2]) == D3DSPR_INPUT)
        colors[input] = (code[i + 1] & D3DSP_DCL_USAGEINDEX_MASK) >> D3DSP_DCL_USAGEINDEX_SHIFT;
    }
    if (opcode == D3DSIO_DEF && length == 6) {
      const DWORD reg = code[i + 1] & D3DSP_REGNUM_MASK;
      if (reg < constants.size()) for (unsigned component = 0; component < 4; ++component) {
        constants[reg][component].kind = Term::LITERAL;
        std::memcpy(&constants[reg][component].literal, &code[i + 2 + component], sizeof(float));
      }
    }
    if (opcode == D3DSIO_TEXKILL) {
      // Accept only the audited clip-plane interpolant: mov rN, vN.wwww;
      // texkill rN. Alpha tests/other discard calculations remain unsupported.
      if (length != 2 || previous_instruction + 3 != i || (code[previous_instruction] & D3DSI_OPCODE_MASK) != D3DSIO_MOV
          || clip_semantic != -1 || (code[previous_instruction + 1] & D3DSP_REGNUM_MASK) != (code[i + 1] & D3DSP_REGNUM_MASK)
          || (code[previous_instruction + 1] & D3DSP_WRITEMASK_ALL) != D3DSP_WRITEMASK_ALL
          || (code[previous_instruction + 2] & D3DSP_SWIZZLE_MASK) != D3DSP_REPLICATEALPHA
          || (code[previous_instruction + 2] & D3DSP_SRCMOD_MASK) != 0
          || ((code[previous_instruction + 2] & D3DSP_REGTYPE_MASK) >> D3DSP_REGTYPE_SHIFT) != D3DSPR_INPUT) return -2;
      const DWORD input = code[previous_instruction + 2] & D3DSP_REGNUM_MASK;
      if (input >= inputs.size() || inputs[input] < 0) return -2;
      clip_semantic = inputs[input];
    }
    if (opcode != D3DSIO_COMMENT && length > 1) {
      const DWORD type = ((code[i + 1] & D3DSP_REGTYPE_MASK) >> D3DSP_REGTYPE_SHIFT)
                         | ((code[i + 1] & D3DSP_REGTYPE_MASK2) >> D3DSP_REGTYPE_SHIFT2);
      if (type == D3DSPR_DEPTHOUT) return -2;
      if (opcode != D3DSIO_DCL && opcode != D3DSIO_TEXKILL && (type == D3DSPR_TEMP || type == D3DSPR_COLOROUT)) {
        std::array<Term, 4> origin = {};
        const DWORD dest = code[i + 1] & D3DSP_REGNUM_MASK;
        if (!flow_depth && !(code[i] & D3DSHADER_INSTRUCTION_PREDICATED)
            && !(code[i + 1] & (D3DSP_DSTSHIFT_MASK | D3DSHADER_ADDRESSMODE_MASK))) {
          if ((opcode == D3DSIO_MOV && length == 3) || ((opcode == D3DSIO_MUL || opcode == D3DSIO_ADD) && length == 4)
              || (opcode == D3DSIO_MAD && length == 5)) {
            for (unsigned component = 0; component < 4; ++component) {
              origin[component] = source(code[i + 2], component);
              if (opcode == D3DSIO_MUL || opcode == D3DSIO_MAD) origin[component] = multiply(origin[component], source(code[i + 3], component));
              if (opcode == D3DSIO_ADD || opcode == D3DSIO_MAD) origin[component] = add(origin[component], source(code[i + (opcode == D3DSIO_MAD ? 4 : 3)], component));
            }
          } else if (opcode == D3DSIO_RCP && length == 3) {
            for (unsigned component = 0; component < 4; ++component) {
              origin[component] = source(code[i + 2], component);
              if (origin[component].kind == Term::VERTEX) origin[component].kind = Term::INVERSE_CLIP_W;
              else origin[component] = {};
            }
          } else if (opcode == D3DSIO_TEX && length == 4 && register_type(code[i + 3]) == D3DSPR_SAMPLER
                     && !(code[i] & (D3DSI_TEXLD_PROJECT | D3DSI_TEXLD_BIAS))
                     && (code[i + 3] & D3DSP_SWIZZLE_MASK) == D3DSP_NOSWIZZLE
                     && !(code[i + 2] & (D3DSP_SRCMOD_MASK | D3DSHADER_ADDRESSMODE_MASK))) {
            const Term u = source(code[i + 2], 0), v = source(code[i + 2], 1);
            if (u.kind == Term::UV_X && v.kind == Term::UV_Y && u.opacity.uv_semantic == v.opacity.uv_semantic) {
              origin[3].kind = Term::TEXTURE;
              origin[3].opacity.sampler = code[i + 3] & D3DSP_REGNUM_MASK;
              origin[3].opacity.uv_semantic = u.opacity.uv_semantic;
              origin[3].opacity.uv_constants = {u.opacity.constant, v.opacity.constant};
            }
          }
        }
        if (code[i + 1] & D3DSPDM_SATURATE) for (auto& term : origin) {
          if (term.kind == Term::TEXTURE) term.opacity.saturate = true;
          else if (term.kind == Term::LITERAL) term.literal = std::clamp(term.literal, 0.f, 1.f);
          else term = {};
        }
        for (unsigned component = 0; component < 4; ++component) if (code[i + 1] & (D3DSP_WRITEMASK_0 << component)) {
          if (type == D3DSPR_TEMP && dest < alpha_origins.size()) alpha_origins[dest][component] = origin[component];
          if (type == D3DSPR_COLOROUT && dest == 0 && component == 3) output_alpha = origin[component];
          if (type == D3DSPR_COLOROUT && dest == 1 && component == 0) output_depth = origin[component];
        }
      }
    }
    previous_instruction = i;
    i += length;
  }
  return -2;
}

// The final native hardware depth tests visibility for this separate pass.
// No game color/depth surfaces are modified and no copies cross the DX9 proxy.
inline const MotionState::PixelShader& GetMotionPixelShader(MotionState* state, const ComPtr<IDirect3DPixelShader9>& shader) {
  auto found = state->pixel_shaders.find(shader.Get());
  if (found == state->pixel_shaders.end()) {
    // Clearing the entire 256-entry cache made a larger material working set
    // repeatedly parse the same SM3 bytecode. Retain a bounded working set and
    // evict only the least recently used shader when it fills.
    if (state->pixel_shaders.size() >= 2048) {
      auto oldest = state->pixel_shaders.begin();
      for (auto it = state->pixel_shaders.begin(); it != state->pixel_shaders.end(); ++it)
        if (it->second.last_used < oldest->second.last_used) oldest = it;
      state->pixel_shaders.erase(oldest);
    }
    MotionState::PixelShader properties{shader};
    properties.clip_semantic = MotionClipSemantic(shader.Get(), &properties.opacity, &properties.depth_color_semantic);
    found = state->pixel_shaders.emplace(shader.Get(), std::move(properties)).first;
    ++state->shader_cache_misses;
  }
  found->second.last_used = ++state->shader_usage;
  return found->second;
}

inline bool RenderObjectMotion(IDirect3DDevice9* native, MotionState* state, IDirect3DSurface9* depth,
                               UINT width, UINT height, const std::array<float, 2>& jitter, bool pair_valid,
                               IDirect3DTexture9* msaa_scene_depth = nullptr) {
  state->ready = false;
  state->matched_rigid = state->matched_skin = state->unmatched = 0;
  state->camera_only_draws = 0;
  state->root_motion_draws = 0;
  auto& resources = state->resources;
  if (resources.failed || !depth) return false;
  D3DSURFACE_DESC depth_desc;
  if (FAILED(depth->GetDesc(&depth_desc)) || (!msaa_scene_depth && depth_desc.MultiSampleType != D3DMULTISAMPLE_NONE)
      || depth_desc.Width != width || depth_desc.Height != height) return false;
  if (msaa_scene_depth && (FAILED(msaa_scene_depth->GetLevelDesc(0, &depth_desc)) || depth_desc.Format != D3DFMT_R32F
                          || depth_desc.Width != width || depth_desc.Height != height)) return false;
  if (resources.width != width || resources.height != height) resources = {};
  if (!resources.texture) {
    D3DCAPS9 caps;
    D3DDEVICE_CREATION_PARAMETERS creation;
    D3DDISPLAYMODE display;
    ComPtr<IDirect3D9> api;
    // Total TAA GPU textures: 2*(RGBA16F+R16F) + RGBA16F velocity, 221.5 MiB at 4K.
    if (uint64_t(width) * height * 28 > 224ull * 1024 * 1024
        || FAILED(native->GetDeviceCaps(&caps)) || caps.VertexShaderVersion < D3DVS_VERSION(3, 0)
        || FAILED(native->GetCreationParameters(&creation)) || FAILED(native->GetDirect3D(&api))
        || FAILED(api->GetAdapterDisplayMode(creation.AdapterOrdinal, &display))
        || FAILED(api->CheckDeviceFormat(creation.AdapterOrdinal, creation.DeviceType, display.Format,
                                         D3DUSAGE_QUERY_VERTEXTEXTURE, D3DRTYPE_TEXTURE, D3DFMT_A32B32G32R32F))
        || FAILED(native->CreateTexture(width, height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A16B16G16R16F,
                                         D3DPOOL_DEFAULT, &resources.texture, nullptr))
        || FAILED(CreateMotionWindShader(native, __taa_motion_vs, &resources.rigid_shader))
        || FAILED(CreateMotionWindShader(native, __taa_motion_tree, &resources.tree_shader))
        || FAILED(native->CreateVertexShader(reinterpret_cast<const DWORD*>(__taa_motion_skin.data()), &resources.skin_shader))
        || FAILED(native->CreatePixelShader(reinterpret_cast<const DWORD*>(__taa_motion_ps.data()), &resources.pixel_shader))) {
      resources = {};
      resources.failed = true;
      return false;
    }
    resources.width = width;
    resources.height = height;
  }
  if (msaa_scene_depth && !resources.msaa_replay_depth) {
    // MSAA itself already owns large native surfaces. Add only one 1x D24S8
    // buffer (31.6 MiB at 4K), not an 8x RGBA16F velocity RT (~506 MiB).
    if (uint64_t(width) * height * 32 > 256ull * 1024 * 1024
        || FAILED(native->CreateDepthStencilSurface(width, height, D3DFMT_D24S8, D3DMULTISAMPLE_NONE, 0, TRUE,
                                                    &resources.msaa_replay_depth, nullptr))) return false;
  }
  if (!msaa_scene_depth) resources.msaa_replay_depth.Reset();
  state->matches = MatchMotionDraws(state->current, state->previous, &state->rejected_matches);
  UINT palette_rows = 0;
  for (size_t i = 0; i < state->current.size(); ++i) {
    const auto& draw = state->current[i];
    if (!pair_valid) state->matches[i] = -1;
    if (state->matches[i] >= 0) {
      const auto& previous = state->previous[state->matches[i]];
      // Teleports/reused instances may preserve a mesh key; do not bridge them.
      for (unsigned row = 0; row < 3; ++row)
        if (std::abs(draw.world.m[row][3] - previous.world.m[row][3]) > 16.f) state->matches[i] = -1;
    }
    // AA and FG share camera reprojection for unchanged geometry with reliable
    // native depth. Moving/deforming and late geometry still need replay.
    state->current[i].camera_only = state->matches[i] >= 0 && draw.camera_static_candidate
        && state->previous[state->matches[i]].camera_static_candidate
        && SameMotionWorld(draw, state->previous[state->matches[i]])
        && draw.buffer_writes == state->previous[state->matches[i]].buffer_writes;
    if (state->current[i].camera_only) {
      const std::array<uintptr_t, 3> buffers = {draw.mesh.vertices, draw.mesh.secondary_vertices, draw.mesh.indices};
      for (size_t buffer = 0; buffer < buffers.size(); ++buffer) if (buffers[buffer]) {
        const auto write = state->buffer_writes.find(buffers[buffer]);
        if (write == state->buffer_writes.end() || write->second != draw.buffer_writes[buffer]) state->current[i].camera_only = false;
      }
    }
    if (state->current[i].camera_only) ++state->camera_only_draws;
    if (draw.skinned || draw.tree) ++palette_rows;
  }
  state->root_motion_draws = MatchMotionRoots(&state->current, state->previous, state->matches);
  if (palette_rows != 0) {
    if (palette_rows > resources.palette_height) {
      D3DCAPS9 caps;
      // Capture is capped at 2048 draws: the atlas is at most 4 MiB. Grow by
      // powers of two and retain it until reset, avoiding per-frame allocation.
      const UINT height = std::bit_ceil(palette_rows);
      ComPtr<IDirect3DTexture9> palette;
      if (height > 2048 || FAILED(native->GetDeviceCaps(&caps)) || height > caps.MaxTextureHeight
          || FAILED(native->CreateTexture(128, height, 1, D3DUSAGE_DYNAMIC, D3DFMT_A32B32G32R32F,
                                           D3DPOOL_DEFAULT, &palette, nullptr))) {
        resources.failed = true;
        return false;
      }
      resources.palette = std::move(palette);
      resources.palette_height = height;
    }
    D3DLOCKED_RECT lock;
    if (FAILED(resources.palette->LockRect(0, &lock, nullptr, D3DLOCK_DISCARD))) {
      resources.failed = true;
      return false;
    }
    UINT row = 0;
    for (size_t i = 0; i < state->current.size(); ++i) {
      const auto& draw = state->current[i];
      if (!draw.skinned && !draw.tree) continue;
      const auto& previous = state->matches[i] >= 0 ? state->previous[state->matches[i]] : draw;
      auto* destination = static_cast<unsigned char*>(lock.pBits) + size_t(row++) * lock.Pitch;
      std::memcpy(destination, previous.bones.data(), sizeof(previous.bones));
      std::memset(destination + sizeof(previous.bones), 0, 32);
    }
    if (FAILED(resources.palette->UnlockRect(0))) {
      resources.failed = true;
      return false;
    }
  }
  ComPtr<IDirect3DStateBlock9> saved;
  std::array<ComPtr<IDirect3DSurface9>, 4> targets;
  ComPtr<IDirect3DSurface9> old_depth, output;
  D3DVIEWPORT9 viewport;
  D3DCAPS9 caps;
  if (FAILED(native->GetDeviceCaps(&caps)) || FAILED(native->CreateStateBlock(D3DSBT_ALL, &saved))
      || FAILED(saved->Capture()) || FAILED(native->GetViewport(&viewport))
      || FAILED(resources.texture->GetSurfaceLevel(0, &output))) return false;
  for (unsigned i = 0; i < caps.NumSimultaneousRTs && i < targets.size(); ++i) native->GetRenderTarget(i, &targets[i]);
  native->GetDepthStencilSurface(&old_depth);
  native->SetDepthStencilSurface(nullptr);
  for (unsigned i = 1; i < caps.NumSimultaneousRTs && i < targets.size(); ++i) native->SetRenderTarget(i, nullptr);
  HRESULT status = native->SetRenderTarget(0, output.Get());
  const D3DVIEWPORT9 motion_viewport = {0, 0, width, height, 0.f, 1.f};
  native->SetViewport(&motion_viewport);
  if (SUCCEEDED(status)) status = native->Clear(0, nullptr, D3DCLEAR_TARGET, 0, 1.f, 0);
  if (SUCCEEDED(status)) status = native->SetDepthStencilSurface(msaa_scene_depth ? resources.msaa_replay_depth.Get() : depth);
  if (SUCCEEDED(status) && msaa_scene_depth) status = native->Clear(0, nullptr, D3DCLEAR_ZBUFFER | D3DCLEAR_STENCIL, 0, 1.f, 0);
  native->SetRenderState(D3DRS_ZENABLE, TRUE);
  native->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
  native->SetRenderState(D3DRS_ZFUNC, D3DCMP_EQUAL);
  native->SetRenderState(D3DRS_STENCILENABLE, FALSE);
  native->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
  native->SetRenderState(D3DRS_ALPHATESTENABLE, FALSE);
  native->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);
  native->SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
  native->SetRenderState(D3DRS_FOGENABLE, FALSE);
  native->SetRenderState(D3DRS_CLIPPLANEENABLE, 0);
  native->SetRenderState(D3DRS_SRGBWRITEENABLE, FALSE);
  native->SetRenderState(D3DRS_COLORWRITEENABLE, 15);
  native->SetPixelShader(resources.pixel_shader.Get());
  native->SetStreamSourceFreq(0, 1);
  for (unsigned sampler = 0; sampler < 16; ++sampler) native->SetTexture(sampler, nullptr);
  native->SetTexture(1, msaa_scene_depth);
  native->SetSamplerState(1, D3DSAMP_MINFILTER, D3DTEXF_POINT);
  native->SetSamplerState(1, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
  native->SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
  native->SetSamplerState(1, D3DSAMP_SRGBTEXTURE, FALSE);
  native->SetSamplerState(1, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
  native->SetSamplerState(1, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
  const float depth_info[4] = {1.f / width, 1.f / height, msaa_scene_depth ? 1.f : 0.f, 2.e-7f};
  native->SetPixelShaderConstantF(8, depth_info, 1);
  native->SetTexture(D3DVERTEXTEXTURESAMPLER0, resources.palette.Get());
  native->SetSamplerState(D3DVERTEXTEXTURESAMPLER0, D3DSAMP_MINFILTER, D3DTEXF_POINT);
  native->SetSamplerState(D3DVERTEXTEXTURESAMPLER0, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
  native->SetSamplerState(D3DVERTEXTEXTURESAMPLER0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
  native->SetSamplerState(D3DVERTEXTEXTURESAMPLER0, D3DSAMP_SRGBTEXTURE, FALSE);
  native->SetSamplerState(D3DVERTEXTEXTURESAMPLER0, D3DSAMP_MAXMIPLEVEL, 0);
  native->SetSamplerState(D3DVERTEXTEXTURESAMPLER0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
  native->SetSamplerState(D3DVERTEXTEXTURESAMPLER0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
  // These states are identical for every replay submission.
  native->SetStreamSourceFreq(1, 1);
  native->SetStreamSourceFreq(2, 1);
  native->SetRenderState(D3DRS_TWOSIDEDSTENCILMODE, FALSE);
  native->SetRenderState(D3DRS_STENCILWRITEMASK, 0);
  native->SetRenderState(D3DRS_STENCILFAIL, D3DSTENCILOP_KEEP);
  native->SetRenderState(D3DRS_STENCILZFAIL, D3DSTENCILOP_KEEP);
  native->SetRenderState(D3DRS_STENCILPASS, D3DSTENCILOP_KEEP);
  UINT palette_row = 0;
  const MotionDraw* last_draw = nullptr;
  const MotionDraw* last_alpha = nullptr;
  const MotionDraw* last_bones = nullptr;
  IDirect3DVertexBuffer9* last_previous_vertices = nullptr;
  UINT last_previous_stride = 0;
  std::array<DWORD, 8> last_raster = {};
  std::array<std::array<float, 4>, 7> last_vertex_info = {};
  std::array<std::array<float, 4>, 8> last_pixel_info = {};
  for (size_t i = 0; i < state->current.size() && SUCCEEDED(status); ++i) {
    const auto& draw = state->current[i];
    if (draw.camera_only) continue;
    const bool matched = state->matches[i] >= 0;
    const auto& previous = matched ? state->previous[state->matches[i]] : draw;
    if (draw.skinned || draw.tree) {
      if (!last_bones || draw.tree != last_bones->tree || draw.bones != last_bones->bones)
        native->SetVertexShaderConstantF(draw.tree ? 95 : 120, draw.bones.data(), draw.tree ? 125 : 126);
      last_bones = &draw;
    }
    if (!last_draw || bool(draw.tree) != bool(last_draw->tree) || draw.skinned != last_draw->skinned)
      native->SetVertexShader(draw.tree ? resources.tree_shader.Get() : draw.skinned ? resources.skin_shader.Get() : resources.rigid_shader.Get());
    if (!last_draw || std::memcmp(&draw.clip, &last_draw->clip, sizeof(Matrix)) != 0)
      native->SetVertexShaderConstantF(0, &draw.clip.m[0][0], 4);
    if (!last_draw || std::memcmp(&draw.world, &last_draw->world, sizeof(Matrix)) != 0)
      native->SetVertexShaderConstantF(8, &draw.world.m[0][0], 4);
    // Upload contiguous controls together instead of entering the driver for
    // each float4. c18..c24 have the same contract across replay shaders.
    const std::array<std::array<float, 4>, 7> vertex_info = {{
        draw.clip_plane,
        {draw.tree ? float(draw.tree) : draw.packed_position ? 1.f : 0.f, (draw.vertex_alpha || draw.position_alpha) ? 1.f : 0.f, draw.wind ? 1.f : 0.f, draw.constant_vertex_alpha},
        {draw.alpha_uv_scale[0], draw.alpha_uv_scale[1], 0.f, 0.f},
        previous.wind_origin,
        draw.tree ? previous.tree_eye : std::array<float, 4>{draw.displaced ? 1.f : 0.f, draw.displacement, previous.displacement, 0.f},
        {draw.geometry ? 1.f : 0.f, 0.f, 0.f, 0.f},
        {(draw.skinned || draw.tree) ? (palette_row++ + 0.5f) / resources.palette_height : 0.f, 0.f, 0.f, 0.f},
    }};
    if (!last_draw || std::memcmp(vertex_info.data(), last_vertex_info.data(), sizeof(vertex_info)) != 0) {
      native->SetVertexShaderConstantF(18, vertex_info[0].data(), UINT(vertex_info.size()));
      last_vertex_info = vertex_info;
    }
    if (draw.wind) {
      // Wind constants overlap both skin and tree palette register ranges.
      last_bones = nullptr;
      native->SetVertexShaderConstantF(13, draw.wind_origin.data(), 1);
      native->SetVertexShaderConstantF(100, draw.wind_constants.data(), 6);
      native->SetVertexShaderConstantF(140, previous.wind_constants.data(), 6);
    }
    if (draw.tree) {
      native->SetVertexShaderConstantF(12, draw.tree_eye.data(), 1);
    }
    std::array<std::array<float, 4>, 8> pixel_info;
    std::memcpy(pixel_info.data(), draw.root_match >= 0 ? &state->previous[draw.root_match].unjittered_clip
                                                     : &previous.unjittered_clip, sizeof(Matrix));
    pixel_info[4] = {jitter[0] / width, jitter[1] / height, matched ? 1.f : draw.root_match >= 0 ? 2.f : 0.f, 0.f};
    pixel_info[5] = {float(draw.alpha_function), float(draw.alpha_reference) / 255.f, draw.alpha_pixel_uv_scale[0], draw.alpha_pixel_uv_scale[1]};
    pixel_info[6] = {draw.alpha_scale, (draw.vertex_alpha || draw.position_alpha || draw.constant_vertex_alpha != 1.f) ? 1.f : 0.f, draw.saturate_alpha ? 1.f : 0.f, draw.vertex_alpha_first ? 1.f : 0.f};
    pixel_info[7] = {draw.alpha_final_scale, draw.translucent ? 0.5f : 0.f, 0.f, 0.f};
    if (!last_draw || std::memcmp(pixel_info.data(), last_pixel_info.data(), sizeof(pixel_info)) != 0) {
      native->SetPixelShaderConstantF(0, pixel_info[0].data(), UINT(pixel_info.size()));
      last_pixel_info = pixel_info;
    }
    if (!last_draw || draw.alpha_texture != last_draw->alpha_texture) native->SetTexture(0, draw.alpha_texture.Get());
    if (draw.alpha_texture) for (unsigned sampler_state = 1; sampler_state < draw.alpha_sampler_states.size(); ++sampler_state) {
      if (!last_alpha || draw.alpha_sampler_states[sampler_state] != last_alpha->alpha_sampler_states[sampler_state])
        native->SetSamplerState(0, D3DSAMPLERSTATETYPE(sampler_state), draw.alpha_sampler_states[sampler_state]);
    }
    if (draw.alpha_texture) last_alpha = &draw;
    if (!last_draw || draw.motion_declaration != last_draw->motion_declaration || (!draw.motion_declaration && draw.declaration != last_draw->declaration))
      native->SetVertexDeclaration(draw.motion_declaration ? draw.motion_declaration.Get() : draw.declaration.Get());
    if (!last_draw || draw.vertices != last_draw->vertices || draw.mesh.stride != last_draw->mesh.stride
        || (draw.geometry ? 0 : draw.mesh.offset) != (last_draw->geometry ? 0 : last_draw->mesh.offset))
      native->SetStreamSource(0, draw.vertices.Get(), draw.geometry ? 0 : draw.mesh.offset, draw.mesh.stride);
    if (!last_draw || draw.secondary_vertices != last_draw->secondary_vertices || draw.mesh.secondary_offset != last_draw->mesh.secondary_offset
        || draw.mesh.secondary_stride != last_draw->mesh.secondary_stride)
      native->SetStreamSource(1, draw.secondary_vertices.Get(), draw.mesh.secondary_offset, draw.mesh.secondary_stride);
    if (!last_draw || (draw.geometry ? previous.vertices.Get() : nullptr) != last_previous_vertices
        || (draw.geometry ? draw.mesh.stride : 0) != last_previous_stride) {
      last_previous_vertices = draw.geometry ? previous.vertices.Get() : nullptr;
      last_previous_stride = draw.geometry ? draw.mesh.stride : 0;
      native->SetStreamSource(2, last_previous_vertices, 0, last_previous_stride);
    }
    if (!last_draw || draw.indices != last_draw->indices) native->SetIndices(draw.indices.Get());
    constexpr D3DRENDERSTATETYPE raster_states[] = {D3DRS_CULLMODE, D3DRS_DEPTHBIAS, D3DRS_SLOPESCALEDEPTHBIAS, D3DRS_ZFUNC,
                                                   D3DRS_STENCILENABLE, D3DRS_STENCILFUNC, D3DRS_STENCILREF, D3DRS_STENCILMASK};
    const std::array<DWORD, 8> raster = {draw.cull, draw.bias, draw.slope_bias, msaa_scene_depth ? DWORD(D3DCMP_LESSEQUAL) : draw.depth_function,
                                        DWORD(draw.stencil_function != D3DCMP_ALWAYS), draw.stencil_function, draw.stencil_reference, draw.stencil_mask};
    for (unsigned state = 0; state < raster.size(); ++state)
      if (!last_draw || raster[state] != last_raster[state]) native->SetRenderState(raster_states[state], raster[state]);
    last_raster = raster;
    if (msaa_scene_depth && (!last_draw || draw.translucent != last_draw->translucent))
      native->SetRenderState(D3DRS_ZWRITEENABLE, !draw.translucent);
    if (!last_draw || draw.min_depth != last_draw->min_depth || draw.max_depth != last_draw->max_depth) {
      const D3DVIEWPORT9 draw_viewport = {0, 0, width, height, draw.min_depth, draw.max_depth};
      native->SetViewport(&draw_viewport);
    }
    status = draw.mesh.indexed
                 ? native->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, draw.geometry ? -INT(draw.vertex_min) : draw.mesh.base_vertex,
                                                draw.vertex_min, draw.vertex_count, draw.mesh.first, draw.mesh.count / 3)
                 : native->DrawPrimitive(D3DPT_TRIANGLELIST, draw.geometry ? 0 : draw.mesh.first, draw.mesh.count / 3);
    if (!matched) {
      if (draw.root_match < 0) ++state->unmatched;
    } else if (draw.skinned) ++state->matched_skin;
    else ++state->matched_rigid;
    last_draw = &draw;
  }
  native->SetDepthStencilSurface(nullptr);
  for (unsigned i = 0; i < caps.NumSimultaneousRTs && i < targets.size(); ++i) native->SetRenderTarget(i, targets[i].Get());
  native->SetDepthStencilSurface(old_depth.Get());
  const HRESULT restored = saved->Apply();
  native->SetViewport(&viewport);
  state->ready = SUCCEEDED(status) && SUCCEEDED(restored);
  if (!state->ready) resources.failed = true;
  return state->ready;
}
}  // namespace acbrotherhood::taa
