// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../fog/binding_layout.hpp"
#include <iostream>
#include <stdexcept>
using namespace reshade::api;
void Check(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
int main() {
  try {
    descriptor_range root{.binding = 0, .dx_register_index = 12, .dx_register_space = 0, .count = 1, .visibility = shader_stage::pixel, .type = descriptor_type::constant_buffer};
    descriptor_range_with_static_samplers modern;
    static_cast<descriptor_range&>(modern) = root;
    modern.dx_register_index = 13;
    descriptor_range srv{.binding = 4, .dx_register_index = 8, .dx_register_space = 0, .count = 1, .visibility = shader_stage::pixel, .type = descriptor_type::texture_shader_resource_view};
    pipeline_layout_param params[] = {pipeline_layout_param(root), pipeline_layout_param(modern), pipeline_layout_param(1, &srv)};
    const hartapfelfx::fog::BindingLayout layout(3, params);
    root.dx_register_index = 99;
    modern.dx_register_index = 99;
    srv.dx_register_index = 99;
    Check(!layout.parameters[0].table && layout.parameters[0].ranges[0].dx_register_index == 12, "Legacy root CBV lost");
    Check(!layout.parameters[1].table && layout.parameters[1].ranges[0].dx_register_index == 13, "Modern root CBV lost or ranges not owned");
    Check(layout.parameters[2].table && layout.parameters[2].ranges[0].dx_register_index == 8, "SRV table not owned");
    Check(layout.parameters[2].ranges[0].binding == 4, "Descriptor heap offset lost");
    params[2].type = pipeline_layout_param_type::push_descriptors_with_ranges;
    const hartapfelfx::fog::BindingLayout pushed(3, params);
    Check(!pushed.parameters[2].table, "Root descriptor mistaken for GPU table");
    modern.dx_register_space = 71;
    pipeline_layout_param static_table(1, &modern);
    const hartapfelfx::fog::BindingLayout namespaced(1, &static_table);
    Check(namespaced.parameters[0].table && namespaced.parameters[0].ranges[0].dx_register_space == 71, "Private binding space lost");
    const hartapfelfx::fog::BindingLayout empty(0, nullptr);
    Check(empty.parameters.empty(), "Empty layout invalid");
    descriptor_range camera{.binding = 0, .dx_register_index = 12, .dx_register_space = 0, .count = 1, .visibility = shader_stage::all, .type = descriptor_type::constant_buffer};
    descriptor_range sunlight = camera;
    sunlight.dx_register_index = 13;
    descriptor_range hdr = sunlight;
    hdr.dx_register_space = 50;
    pipeline_layout_param common[] = {pipeline_layout_param(camera), pipeline_layout_param(sunlight), pipeline_layout_param(hdr)};
    std::vector<pipeline_layout_param> extended;
    Check(hartapfelfx::fog::ExtendFogLayout(common, &extended), "Native common signature was rejected");
    Check(extended.size() == 13, "Expected fog, cloud and lighting bindings");
    Check(extended[11].push_descriptors.dx_register_space == 73 && extended[11].push_descriptors.type == descriptor_type::constant_buffer
        && extended[12].push_descriptors.dx_register_space == 54, "Lighting settings or contact field root missing");
    Check(extended[2].push_descriptors.dx_register_space == 50 && extended[2].push_descriptors.dx_register_index == 13, "HDR root index or register changed");
    Check(!hartapfelfx::fog::ExtendFogLayout(std::span(common, 1), &extended), "Unrelated/local signature modified");
    common[2] = pipeline_layout_param(constant_range{.binding = 0, .dx_register_index = 0, .dx_register_space = 0, .count = 49, .visibility = shader_stage::all});
    Check(!hartapfelfx::fog::ExtendFogLayout(common, &extended), "Root DWORD overflow accepted");
    common[2].push_constants.count = 44;
    Check(hartapfelfx::fog::ExtendFogLayout(common, &extended), "Valid 64-DWORD signature rejected");
    Check(extended.size() == 11, "Lighting extension exceeded the remaining root budget");
    descriptor_range compute_cbvs{.binding = 0, .dx_register_index = 1, .dx_register_space = 0,
        .count = 15, .visibility = shader_stage::compute, .type = descriptor_type::constant_buffer};
    pipeline_layout_param compute_params[] = {pipeline_layout_param(camera), pipeline_layout_param(1, &compute_cbvs)};
    Check(hartapfelfx::fog::ExtendFogLayout(compute_params, &extended), "RTGI constant-table signature rejected");
    const hartapfelfx::fog::BindingLayout compute_layout(uint32_t(extended.size()), extended.data());
    Check(extended.size() == 15 && compute_layout.parameters[1].table, "Native RTGI constant table changed");
    for (uint32_t index = 12; index < 15; ++index) {
      const auto& range = compute_layout.parameters[index].ranges.front();
      Check(!compute_layout.parameters[index].table && range.count == 1 && range.visibility == shader_stage::compute,
          "RTGI material inputs must be compute root descriptors");
      Check(range.dx_register_space == (index == 14 ? 55u : 59u)
          && range.type == (index == 12 ? descriptor_type::constant_buffer : descriptor_type::buffer_shader_resource_view),
          "RTGI material context, records or cloud input missing");
    }
    camera.dx_register_space = 71;
    common[2] = pipeline_layout_param(camera);
    Check(!hartapfelfx::fog::ExtendFogLayout(common, &extended), "Private binding conflict accepted");
    resource_desc scene_depth{};
    scene_depth.type = resource_type::texture_2d;
    scene_depth.texture.width = 1920;
    scene_depth.texture.height = 1080;
    scene_depth.texture.samples = 1;
    scene_depth.usage = resource_usage::depth_stencil | resource_usage::shader_resource;
    resource_view_desc depth_view{};
    depth_view.type = resource_view_type::texture_2d;
    depth_view.format = format::r32_float_x8_uint;
    Check(hartapfelfx::fog::IsFogDepthInput(scene_depth, depth_view), "Native Raster/RT/PT scene depth rejected");
    auto atlas = scene_depth;
    atlas.texture.width = 1024;
    atlas.texture.height = 512;
    atlas.usage = resource_usage::shader_resource | resource_usage::unordered_access;
    auto atlas_view = depth_view;
    atlas_view.format = format::r8g8b8a8_unorm;
    Check(!hartapfelfx::fog::IsFogDepthInput(atlas, atlas_view), "RT 1024x512 colour atlas accepted as depth");
    atlas.texture.width = 512;
    Check(!hartapfelfx::fog::IsFogDepthInput(atlas, atlas_view), "RT 512x512 colour atlas accepted as depth");
    atlas_view.format = format::r32_float;
    Check(!hartapfelfx::fog::IsFogDepthInput(atlas, atlas_view), "Scalar colour texture accepted as depth");
    depth_view.format = format::r32_float;
    Check(hartapfelfx::fog::IsFogDepthInput(scene_depth, depth_view), "Scalar depth component rejected");
    scene_depth.texture.samples = 4;
    Check(!hartapfelfx::fog::IsFogDepthInput(scene_depth, depth_view), "Unsupported multisample depth accepted");
    viewport scene_view{0, 0, 1920, 1080, 0, 1}, probe_view{0, 0, 256, 256, 0, 1};
    Check(hartapfelfx::fog::MatchesFogViewport(scene_view, scene_view), "Main view rejected");
    Check(!hartapfelfx::fog::MatchesFogViewport(probe_view, scene_view), "RT probe sky accepted a main-view fog volume");
    std::cout << "PASS: root CBVs, owned ranges, table offsets, private spaces, depth-only source selection, view isolation and empty layouts\n";
  } catch (const std::exception& e) {
    std::cerr << e.what() << '\n';
    return 1;
  }
}
