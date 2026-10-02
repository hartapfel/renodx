/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Standalone D3D11 WARP validation of the same three HLSL passes, compiled as
// cs_5_0 for the software adapter. Shipping shaders are strictly built as cs_6_6.
#define NOMINMAX
#include <d3d11.h>
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

using Microsoft::WRL::ComPtr;
using Pixel = std::array<float, 4>;
constexpr unsigned WIDTH = 257, HEIGHT = 97;
constexpr unsigned TILES_X = (WIDTH + 31) / 32, TILES_Y = (HEIGHT + 31) / 32;
struct Parameters {
  unsigned width = WIDTH, height = HEIGHT, tiles_x = TILES_X, tiles_y = TILES_Y;
  float motion_x = 1, motion_y = 1, velocity_x = WIDTH * .25f, velocity_y = HEIGHT * .25f;
  float depth_x = 1, depth_y = 1, depth_a = 1, depth_b = 0;
  float radius = 32;
  unsigned samples = 64, diagnostic = 0;
  float seconds = 1.f / 60;
};
static_assert(sizeof(Parameters) == 64);
void Check(HRESULT result) { if (FAILED(result)) throw std::runtime_error("D3D failure " + std::to_string(result)); }
void Require(bool pass, const char* reason) { if (!pass) throw std::runtime_error(reason); }

int main(int argc, char** argv) {
  try {
    Require(argc == 4, "Expected TileMax, NeighborMax and reconstruction binaries");
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> context;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context));
    ComPtr<ID3D11ComputeShader> shaders[3];
    for (unsigned i = 0; i < 3; ++i) {
      std::ifstream stream(argv[i + 1], std::ios::binary);
      std::vector<char> bytes((std::istreambuf_iterator<char>(stream)), {});
      Check(device->CreateComputeShader(bytes.data(), bytes.size(), nullptr, &shaders[i]));
    }
    ComPtr<ID3D11Buffer> buffer;
    D3D11_BUFFER_DESC buffer_desc = {sizeof(Parameters), D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER, 0, 0, 0};
    Check(device->CreateBuffer(&buffer_desc, nullptr, &buffer));
    context->CSSetConstantBuffers(0, 1, buffer.GetAddressOf());
    // Exercise the shipping shader's native c21/c22 projection-buffer layout.
    ComPtr<ID3D11Buffer> projection_buffer;
    std::array<float, 92> projection = {};
    projection[84] = projection[88] = 1.f;
    D3D11_BUFFER_DESC projection_desc = {sizeof(projection), D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER, 0, 0, 0};
    D3D11_SUBRESOURCE_DATA projection_data = {projection.data(), 0, 0};
    Check(device->CreateBuffer(&projection_desc, &projection_data, &projection_buffer));
    context->CSSetConstantBuffers(1, 1, projection_buffer.GetAddressOf());
    ComPtr<ID3D11SamplerState> sampler;
    D3D11_SAMPLER_DESC sampler_desc = {};
    sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sampler_desc.AddressU = sampler_desc.AddressV = sampler_desc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler_desc.MaxLOD = D3D11_FLOAT32_MAX;
    Check(device->CreateSamplerState(&sampler_desc, &sampler));
    context->CSSetSamplers(0, 1, sampler.GetAddressOf());
    ComPtr<ID3D11Texture2D> textures[6], readback;
    ComPtr<ID3D11ShaderResourceView> srvs[6];
    ComPtr<ID3D11UnorderedAccessView> uavs[6];
    for (unsigned i = 0; i < 6; ++i) {
      D3D11_TEXTURE2D_DESC desc = {i == 3 || i == 4 ? TILES_X : WIDTH, i == 3 || i == 4 ? TILES_Y : HEIGHT,
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
    auto run = [&]() {
      ID3D11ShaderResourceView* null_srvs[4] = {};
      ID3D11UnorderedAccessView* null_uav = nullptr;
      context->CSSetShaderResources(0, 4, null_srvs);
      context->CSSetUnorderedAccessViews(0, 1, &null_uav, nullptr);
      context->UpdateSubresource(buffer.Get(), 0, nullptr, &parameters, 0, 0);
      context->UpdateSubresource(textures[0].Get(), 0, nullptr, scene.data(), WIDTH * sizeof(Pixel), 0);
      context->UpdateSubresource(textures[1].Get(), 0, nullptr, motion.data(), WIDTH * sizeof(Pixel), 0);
      context->UpdateSubresource(textures[2].Get(), 0, nullptr, depth.data(), WIDTH * sizeof(Pixel), 0);
      for (unsigned pass = 0; pass < 3; ++pass) {
        ID3D11ShaderResourceView* inputs[] = {srvs[0].Get(), srvs[1].Get(), srvs[2].Get(), pass == 0 ? nullptr : srvs[pass + 2].Get()};
        context->CSSetShaderResources(0, 4, inputs);
        context->CSSetUnorderedAccessViews(0, 1, uavs[pass + 3].GetAddressOf(), nullptr);
        context->CSSetShader(shaders[pass].Get(), nullptr, 0);
        context->Dispatch(pass == 0 ? TILES_X : pass == 1 ? (TILES_X + 7) / 8 : (WIDTH + 7) / 8,
                         pass == 0 ? TILES_Y : pass == 1 ? (TILES_Y + 7) / 8 : (HEIGHT + 7) / 8, 1);
        context->CSSetShaderResources(0, 4, null_srvs);
        context->CSSetUnorderedAccessViews(0, 1, &null_uav, nullptr);
      }
      context->CopyResource(readback.Get(), textures[5].Get());
      D3D11_MAPPED_SUBRESOURCE mapped;
      Check(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &mapped));
      for (unsigned y = 0; y < HEIGHT; ++y)
        std::copy_n(reinterpret_cast<const Pixel*>(static_cast<const char*>(mapped.pData) + y * mapped.RowPitch), WIDTH, result.data() + y * WIDTH);
      context->Unmap(readback.Get(), 0);
      ++cases;
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

    // At the maximum radius, a one-pixel HDR light must not leave sampling
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
    std::cout << "PASS " << cases << " three-pass GPU cases, " << cases * WIDTH * HEIGHT << " output pixels\n";
  } catch (const std::exception& error) {
    std::cerr << "FAIL " << error.what() << '\n';
    return 1;
  }
}
