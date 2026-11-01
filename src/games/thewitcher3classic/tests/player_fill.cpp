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
    assert(scene_fill::Validate(image.data()));
    for(const auto& contract:scene_fill::contracts) {
      image[contract.rva]^=1;assert(!scene_fill::Validate(image.data()));image[contract.rva]^=1;
    }
#ifdef CLASSIC_SCENE_DETOUR_TEST
    // Prove Detours can relocate each real native entry before deploying it.
    // Never execute the private EXE copy or modify the running game's image.
    auto* executable=static_cast<uint8_t*>(VirtualAlloc(nullptr,image.size(),MEM_RESERVE|MEM_COMMIT,PAGE_EXECUTE_READWRITE));
    assert(executable);std::memcpy(executable,image.data(),image.size());
    std::array<void*,8> targets{};
    const std::array<void*,8> hooks{reinterpret_cast<void*>(&scene_fill::SpawnHook),
        reinterpret_cast<void*>(&scene_fill::CreateComponentHook),reinterpret_cast<void*>(&scene_fill::CreateProxyHook),
        reinterpret_cast<void*>(&scene_fill::DestroyComponentHook),reinterpret_cast<void*>(&scene_fill::DestroyProxyHook),
        reinterpret_cast<void*>(&scene_fill::BuildBankHook),reinterpret_cast<void*>(&scene_fill::BuildPointHook),
        reinterpret_cast<void*>(&scene_fill::BuildSpotHook)};
    for(unsigned i=0;i<8;++i)targets[i]=executable+scene_fill::contracts[i].rva;
    assert(DetourTransactionBegin()==NO_ERROR &&DetourUpdateThread(GetCurrentThread())==NO_ERROR);
    for(unsigned i=0;i<8;++i)assert(DetourAttach(&targets[i],hooks[i])==NO_ERROR);
    assert(DetourTransactionCommit()==NO_ERROR);
    assert(DetourTransactionBegin()==NO_ERROR &&DetourUpdateThread(GetCurrentThread())==NO_ERROR);
    for(unsigned i=0;i<8;++i)assert(DetourDetach(&targets[i],hooks[i])==NO_ERROR);
    assert(DetourTransactionCommit()==NO_ERROR &&scene_fill::Validate(executable));
    VirtualFree(executable,0,MEM_RELEASE);
    std::cout<<"PASS all eight actual native entry prologues attach/detach and restore exactly in a private executable copy\n";
