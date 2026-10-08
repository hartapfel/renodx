// ReShade device stub for CPU lifecycle checks; unused GPU calls return defaults.
#pragma once
struct MockDevice : reshade::api::device {
  using Key = std::array<uint8_t, 16>;
  mutable std::map<Key, std::pair<HMODULE, uint64_t>> private_data;
  mutable unsigned collisions = 0;
  unsigned layout_creations = 0;
  uint64_t get_native() const override { return 0; }
  void get_private_data(const uint8_t* guid, uint64_t* value) const override {
    Key key{}; std::memcpy(key.data(), guid, key.size());
    auto it = private_data.find(key);
    *value = it == private_data.end() ? 0 : it->second.second;
  }
  void set_private_data(const uint8_t* guid, uint64_t value) override {
    Key key{}; std::memcpy(key.data(), guid, key.size());
    HMODULE owner = ModuleForAddress(_ReturnAddress());
    auto it = private_data.find(key);
    if (value && it != private_data.end() && it->second.second && it->second.first != owner) ++collisions;
    if (value) private_data[key] = {owner, value}; else private_data.erase(key);
  }
  device_api get_api() const override { return device_api::d3d12; }
  bool check_capability(device_caps capability) const override { return {}; }
  bool check_format_support(format format, resource_usage usage) const override { return {}; }
  bool create_sampler(const sampler_desc &desc, sampler *out_sampler) override { return {}; }
  void destroy_sampler(sampler sampler) override {  }
  bool create_resource(const resource_desc &desc, const subresource_data *initial_data, resource_usage initial_state, resource *out_resource, void **shared_handle) override { return {}; }
  void destroy_resource(resource resource) override {  }
  resource_desc get_resource_desc(resource resource) const override { return {}; }
  bool create_resource_view(resource resource, resource_usage usage_type, const resource_view_desc &desc, resource_view *out_view) override { return {}; }
  void destroy_resource_view(resource_view view) override {  }
  resource get_resource_from_view(resource_view view) const override { return {}; }
  resource_view_desc get_resource_view_desc(resource_view view) const override { return {}; }
  bool map_buffer_region(resource resource, uint64_t offset, uint64_t size, map_access access, void **out_data) override { return {}; }
  void unmap_buffer_region(resource resource) override {  }
  bool map_texture_region(resource resource, uint32_t subresource, const subresource_box *box, map_access access, subresource_data *out_data) override { return {}; }
  void unmap_texture_region(resource resource, uint32_t subresource) override {  }
  void update_buffer_region(const void *data, resource dest, uint64_t dest_offset, uint64_t size) override {  }
  void update_texture_region(const subresource_data &data, resource dest, uint32_t dest_subresource, const subresource_box *dest_box) override {  }
  bool create_pipeline(pipeline_layout layout, uint32_t subobject_count, const pipeline_subobject *subobjects, pipeline *out_pipeline) override { return {}; }
  void destroy_pipeline(pipeline pipeline) override {  }
  bool create_pipeline_layout(uint32_t, const pipeline_layout_param*, pipeline_layout* out_layout) override { ++layout_creations; *out_layout = {}; return false; }
  void destroy_pipeline_layout(pipeline_layout layout) override {  }
  bool allocate_descriptor_tables(uint32_t count, pipeline_layout layout, uint32_t param, descriptor_table *out_tables) override { return {}; }
  void free_descriptor_tables(uint32_t count, const descriptor_table *tables) override {  }
  void get_descriptor_heap_offset(descriptor_table table, uint32_t binding, uint32_t array_offset, descriptor_heap *out_heap, uint32_t *out_offset) const override {  }
  void copy_descriptor_tables(uint32_t count, const descriptor_table_copy *copies) override {  }
  void update_descriptor_tables(uint32_t count, const descriptor_table_update *updates) override {  }
  bool create_query_heap(query_type type, uint32_t count, query_heap *out_heap) override { return {}; }
  void destroy_query_heap(query_heap heap) override {  }
  bool get_query_heap_results(query_heap heap, uint32_t first, uint32_t count, void *results, uint32_t stride) override { return {}; }
  void set_resource_name(resource resource, const char *name) override {  }
  void set_resource_view_name(resource_view view, const char *name) override {  }
  bool create_fence(uint64_t initial_value, fence_flags flags, fence *out_fence, void **shared_handle) override { return {}; }
  void destroy_fence(fence fence) override {  }
  uint64_t get_completed_fence_value(fence fence) const override { return {}; }
  bool wait(fence fence, uint64_t value, uint64_t timeout = UINT64_MAX) override { return {}; }
  bool signal(fence fence, uint64_t value) override { return {}; }
  bool get_property(device_properties property, void *data) const override { return {}; }
  uint64_t get_resource_view_gpu_address(resource_view view) const override { return {}; }
  void get_acceleration_structure_size(acceleration_structure_type type, acceleration_structure_build_flags flags, uint32_t input_count, const acceleration_structure_build_input *inputs, uint64_t *out_size, uint64_t *out_build_scratch_size, uint64_t *out_update_scratch_size) const override {  }
  bool get_pipeline_shader_group_handles(pipeline pipeline, uint32_t first, uint32_t count, void *out_handles) override { return {}; }
};
