/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Standalone D3D11 WARP validation of the reconstruction paths, compiled as
// cs_5_0 for the software adapter. Shipping shaders are strictly built as cs_6_6.
#define NOMINMAX
#include <d3d11.h>
#include <bit>
#include <DirectXPackedVector.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include <vector>
#include "../motion_blur_config.h"

using Microsoft::WRL::ComPtr;
using Pixel = std::array<float, 4>;
constexpr unsigned WIDTH = 769, HEIGHT = 385;
constexpr unsigned TILES_X = (WIDTH + WITCHER_MOTION_TILE - 1) / WITCHER_MOTION_TILE;
constexpr unsigned TILES_Y = (HEIGHT + WITCHER_MOTION_TILE - 1) / WITCHER_MOTION_TILE;
struct Parameters {
  float angle = 180.f; unsigned samples = 64, diagnostic = 0; float seconds = 0;
  unsigned components = 3; float object_angle = 180.f; unsigned cache_enabled = 0, half_resolution = 0;
  unsigned cache_width = WIDTH, cache_height = HEIGHT, half_width = (WIDTH + 1) / 2, half_height = (HEIGHT + 1) / 2;
};
void Check(HRESULT result) { if (FAILED(result)) throw std::runtime_error("D3D failure " + std::to_string(result)); }
void Require(bool pass, const char* reason) { if (!pass) throw std::runtime_error(reason); }