#endif
    for(unsigned offset:{0xc3c510u,0xc39d02u,0xc39d1au,0xc39d3au,0xc39d93u,0xc39da8u,
        0xc39e00u,0xc39e5au,0xc3c7a6u,0xc3c65bu,0xcdc901u,0xcdc912u}) {
      image[offset]^=1;assert(!Validate(image.data()));image[offset]^=1;
    }
    std::cout<<"PASS actual 1.32 camera-source/RGB/endpoint/common contracts and changed-code rejection\n";
  }
  // Ownership, rather than matching RGB/flags/radius, distinguishes story
  // lights from placed lights. Exercise the actual producer/lifetime hooks.
  namespace sf=scene_fill;
  static std::array<uint32_t,40> component{},proxy0{},proxy1{},world_proxy{};
  static void* result_proxy=proxy0.data();
  static bool create_during_spawn=true;
  proxy0[4]=3;proxy1[4]=4;world_proxy[4]=4;
  sf::create_component=[](void*,const void*,const void*)->void* {return component.data();};
  sf::create_proxy=[](void*,const void* const*)->void* {return result_proxy;};
  sf::destroy_proxy=sf::destroy_component=[](void*){};
  sf::spawn=[](void*,const void*)->void* {
    const void* descriptor[]={sf::CreateComponentHook(nullptr,nullptr,nullptr)};
    if(create_during_spawn)sf::CreateProxyHook(nullptr,descriptor);
    return component.data();
  };
  sf::SpawnHook(nullptr,nullptr);assert(sf::spawn_depth==0);
  assert(sf::sources->components.contains(component.data())&&sf::sources->proxies.contains(proxy0.data()));
  const void* description[]={component.data()};result_proxy=proxy1.data();
  sf::CreateProxyHook(nullptr,description); // rebuilt outside the spawn call
  assert(sf::sources->proxies.contains(proxy0.data())&&sf::sources->proxies.contains(proxy1.data()));
  sf::DestroyProxyHook(proxy0.data());assert(!sf::sources->proxies.contains(proxy0.data()));
  sf::DestroyComponentHook(component.data());assert(sf::sources->components.empty());
  assert(sf::sources->proxies.contains(proxy1.data())); // queued frame still alive
  sf::DestroyProxyHook(proxy1.data());assert(sf::sources->proxies.empty());
  result_proxy=proxy0.data();sf::CreateProxyHook(nullptr,description);
  assert(sf::sources->proxies.empty()); // reused component/proxy addresses, new world owner
  create_during_spawn=false;sf::SpawnHook(nullptr,nullptr);
  sf::CreateProxyHook(nullptr,description);assert(sf::sources->proxies.contains(proxy0.data()));
  for(bool active:{false,true})for(bool match:{false,true})for(float cutscene:{0.f,.2f,1.f})
    for(float gameplay:{0.f,1.f})for(float gain:{0.f,.25f,1.f,2.f}) {
      environment[0x404c/4]=gain;
      auto record=original;uint32_t flags=0x1801;std::memcpy(record.data()+15,&flags,4);
      const auto native=record;
      sf::Apply(record.data(),world_proxy.data(),env,{active,match,gameplay,cutscene});assert(record==native);
      sf::Apply(record.data(),proxy0.data(),env,{active,match,gameplay,cutscene});
      for(unsigned i=0;i<record.size();++i) {
        if(active &&i>=12 &&i<15)assert(record[i]==native[i]*cutscene*(match?gain:1.f));
        else if(active &&match &&i==15)assert(std::bit_cast<uint32_t>(record[i])==(flags|0x1800u));
        else assert(record[i]==native[i]);
      }
  }
  sf::DestroyComponentHook(component.data());sf::DestroyProxyHook(proxy0.data());
  assert(sf::sources->components.empty()&&sf::sources->proxies.empty());
  // Exercise the ten-argument bank ABI and nested scope restoration. Point and
  // spot put the shadow switch and proxy in different argument positions.
  sf::build_point=[](void* output,const void* position,const void* color,bool shadows,const void* proxy) {
    assert(position==component.data()&&color==world_proxy.data()&&shadows&&proxy==proxy0.data());
    std::fill_n(static_cast<float*>(output),36,16.f);
  };
  sf::build_spot=[](void* output,const void* position,const void* color,const void* proxy,bool shadows) {
    assert(position==component.data()&&color==world_proxy.data()&&proxy==proxy1.data()&&!shadows);
    std::fill_n(static_cast<float*>(output),36,8.f);
  };
  static const void* active_environment=env;
  sf::build_bank=[](void* renderer,const void* e,const void* camera,const void* evaluated,const void* curves,
      uint32_t count,const void* const* lights,bool shadows,bool secondary,float blend) {
    assert(renderer==component.data()&&e==active_environment&&camera==proxy0.data()&&evaluated==proxy1.data()
        &&curves==world_proxy.data()&&count==2&&lights&&shadows&&!secondary&&blend==.375f);
    std::array<float,36> point{},spot{};
    sf::BuildPointHook(point.data(),component.data(),world_proxy.data(),true,proxy0.data());
    sf::BuildSpotHook(spot.data(),component.data(),world_proxy.data(),proxy1.data(),false);
    assert(point[12]==2.f&&spot[12]==1.f);
  };
  {std::unique_lock lock(sf::sources->mutex);sf::sources->proxies.insert(proxy0.data());sf::sources->proxies.insert(proxy1.data());}
  player_control=1;player_unify=1;cutscene_strength=.5f;environment[0x404c/4]=.25f;Update(true);
  sf::environment=world_proxy.data();sf::controls={false,false,.1f,.2f};
  sf::BuildBankHook(component.data(),env,proxy0.data(),proxy1.data(),world_proxy.data(),2,description,true,false,.375f);
  assert(sf::environment==world_proxy.data()&&!sf::controls.enabled&&sf::controls.strength==.1f);
  sf::DestroyProxyHook(proxy0.data());sf::DestroyProxyHook(proxy1.data());
  std::cout<<"PASS native bank/point/spot ABI and nested environment/control scope restoration\n";
  std::cout<<"PASS scene light provenance, disabled creation, proxy rebuild/queued-frame lifetime, address reuse, independent cutscene strength, matched receivers and native world-light bypass\n";
  std::cout<<"PASS "<<cases<<" independent gameplay/cutscene/receiver cases, both scene endpoints, RGB-only HDR, source rejection, fresh outputs, failed builds, seven-argument ABI and daytime CommonUpload\n";
}
