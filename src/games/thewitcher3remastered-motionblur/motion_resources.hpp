/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include "../../utils/d3d12_resource_pool.hpp"

namespace witcher::motion {
using Microsoft::WRL::ComPtr;
using renodx::utils::d3d12_resource_pool::Completion;
using renodx::utils::d3d12_resource_pool::Queue;
using renodx::utils::d3d12_resource_pool::Allocation;
using ResourcePool = renodx::utils::d3d12_resource_pool::ResourcePool<768ull << 20, 65536>;
}  // namespace witcher::motion