int main(int argc, char** argv) {
  try {
    Require(argc == 8 || argc == 11, "Expected seven candidate shaders, optionally followed by three baseline shaders");
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> context;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context));
    ComPtr<ID3D11ComputeShader> shaders[7], baseline[3];
    for (unsigned i = 0; i < 7; ++i) {
      std::ifstream stream(argv[i + 1], std::ios::binary);
      std::vector<char> bytes((std::istreambuf_iterator<char>(stream)), {});
      Check(device->CreateComputeShader(bytes.data(), bytes.size(), nullptr, &shaders[i]));
    }
    if (argc == 11) for (unsigned i = 0; i < 3; ++i) {
      std::ifstream stream(argv[i + 8], std::ios::binary);
      std::vector<char> bytes((std::istreambuf_iterator<char>(stream)), {});
      Check(device->CreateComputeShader(bytes.data(), bytes.size(), nullptr, &baseline[i]));
    }
    float maximum_relative_error = 0.f;
    double total_squared_relative_error = 0;
    uint64_t compared_channels = 0;
    ComPtr<ID3D11Buffer> buffer;
    D3D11_BUFFER_DESC buffer_desc = {sizeof(Parameters), D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER, 0, 0, 0};
    Check(device->CreateBuffer(&buffer_desc, nullptr, &buffer));
    context->CSSetConstantBuffers(0, 1, buffer.GetAddressOf());
    ComPtr<ID3D11Buffer> scratch;
    ComPtr<ID3D11UnorderedAccessView> scratch_uav;
    std::vector<Pixel> scratch_data(WITCHER_MOTION_CACHE + (WIDTH + 8) * (HEIGHT + 8) + ((WIDTH + 1) / 2) * ((HEIGHT + 1) / 2) + 64);
    scratch_data[0] = {1, 0, 1, 0};
    D3D11_BUFFER_DESC scratch_desc = {UINT(scratch_data.size() * sizeof(Pixel)), D3D11_USAGE_DEFAULT,
        D3D11_BIND_UNORDERED_ACCESS, 0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, sizeof(Pixel)};
    D3D11_SUBRESOURCE_DATA initial_scratch = {scratch_data.data(), 0, 0};
    Check(device->CreateBuffer(&scratch_desc, &initial_scratch, &scratch));
    Check(device->CreateUnorderedAccessView(scratch.Get(), nullptr, &scratch_uav));
    ComPtr<ID3D11Buffer> scratch_readback;
    D3D11_BUFFER_DESC scratch_readback_desc = {scratch_desc.ByteWidth, D3D11_USAGE_STAGING, 0, D3D11_CPU_ACCESS_READ, 0, 0};
    Check(device->CreateBuffer(&scratch_readback_desc, nullptr, &scratch_readback));
    ComPtr<ID3D11SamplerState> sampler;
    D3D11_SAMPLER_DESC sampler_desc = {};
    sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sampler_desc.AddressU = sampler_desc.AddressV = sampler_desc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler_desc.MaxLOD = D3D11_FLOAT32_MAX;
    Check(device->CreateSamplerState(&sampler_desc, &sampler));
    context->CSSetSamplers(0, 1, sampler.GetAddressOf());
    ComPtr<ID3D11Texture2D> textures[3], readback;
    ComPtr<ID3D11ShaderResourceView> srvs[3];
    ComPtr<ID3D11UnorderedAccessView> uavs[3];
    for (unsigned i = 0; i < 3; ++i) {
      D3D11_TEXTURE2D_DESC desc = {WIDTH, HEIGHT,
          1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT,
          D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS, 0, 0};
      Check(device->CreateTexture2D(&desc, nullptr, &textures[i]));
      Check(device->CreateShaderResourceView(textures[i].Get(), nullptr, &srvs[i]));
      Check(device->CreateUnorderedAccessView(textures[i].Get(), nullptr, &uavs[i]));
    }
    D3D11_TEXTURE2D_DESC desc = {WIDTH, HEIGHT, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0},
        D3D11_USAGE_STAGING, 0, D3D11_CPU_ACCESS_READ, 0};
    Check(device->CreateTexture2D(&desc, nullptr, &readback));
    std::vector<Pixel> scene(WIDTH * HEIGHT), motion(WIDTH * HEIGHT), depth(WIDTH * HEIGHT, Pixel{.1f, 0, 0, 0}), result(WIDTH * HEIGHT);
    Parameters parameters;
    unsigned cases = 0;
    bool independent_intensity = false;
    bool test_half = false;
    bool capacity_test = false;
    float cache_max_error = 0;
    auto run = [&]() {
      if (!independent_intensity) parameters.object_angle = parameters.angle;
      ID3D11ShaderResourceView* null_srvs[4] = {};
      ID3D11UnorderedAccessView* null_uav = nullptr;
      context->CSSetShaderResources(0, 4, null_srvs);
      context->CSSetUnorderedAccessViews(0, 1, &null_uav, nullptr);
      context->UpdateSubresource(buffer.Get(), 0, nullptr, &parameters, 0, 0);
      context->UpdateSubresource(textures[0].Get(), 0, nullptr, scene.data(), WIDTH * sizeof(Pixel), 0);
      auto packed_motion = motion;
      for (unsigned i = 0; i < motion.size(); ++i) {
        using namespace DirectX::PackedVector;
        const unsigned bits = std::bit_cast<unsigned>(depth[i][0]);
        for (unsigned channel = 0; channel < 2; ++channel) {
          const unsigned chunk = (bits >> (channel * 15)) & 0x7fff;
          packed_motion[i][channel + 2] = XMConvertHalfToFloat(((chunk & 0x3fff) + 0x400) | ((chunk & 0x4000) << 1));
        }
      }
      context->UpdateSubresource(textures[1].Get(), 0, nullptr, packed_motion.data(), WIDTH * sizeof(Pixel), 0);
      std::vector<Pixel> reference;
      for (unsigned version = 0; version < 2u; ++version) {
      parameters.cache_enabled = version;
      parameters.half_resolution = version && test_half ? 1u : 0u;
      if (capacity_test) {
        std::fill(scratch_data.begin() + WITCHER_MOTION_CACHE, scratch_data.end(), Pixel{12345, 23456, 34567, 45678});
        context->UpdateSubresource(scratch.Get(), 0, nullptr, scratch_data.data(), 0, 0);
      }
      context->UpdateSubresource(buffer.Get(), 0, nullptr, &parameters, 0, 0);
      const unsigned passes[] = {3, 0, 1, 2, 4};
      for (unsigned pass : passes) {
        if (pass == 3 && !version) continue;
        if (pass == 4 && !parameters.half_resolution) continue;
        ID3D11ShaderResourceView* inputs[] = {nullptr, srvs[0].Get(), srvs[1].Get(), nullptr};
        context->CSSetShaderResources(0, 4, inputs);
        ID3D11UnorderedAccessView* outputs[] = {uavs[2].Get(), scratch_uav.Get()};
        context->CSSetUnorderedAccessViews(0, 2, outputs, nullptr);
        context->CSSetShader(argc == 11 && version == 0 ? baseline[pass].Get() : shaders[pass == 2 ? (parameters.half_resolution ? 5 : parameters.cache_enabled ? 6 : 2) : pass].Get(), nullptr, 0);
        context->Dispatch(pass == 0 ? TILES_X : pass == 1 ? (TILES_X + 7) / 8 : ((pass == 2 && parameters.half_resolution ? (WIDTH + 1) / 2 : WIDTH) + 7) / 8,
                         pass == 0 ? TILES_Y : pass == 1 ? (TILES_Y + 7) / 8 : ((pass == 2 && parameters.half_resolution ? (HEIGHT + 1) / 2 : HEIGHT) + 7) / 8, 1);
        context->CSSetShaderResources(0, 4, null_srvs);
        context->CSSetUnorderedAccessViews(0, 1, &null_uav, nullptr);
      }
      context->CopyResource(readback.Get(), textures[2].Get());
      D3D11_MAPPED_SUBRESOURCE mapped;
      Check(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &mapped));
      for (unsigned y = 0; y < HEIGHT; ++y)
        std::copy_n(reinterpret_cast<const Pixel*>(static_cast<const char*>(mapped.pData) + y * mapped.RowPitch), WIDTH, result.data() + y * WIDTH);
      context->Unmap(readback.Get(), 0);
        if (version == 0) reference = result;
        else for (unsigned i = 0; i < result.size(); ++i) for (unsigned c = 0; c < 3; ++c) {
          float error = std::abs(result[i][c] - reference[i][c]) / std::max(1.f, std::abs(reference[i][c]));
          maximum_relative_error = std::max(maximum_relative_error, error);
          if ((!test_half || (capacity_test && (parameters.cache_width < WIDTH || parameters.cache_height < HEIGHT
                            || parameters.half_width < (WIDTH + 1) / 2 || parameters.half_height < (HEIGHT + 1) / 2))) && argc != 11) {
            cache_max_error = std::max(cache_max_error, error);
            Require(error < 1e-5f, "Cached motion changed reconstruction");
          }
          total_squared_relative_error += double(error) * error;
          ++compared_channels;
        }
      }
      ++cases;
      if (capacity_test) {
        context->CopyResource(scratch_readback.Get(), scratch.Get());
        D3D11_MAPPED_SUBRESOURCE mapped;
        Check(context->Map(scratch_readback.Get(), 0, D3D11_MAP_READ, 0, &mapped));
        const auto* values = static_cast<const Pixel*>(mapped.pData);
        const unsigned end = WITCHER_MOTION_CACHE + parameters.cache_width * parameters.cache_height
                             + parameters.half_width * parameters.half_height;
        bool intact = true;
        for (unsigned i = end; i < scratch_data.size(); ++i) intact &= values[i] == scratch_data[i];
        context->Unmap(scratch_readback.Get(), 0);
        Require(intact, "Shader wrote beyond the declared root UAV allocation");
      }
      for (unsigned i = 0; i < result.size(); ++i) {
        for (float value : result[i]) Require(std::isfinite(value), "Nonfinite output");
        Require(result[i][3] == scene[i][3], "Source alpha changed");
      }
    };
    for (unsigned i = 0; i < scene.size(); ++i) scene[i] = {float(i % 7) - 1, float(i % 11), float(i % 17), float(i % 5) * .2f};
    run(); Require(result == scene, "Stationary frame changed");
    for (float dx : {0.f, 1.f, 4.f, 16.f, 128.f, 1000.f}) {
      std::fill(scene.begin(), scene.end(), Pixel{-.25f, 3.f, 16.f, .7f});
      std::fill(motion.begin(), motion.end(), Pixel{dx / WIDTH, dx * .37f / HEIGHT, 0, 0});
      run();
      for (const auto& pixel : result) for (unsigned k = 0; k < 3; ++k)
        Require(std::abs(pixel[k] - scene[0][k]) < 3e-5f, "HDR constant was clipped or altered");
    }
    // The motion is horizontal. Full-resolution vertical detail must survive.
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x)
      scene[y * WIDTH + x] = {float(y % 2) * 4, 2, 3, .7f};
    std::fill(motion.begin(), motion.end(), Pixel{32.f / WIDTH, 0, 0, 0});
    run();
    for (unsigned i = 0; i < result.size(); ++i) Require(std::abs(result[i][0] - scene[i][0]) < 1e-4f, "Orthogonal one-pixel detail lost");

    // Actual world speed is fixed; per-frame displacement changes with FPS.
    // Compare impulse spread to the analytical box-shutter standard deviation.
    std::fill(scene.begin(), scene.end(), Pixel{0, 0, 0, 1});
    for (unsigned y = 0; y < HEIGHT; ++y) scene[y * WIDTH + 128] = {8, 4, 2, 1};
    std::vector<double> spreads;
    for (float fps : {30.f, 60.f, 120.f, 240.f}) {
      std::fill(motion.begin(), motion.end(), Pixel{960.f / fps / WIDTH, 0, 0, 0});
      run();
      double energy = 0, moment = 0;
      for (unsigned y = 16; y < HEIGHT - 16; ++y) for (unsigned x = 64; x < 192; ++x) {
        energy += result[y * WIDTH + x][0];
        moment += result[y * WIDTH + x][0] * std::pow(double(x) - 128, 2);
      }
      spreads.push_back(std::sqrt(moment / energy));
      std::cout << "fps=" << fps << " spread=" << spreads.back() << " box_reference=" << 480.f / fps / std::sqrt(12.f) << '\n';
    }
    for (unsigned i = 1; i < spreads.size(); ++i)
      Require(spreads[i - 1] > spreads[i] * 1.65 && spreads[i - 1] < spreads[i] * 2.3, "FPS response does not follow shutter duration");

    // At the former maximum radius, a one-pixel HDR light must not leave sampling
    // holes. This exposes duplicate taps when both reconstruction axes align.
    std::fill(motion.begin(), motion.end(), Pixel{128.f / WIDTH, 0, 0, 0});
    run();
    float minimum_trail = 8.f;
    for (unsigned y = 16; y < HEIGHT - 16; ++y) for (unsigned x = 104; x <= 152; ++x)
      minimum_trail = std::min(minimum_trail, result[y * WIDTH + x][0]);
    std::cout << "one_pixel_light_minimum_trail=" << minimum_trail << '\n';
    Require(minimum_trail > .02f, "Narrow moving light developed sampling holes");

    // A stationary foreground in front of a fast background must remain clear.
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x) {
      bool foreground = x >= 96 && x < 160;
      scene[y * WIDTH + x] = foreground ? Pixel{float((x + y) % 2) * 4, 0, 0, .3f} : Pixel{0, float(x % 2) * 4, 0, .9f};
      motion[y * WIDTH + x] = {foreground ? 0.f : 64.f / WIDTH, 0, 0, 0};
      depth[y * WIDTH + x] = {foreground ? 1.f : .1f, 0, 0, 0};
    }
    run();
    float foreground_error = 0;
    unsigned foreground_errors = 0;
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 96; x < 160; ++x)
      for (unsigned channel = 0; channel < 3; ++channel) {
        float error = std::abs(result[y * WIDTH + x][channel] - scene[y * WIDTH + x][channel]);
        foreground_error = std::max(foreground_error, error);
        foreground_errors += error > 1e-4f;
      }
    std::cout << "stationary_foreground_max_error=" << foreground_error << " affected_channels=" << foreground_errors << '\n';
    Require(foreground_error < 1e-4f, "Background motion smeared stationary foreground");

    // A moving foreground contributes outside its original silhouette; compare
    // with exact temporal coverage of a translating, opaque rectangle.
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x) {
      bool foreground = x >= 96 && x < 160;
      scene[y * WIDTH + x] = foreground ? Pixel{1, 0, 0, 1} : Pixel{0, 1, 0, 1};
      motion[y * WIDTH + x] = {foreground ? 32.f / WIDTH : 0.f, 0, 0, 0};
    }
    run();
    Require(result[48 * WIDTH + 93][0] > .01f && result[48 * WIDTH + 162][0] > .01f, "Moving silhouette did not spread onto background");
    double error = 0;
    for (unsigned y = 16; y < HEIGHT - 16; ++y) for (unsigned x = 80; x < 176; ++x) {
      double coverage = std::clamp(std::min(double(x) + .5 - 88, 168 - (double(x) + .5)) / 16, 0., 1.);
      error += std::pow(result[y * WIDTH + x][0] - coverage, 2);
    }
    std::cout << "moving_silhouette_coverage_rmse=" << std::sqrt(error / ((HEIGHT - 32) * 96)) << '\n';
    Require(std::sqrt(error / ((HEIGHT - 32) * 96)) < .16, "Silhouette coverage departed too far from temporal reference");

    // A camera pan gives separate static surfaces the same screen-space
    // motion. Changing their depth must not make the nearer silhouette sharp:
    // the temporal reference is the same whole-image translation in both cases.
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x)
      scene[y * WIDTH + x] = x >= 96 && x < 160 ? Pixel{1, 0, 0, 1} : Pixel{0, 1, 0, 1};
    std::fill(motion.begin(), motion.end(), Pixel{96.f / WIDTH, 0, 0, 0});
    std::fill(depth.begin(), depth.end(), Pixel{.1f, 0, 0, 0});
    run();
    const auto common_motion_reference = result;
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 96; x < 160; ++x)
      depth[y * WIDTH + x] = {1.f, 0, 0, 0};
    run();
    float common_motion_error = 0;
    for (unsigned i = 0; i < result.size(); ++i)
      common_motion_error = std::max(common_motion_error, std::abs(result[i][0] - common_motion_reference[i][0]));
    std::cout << "camera_pan_depth_edge_max_error=" << common_motion_error
              << " foreground_edge=" << result[48 * WIDTH + 96][0]
              << " equal_depth_reference=" << common_motion_reference[48 * WIDTH + 96][0] << '\n';
    Require(common_motion_error < 1e-4f, "Depth discontinuity made a co-moving foreground artificially sharp");

    // All three shutter radii (240/120/40 pixels) exceeded the old ceiling.
    // A fixed clamp makes these identical instead of following 30/60/180 FPS.
    std::fill(scene.begin(), scene.end(), Pixel{0, 0, 0, 1});
    std::fill(depth.begin(), depth.end(), Pixel{.1f, 0, 0, 0});
    for (unsigned y = 0; y < HEIGHT; ++y) scene[y * WIDTH + 384] = {8, 4, 2, 1};
    spreads.clear();
    for (float fps : {30.f, 60.f, 180.f}) {
      std::fill(motion.begin(), motion.end(), Pixel{28800.f / fps / WIDTH, 0, 0, 0});
      run();
      double energy = 0, moment = 0;
      for (unsigned y = 16; y < HEIGHT - 16; ++y) for (unsigned x = 128; x <= 640; ++x) {
        energy += result[y * WIDTH + x][0];
        moment += result[y * WIDTH + x][0] * std::pow(double(x) - 384, 2);
      }
      spreads.push_back(std::sqrt(moment / energy));
      const double reference = 7200. / fps / std::sqrt(3.);
      std::cout << "long_trail_fps=" << fps << " spread=" << spreads.back() << " box_reference=" << reference << '\n';
      Require(spreads.back() > reference * .8 && spreads.back() < reference * 1.2, "Long trail is truncated or mis-scaled");
      // A bounded stochastic filter trades per-pixel noise for constant work.
      // Test spatially averaged coverage and energy: demanding every individual
      // pixel hit a one-pixel emitter required the old runaway tap expansion.
      float minimum = 8.f;
      for (unsigned x = 384 - unsigned(5400 / fps); x <= 384 + unsigned(5400 / fps); ++x) {
        float column = 0.f;
        for (unsigned y = 16; y < HEIGHT - 16; ++y) column += result[y * WIDTH + x][0];
        minimum = std::min(minimum, column / float(HEIGHT - 32));
      }
      std::cout << "long_light_minimum_mean=" << minimum << " energy=" << energy / (HEIGHT - 32) << '\n';
      Require(minimum > .001f, "Long light trail developed a systematic sampling gap");
      Require(energy / (HEIGHT - 32) > 6.f && energy / (HEIGHT - 32) < 10.f, "Long light energy was lost or amplified");
    }
    Require(spreads[0] > spreads[1] * 1.8 && spreads[0] < spreads[1] * 2.2, "Fast pan lost 30/60 FPS scaling");
    Require(spreads[1] > spreads[2] * 2.7 && spreads[1] < spreads[2] * 3.3, "Fast pan lost 60/180 FPS scaling");

    // A moving object sweeps into pixels more than one coarse tile away.
    // This fails even with unclamped vectors if NeighborMax stays a 3x3 search.
    std::fill(scene.begin(), scene.end(), Pixel{0, 1, 0, 1});
    std::fill(motion.begin(), motion.end(), Pixel{0, 0, 0, 0});
    for (unsigned y = 128; y < 256; ++y) for (unsigned x = 600; x < 616; ++x) {
      scene[y * WIDTH + x] = {1, 0, 0, 1};
      motion[y * WIDTH + x] = {1024.f / WIDTH, 0, 0, 0};
      depth[y * WIDTH + x] = {1.f, 0, 0, 0};
    }
    run();
    std::cout << "distant_silhouette_coverage=" << result[192 * WIDTH + 380][0] << '\n';
    Require(result[192 * WIDTH + 380][0] > .005f, "Long moving silhouette did not reach distant tiles");
    Require(result[32 * WIDTH + 380][0] == 0.f, "Horizontal object motion leaked vertically");

    // Long background streaks still cannot smear a stationary near character.
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x) {
      bool foreground = x >= 320 && x < 448;
      scene[y * WIDTH + x] = foreground ? Pixel{float((x + y) % 2) * 4, 0, 0, 1} : Pixel{0, float(x % 2) * 4, 0, 1};
      motion[y * WIDTH + x] = {foreground ? 0.f : 960.f / WIDTH, 0, 0, 0};
      depth[y * WIDTH + x] = {foreground ? 1.f : .1f, 0, 0, 0};
    }
    run();
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 320; x < 448; ++x)
      for (unsigned channel = 0; channel < 3; ++channel)
        Require(std::abs(result[y * WIDTH + x][channel] - scene[y * WIDTH + x][channel]) < 1e-4f, "Long background motion smeared stationary foreground");

    // Viewport clipping must preserve signed HDR constants even when motion
    // crosses the entire image. Include axis-parallel and diagonal segments.
    std::fill(scene.begin(), scene.end(), Pixel{-.25f, 3.f, 16.f, .7f});
    std::fill(depth.begin(), depth.end(), Pixel{.1f, 0, 0, 0});
    for (Pixel velocity : {Pixel{10, 0, 0, 0}, Pixel{0, -10, 0, 0}, Pixel{-10, 10, 0, 0}}) {
      std::fill(motion.begin(), motion.end(), velocity);
      run();
      for (const auto& pixel : result) for (unsigned channel = 0; channel < 3; ++channel)
        Require(std::abs(pixel[channel] - scene[0][channel]) < 1e-4f, "Clipped long shutter changed constant HDR");
    }
    parameters.angle = 0.f;
    run();
    Require(result == scene, "Zero shutter did not disable long motion blur");
    // Regression for the UI report: 25 and 100 must not look equivalent.
    std::fill(scene.begin(), scene.end(), Pixel{0, 0, 0, 1});
    std::fill(motion.begin(), motion.end(), Pixel{64.f / WIDTH, 0, 0, 0});
    for (unsigned y = 0; y < HEIGHT; ++y) scene[y * WIDTH + WIDTH / 2] = {8, 4, 2, 1};
    double intensity_spread = 0;
    for (float intensity : {0.f, 25.f, 100.f}) {
      parameters.angle = intensity * 3.6f;
      run();
      if (intensity == 0.f) {
        Require(result == scene, "Intensity zero did not preserve moving scene detail");
        continue;
      }
      double energy = 0, moment = 0;
      for (unsigned y = 16; y < HEIGHT - 16; ++y) for (unsigned x = WIDTH / 2 - 64; x < WIDTH / 2 + 64; ++x) {
        energy += result[y * WIDTH + x][0];
        moment += result[y * WIDTH + x][0] * std::pow(double(x) - WIDTH / 2, 2);
      }
      const double spread = std::sqrt(moment / energy);
      std::cout << "intensity=" << intensity << " spread=" << spread << '\n';
      if (intensity == 100.f) Require(spread > intensity_spread * 3.5 && spread < intensity_spread * 4.5,
                                    "Intensity 25 to 100 did not scale blur width by four");
      intensity_spread = spread;
    }
    // A following camera pans by 1/8 screen per frame while the foreground
    // subject stays still (or drifts subpixel). Object-only must not invent a
    // reverse-camera trail, including TileMax/NeighborMax coverage and gathers.
    parameters.components = WITCHER_MOTION_OBJECT;
    parameters.angle = 360.f;
    scratch_data[1] = {float(WIDTH), float(HEIGHT), 1.f / WIDTH, 1.f / HEIGHT};
    scratch_data[2] = {1, 0, 0, 0};
    scratch_data[3] = {0, 1, 0, 0};
    scratch_data[4] = {0, 0, 1, 0};
    scratch_data[5] = {.25f, 0, 0, 1};
    context->UpdateSubresource(scratch.Get(), 0, nullptr, scratch_data.data(), 0, 0);
    for (float drift : {0.f, .25f}) {
      for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x) {
        bool subject = x >= 96 && x < 160;
        scene[y * WIDTH + x] = {float((x + y) % 2) * 4, float(x % 3), float(y % 5), .7f};
        motion[y * WIDTH + x] = {subject ? drift / WIDTH : .125f, 0, 0, 0};
        depth[y * WIDTH + x] = {subject ? 1.f : .1f, 0, 0, 0};
      }
      run();
      Require(result == scene, "Camera-followed subject or static background blurred in object-only mode");
      std::cout << "object_only_follow_camera_drift=" << drift << " exact_sharp_frame=1\n";
    }
    independent_intensity = true;
    parameters.components = WITCHER_MOTION_CAMERA | WITCHER_MOTION_OBJECT;
    // Changing object exposure must not change static scenery during a pan.
    // Conversely, with a static camera, changing camera exposure must not
    // change a moving object's blur. Exercise all three filtering passes.
    std::fill(scene.begin(), scene.end(), Pixel{0, 0, 0, 1});
    for (unsigned y = 0; y < HEIGHT; ++y) scene[y * WIDTH + WIDTH / 2] = {8, 4, 2, 1};
    std::fill(depth.begin(), depth.end(), Pixel{.1f, 0, 0, 0});
    std::fill(motion.begin(), motion.end(), Pixel{.125f, 0, 0, 0});
    parameters.angle = 90.f;
    parameters.object_angle = 0.f;
    run();
    auto camera_reference = result;
    parameters.object_angle = 360.f;
    run();
    Require(result == camera_reference, "Object intensity changed camera-only scenery");
    parameters.angle = 360.f;
    run();
    Require(result != camera_reference, "Camera intensity did not affect camera blur");
    scratch_data[5][0] = 0.f;
    context->UpdateSubresource(scratch.Get(), 0, nullptr, scratch_data.data(), 0, 0);
    parameters.angle = 0.f;
    parameters.object_angle = 90.f;
    run();
    auto object_reference = result;
    parameters.angle = 360.f;
    run();
    Require(result == object_reference, "Camera intensity changed object-only motion");
    parameters.object_angle = 360.f;
    run();
    Require(result != object_reference, "Object intensity did not affect object blur");
    // Unequal source exposures must not resurrect blur on a perfectly tracked
    // subject: its actual screen displacement remains zero.
    scratch_data[5][0] = .25f;
    context->UpdateSubresource(scratch.Get(), 0, nullptr, scratch_data.data(), 0, 0);
    std::fill(motion.begin(), motion.end(), Pixel{0, 0, 0, 0});
    for (auto angles : {std::array<float, 2>{90.f, 360.f}, std::array<float, 2>{360.f, 90.f}}) {
      parameters.angle = angles[0];
      parameters.object_angle = angles[1];
      run();
      Require(result == scene, "Unequal intensities blurred a camera-followed subject");
    }
    std::cout << "independent_camera_object_intensities=PASS\n";
    // Near-coherent motion crosses a large depth discontinuity. The optimized
    // trajectory shortcut may approximate weights within its one-percent bound,
    // but should remain visually close to the baseline feature-aware filter.
    parameters.angle = parameters.object_angle = 180.f;
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x) {
      scene[y * WIDTH + x] = {float((x / 4 + y / 4) % 2), float(y % 2), .5f, 1};
      motion[y * WIDTH + x] = {64.f / WIDTH * (1.f + .002f * (float(x) / WIDTH - .5f)), 0, 0, 0};
      depth[y * WIDTH + x] = {x < WIDTH / 2 ? 1.f : .1f, 0, 0, 0};
    }
    run();
    if (argc == 11) {
      double rmse = std::sqrt(total_squared_relative_error / double(compared_channels));
      std::cout << "baseline_comparison_max_relative_error=" << maximum_relative_error << " rmse=" << rmse << '\n';
      Require(maximum_relative_error < .01f && rmse < .002f, "Optimized blur differs materially from the reference filter");
    }
    // Exercise the actual shader's tap budget at all UI tiers while emulating
    // longer frames and camera reversals. Intensity may lengthen the shutter
    // but must never increase work beyond the selected tier.
    if (argc == 8) {
      parameters.diagnostic = 2;
      std::fill(scene.begin(), scene.end(), Pixel{0, 0, 0, 1});
      for (unsigned samples : {16u, 32u, 64u, 128u}) {
        parameters.samples = samples;
        for (float displacement : {128.f, -128.f, 512.f, -512.f, 4096.f, -4096.f}) {
          std::fill(motion.begin(), motion.end(), Pixel{displacement / WIDTH, 0, 0, 0});
          for (float angle : {36.f, 180.f, 360.f}) {
            parameters.angle = parameters.object_angle = angle;
            run();
            for (const auto& pixel : result) Require(pixel[0] <= samples && pixel[0] >= 8.f, "Shader exceeded the quality budget");
            Require(std::abs(result[(HEIGHT / 2) * WIDTH + WIDTH / 2][1] - std::abs(displacement) * angle / 720.f) < .002f,
                    "Budget limit truncated the shutter trajectory");
          }
        }
      }
      parameters.diagnostic = 0;
      // At the lowest tier, even an extreme one-pixel emitter must keep its
      // mean energy and spatial extent. Individual noisy pixels are expected.
      parameters.samples = 16;
      std::fill(depth.begin(), depth.end(), Pixel{.1f, 0, 0, 0});
      for (unsigned y = 0; y < HEIGHT; ++y) scene[y * WIDTH + 384] = {8, 4, 2, 1};
      for (float displacement : {960.f, -960.f}) {
        std::fill(motion.begin(), motion.end(), Pixel{displacement / WIDTH, 0, 0, 0});
        parameters.angle = parameters.object_angle = 180.f;
        run();
        double energy = 0, moment = 0;
        float minimum = 8.f;
        for (unsigned x = 128; x <= 640; ++x) {
          double column = 0;
          for (unsigned y = 16; y < HEIGHT - 16; ++y) column += result[y * WIDTH + x][0];
          column /= HEIGHT - 32;
          energy += column;
          moment += column * std::pow(double(x) - 384, 2);
          if (x >= 204 && x <= 564) minimum = std::min(minimum, float(column));
        }
        std::cout << "low_quality_long_light_energy=" << energy << " spread=" << std::sqrt(moment / energy) << " minimum_mean=" << minimum << '\n';
        Require(energy > 6 && energy < 10 && minimum > .001f, "Low quality lost thin-light coverage or energy");
        Require(std::sqrt(moment / energy) > 110 && std::sqrt(moment / energy) < 166, "Low quality changed blur extent");
      }
    }
    std::cout << "cache_max_relative_error=" << cache_max_error << '\n';
    // Half-resolution reconstruction: odd dimensions, exact stationary/alpha,
    // constant HDR preservation, foreground rejection and thin emitter energy.
    test_half = true;
    parameters.diagnostic = 0;
    parameters.components = 3;
    parameters.angle = parameters.object_angle = 180.f;
    parameters.samples = 64;
    std::fill(motion.begin(), motion.end(), Pixel{});
    for (unsigned i = 0; i < scene.size(); ++i) scene[i] = {float(i % 7) - 1, float(i % 11), float(i % 17), float(i % 5) * .2f};
    run(); Require(result == scene, "Half resolution changed stationary detail");
    for (float displacement : {1.f, 16.f, 128.f, -128.f, 960.f}) {
      std::fill(motion.begin(), motion.end(), Pixel{displacement / WIDTH, 0, 0, 0});
      std::fill(scene.begin(), scene.end(), Pixel{-.25f, 3.f, 16.f, .7f});
      run();
      for (const auto& pixel : result) for (unsigned c = 0; c < 3; ++c)
        Require(std::abs(pixel[c] - scene[0][c]) < 3e-5f, "Half resolution changed constant HDR");
    }
    std::fill(scene.begin(), scene.end(), Pixel{0, 0, 0, 1});
    for (unsigned y = 0; y < HEIGHT; ++y) scene[y * WIDTH + 384] = {8, 4, 2, 1};
    std::fill(motion.begin(), motion.end(), Pixel{128.f / WIDTH, 0, 0, 0});
    run();
    double half_energy = 0;
    for (unsigned y = 16; y < HEIGHT - 16; ++y) for (unsigned x = 128; x <= 640; ++x) half_energy += result[y * WIDTH + x][0] / (HEIGHT - 32);
    std::cout << "half_resolution_light_energy=" << half_energy << '\n';
    Require(half_energy > 6 && half_energy < 10, "Half resolution lost emitter energy");
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = 0; x < WIDTH; ++x) {
      bool foreground = x > WIDTH / 3 && x < WIDTH * 2 / 3;
      scene[y * WIDTH + x] = foreground ? Pixel{0, float(y % 2), 0, .7f} : Pixel{4, 0, 0, 1};
      motion[y * WIDTH + x] = foreground ? Pixel{} : Pixel{128.f / WIDTH, 0, 0, 0};
      depth[y * WIDTH + x] = {foreground ? 1.f : .1f, 0, 0, 0};
    }
    run();
    for (unsigned y = 0; y < HEIGHT; ++y) for (unsigned x = WIDTH / 3 + 1; x < WIDTH * 2 / 3; ++x)
      Require(result[y * WIDTH + x] == scene[y * WIDTH + x], "Half resolution contaminated stationary foreground");
    // Pooled menu textures can exceed the active dispatch/allocation. Guard
    // memory remains mapped, making illegal writes observable even on WARP.
    capacity_test = true;
    for (bool half : {false, true}) {
      test_half = half;
      for (const auto& extent : std::array<std::array<unsigned, 4>, 5>{{
               {WIDTH / 2, HEIGHT / 2, (WIDTH + 1) / 2, (HEIGHT + 1) / 2},
               {WIDTH - 1, HEIGHT + 1, (WIDTH + 1) / 2, (HEIGHT + 1) / 2},
               {WIDTH, HEIGHT, WIDTH / 4, HEIGHT / 4},
               {0, 0, 0, 0},
               {WIDTH + 7, HEIGHT + 7, (WIDTH + 1) / 2, (HEIGHT + 1) / 2}}}) {
        parameters.cache_width = extent[0]; parameters.cache_height = extent[1];
        parameters.half_width = half ? extent[2] : 0; parameters.half_height = half ? extent[3] : 0;
        run();
      }
    }
    std::cout << "PASS " << cases << " cached/full/half GPU cases (including 10 menu-capacity cases), " << cases * WIDTH * HEIGHT << " output pixels\n";
  } catch (const std::exception& error) {
    std::cerr << "FAIL " << error.what() << '\n';
    return 1;
  }
}
