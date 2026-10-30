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
  using Bank=std::array<uint32_t,3323*4>;
  Bank native{};
  std::array<float,0xb400/4> environment{};
  for(size_t i=0;i<native.size();++i)native[i]=std::bit_cast<uint32_t>(.01f*float(i%791));
  native[57*4]=256;
  for(uint32_t i=0;i<256;++i)native[(61+9*i)*4+3]=i%2?0x1800u:0x80001800u|(i%4==0?1u:0u);
  size_t cases=0;
  for(uint32_t count:{0u,1u,2u,31u,256u,257u})for(float strength:{0.f,.2f,.5f,1.f})
    for(float gain:{0.f,.01f,.227423f,1.f,2.f})for(bool unify:{false,true})for(bool enabled:{false,true}) {
      auto bank=native;bank[57*4]=count;
      const auto before=bank;
      environment[0x404c/4]=gain;
      ApplyLights(bank.data(),environment.data(),{enabled,unify,strength});
      for(uint32_t word=0;word<bank.size();++word) {
        bool rgb=false;
        if(count<=256 && word>=61*4) {
          const uint32_t local=word-61*4,light=local/36,component=local%36;
          rgb=light<count && component<3 && (before[(61+9*light)*4+3]&0x80000000u);
        }
        const float scale=enabled && rgb?strength*(unify?gain:1.f):1.f;
        assert(bank[word]==(scale==1.f?before[word]:std::bit_cast<uint32_t>(std::bit_cast<float>(before[word])*scale)));
      }
      std::array<float,269*4> common{};common[71*4]=gain;
      const auto original_common=common;
      ApplyCommon(common.data(),{enabled,unify,strength});
      for(size_t i=0;i<common.size();++i)assert(common[i]==(i==71*4&&enabled&&unify?1.f:original_common[i]));
      // Native world/character branches agree after normalization, including
      // zero native world fill. No division or threshold near zero is needed.
      if(enabled&&unify)assert(strength*gain*common[71*4]==strength*gain);
      ++cases;
    }
  // The original builder runs every time: unchanged/zero/reordered/new records
  // never inherit an earlier multiplication. Verify all ten native ABI args.
  std::array<uint8_t,0x120> renderer{};
  Bank built{};
  void* bank_pointer=built.data();std::memcpy(renderer.data()+0xf8,&bank_pointer,sizeof(bank_pointer));
  build_local_constants=[](void* renderer,const void* environment,uint64_t view,uint64_t camera,
      uint64_t bounds,uint32_t count,const void* lights,uint8_t shadow,uint8_t enabled,float blend) {
    assert(renderer && environment &&view==0x100000002ull &&camera==0x200000003ull &&bounds==0x300000004ull);
    assert(count==256 &&lights==reinterpret_cast<void*>(0x500000006ull)&&shadow==0x7f&&enabled==1&&blend==.375f);
    void* constants;std::memcpy(&constants,static_cast<uint8_t*>(renderer)+0xf8,sizeof(constants));
    auto* words=static_cast<uint32_t*>(constants);
    std::fill_n(words,3323*4,0u);words[57*4]=1;words[61*4]=std::bit_cast<uint32_t>(16.f);
    words[61*4+1]=std::bit_cast<uint32_t>(8.f);words[61*4+2]=std::bit_cast<uint32_t>(4.f);words[61*4+3]=0x80001800u;
  };
  environment[0x404c/4]=.25f;player_control=1;player_strength=.2f;player_unify=1;Update(true);
  for(int frame=0;frame<100;++frame) {
    LocalConstantsHook(renderer.data(),environment.data(),0x100000002ull,0x200000003ull,0x300000004ull,
        256,reinterpret_cast<void*>(0x500000006ull),0x7f,1,.375f);
    assert(std::bit_cast<float>(built[61*4])==.8f);
    assert(built[61*4+3]==0x80001800u);
  }
  // Normalization must run even with Darker Nights disabled or during daytime.
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
  player_strength=std::numeric_limits<float>::quiet_NaN();Update(true);assert(GetControls().strength==1.f);
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
    for(unsigned offset:{0xc39be0u,0xc39c02u,0xc3a24cu,0xcdc901u,0xcdc912u}) {
      image[offset]^=1;assert(!Validate(image.data()));image[offset]^=1;
    }
    std::cout<<"PASS actual 1.32 local-light/common native contracts and changed-code rejection\n";
  }
  std::cout<<"PASS "<<cases<<" light-table/receiver cases, tags/shadow variants, HDR RGB-only changes, stale count guards, fresh native rebuilds, ten-argument ABI and daytime CommonUpload\n";
}
