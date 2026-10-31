/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <array>
#include <cassert>
#include <iostream>
#include <fstream>
#include <limits>
#include "../darker_nights.hpp"

int main(int argc,char** argv) {
  using namespace witcher3classic::lighting;
  using namespace player_fill;
  std::array<float,0xb400/4> environment{};
  constexpr unsigned first_curves[]={0x3b00,0x3960,0x3ca0,0x3e40};
  std::array<float,36> original{};
  for(unsigned i=0;i<original.size();++i)original[i]=float(i+1)*.375f;
  const std::array<float,8> endpoints={6.809904f,7.86273f,7.86273f,.2f,3.931306f,3.342363f,2.093967f,.2f};
  const auto* env=reinterpret_cast<const uint8_t*>(environment.data());
  size_t cases=0;
  for(unsigned group=0;group<4;++group)for(unsigned second=0;second<2;++second)
    for(float strength:{0.f,.2f,.5f,1.f})for(float cutscene:{0.f,.35f,1.f})
      for(float gain:{0.f,.01f,.227423f,1.f,2.f})for(bool unify:{false,true})for(bool enabled:{false,true}) {
        const auto* evaluated=env+0xb0e8+group*0x60+second*0x30;
        const auto* curves=env+first_curves[group]+second*0xd0;
        assert(Source(env+0x10,evaluated,curves)==static_cast<CameraSource>(group+1));
        auto output=original;auto colors=endpoints;
        environment[0x404c/4]=gain;
        ApplyCameraLight(output.data(),env+0x10,evaluated,curves,group==0?colors.data():nullptr,
            {enabled,unify,strength,cutscene});
        const float scale=enabled?(group==1?strength:cutscene)*(unify?gain:1.f):1.f;
        for(unsigned i=0;i<output.size();++i)
          assert(output[i]==(group!=0&&i>=12&&i<=14?original[i]*scale:original[i]));
        for(unsigned i=0;i<colors.size();++i)
          assert(colors[i]==(group==0&&i%4<3?endpoints[i]*scale:endpoints[i]));
        // The scene compute pass chooses an RGB endpoint using exposure.
        // Both choices follow the cutscene slider; alpha and HDR stay intact.
        if(group==0)for(unsigned first:{0u,4u})for(unsigned c=0;c<3;++c)
          assert(colors[first+c]==endpoints[first+c]*scale);
        std::array<float,269*4> common{};common[71*4]=gain;
        const auto original_common=common;
        ApplyCommon(common.data(),{enabled,unify,strength,cutscene});
        for(size_t i=0;i<common.size();++i)assert(common[i]==(i==71*4&&enabled&&unify?1.f:original_common[i]));
        ++cases;
      }
  // Reject mismatched input identities and unexpected auxiliary-output shapes,
  // even if a light has the same RGB/radius/flags as an actual camera light.
  for(unsigned group=0;group<4;++group)for(unsigned second=0;second<2;++second) {
    const auto* evaluated=env+0xb0e8+group*0x60+second*0x30;
    const auto* curves=env+first_curves[group]+second*0xd0;
    for(unsigned mismatch=0;mismatch<3;++mismatch) {
      auto output=original;auto colors=endpoints;
      ApplyCameraLight(output.data(),env+0x10,evaluated+(mismatch==0?4:0),curves+(mismatch==1?4:0),
          (group==0) != (mismatch==2)?colors.data():nullptr,{true,false,0.f,0.f});
      assert(output==original&&colors==endpoints);
    }
  }
  ApplyCameraLight(nullptr,env+0x10,env+0xb0e8,env+0x3b00,nullptr,{true,true,0.f,0.f});
  // Fresh native outputs, all seven ABI arguments, failed-build passthrough,
  // independent strengths and no accumulated scaling across repeated frames.
  static bool succeeds=true;
  build_camera_light=[](void* output,const void* matrix,const void* evaluated,const void* curves,
      const void* override_color,float blend,void* colors) {
    assert(output&&matrix&&evaluated&&curves&&override_color==reinterpret_cast<void*>(0x100000002ull)&&blend==.375f);
    if(!succeeds)return false;
    std::fill_n(static_cast<float*>(output),36,8.f);
    if(colors)std::fill_n(static_cast<float*>(colors),8,16.f);
    return true;
  };
  player_control=1;player_strength=.2f;cutscene_strength=.5f;player_unify=1;
  environment[0x404c/4]=.25f;Update(true);
  for(unsigned frame=0;frame<100;++frame)for(unsigned group=0;group<4;++group) {
    std::array<float,36> output{};std::array<float,8> colors{};
    assert(CameraLightHook(output.data(),env+0x10,env+0xb0e8+group*0x60,env+first_curves[group],
        reinterpret_cast<void*>(0x100000002ull),.375f,group==0?colors.data():nullptr));
    assert(output[12]==(group==0?8.f:8.f*(group==1?.2f:.5f)*.25f));
    if(group==0)for(unsigned i=0;i<8;++i)assert(colors[i]==(i%4<3?2.f:16.f));
  }
  succeeds=false;auto failed=original;auto failed_colors=endpoints;
  assert(!CameraLightHook(failed.data(),env+0x10,env+0xb0e8,env+0x3b00,
      reinterpret_cast<void*>(0x100000002ull),.375f,failed_colors.data()));
  assert(failed==original&&failed_colors==endpoints);
  // Matching works during daytime and with Darker Nights disabled.
  witcher3classic::night::Controls night_controls{};
  std::array<uint8_t,4304> mapped{};
  {
    witcher3classic::night::CommonUpload upload(night_controls,0.5f);
    auto* redirected=upload.Redirect(mapped.data(),123);
    std::memset(redirected,0,4304);
    const float gain=.25f;std::memcpy(static_cast<uint8_t*>(redirected)+0x470,&gain,4);
    upload.Publish();
  }
  float gain;std::memcpy(&gain,mapped.data()+0x470,4);assert(gain==1.f);
  Update(false);assert(!GetControls().enabled);
  player_control=0;player_strength=cutscene_strength=-0.f;Update(true);assert(!GetControls().enabled&&!std::signbit(GetControls().strength)&&!std::signbit(GetControls().cutscene_strength));
  player_control=1;
  for(float value:{-1.f,0.f,.2f,1.f,2.f,std::numeric_limits<float>::quiet_NaN()}) {
    player_strength=cutscene_strength=value;Update(true);
    const float expected=std::isfinite(value)?std::clamp(value,0.f,1.f):1.f;
    assert(GetControls().strength==expected&&GetControls().cutscene_strength==expected);
  }
  if(argc>1) {
    std::ifstream file(argv[1],std::ios::binary);assert(file);
    const std::vector<uint8_t> data{std::istreambuf_iterator<char>(file),{}};
    const auto* dos=reinterpret_cast<const IMAGE_DOS_HEADER*>(data.data());
    const auto* pe=reinterpret_cast<const IMAGE_NT_HEADERS64*>(data.data()+dos->e_lfanew);
    std::vector<uint8_t> image(pe->OptionalHeader.SizeOfImage);
    std::copy_n(data.begin(),pe->OptionalHeader.SizeOfHeaders,image.begin());
    const auto* section=IMAGE_FIRST_SECTION(pe);
    for(unsigned i=0;i<pe->FileHeader.NumberOfSections;++i)
      std::copy_n(data.begin()+section[i].PointerToRawData,section[i].SizeOfRawData,image.begin()+section[i].VirtualAddress);
    assert(witcher3classic::night::ValidateImage(image.data()));
    assert(Validate(image.data()));
    for(unsigned offset:{0xc3c510u,0xc39d02u,0xc39d1au,0xc39d3au,0xc39d93u,0xc39da8u,
        0xc39e00u,0xc39e5au,0xc3c7a6u,0xc3c65bu,0xcdc901u,0xcdc912u}) {
      image[offset]^=1;assert(!Validate(image.data()));image[offset]^=1;
    }
    std::cout<<"PASS actual 1.32 camera-source/RGB/endpoint/common contracts and changed-code rejection\n";
  }
  std::cout<<"PASS "<<cases<<" independent gameplay/cutscene/receiver cases, both scene endpoints, RGB-only HDR, source rejection, fresh outputs, failed builds, seven-argument ABI and daytime CommonUpload\n";
}
