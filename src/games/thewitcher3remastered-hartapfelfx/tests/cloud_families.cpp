// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include <cassert>
#include <chrono>
#include <iostream>
#include <string_view>
#include <vector>
#include "../clouds/family_runtime.hpp"
namespace family=hartapfelfx::clouds::families;
namespace native=witcher::night::normalization;
uint32_t Intern(void*,const char* name) {
  for(uint32_t i=0;i<std::size(family::names);++i)
    if(std::string_view(name)==family::names[i].text)return 500+i;
  return 0;
}
uint32_t* Area(uint32_t* name,uint32_t value) { *name=100+value;return name; }
int main() {
  std::vector<unsigned char> game(0x17000),world(0x300),environment(0x92300),weather(0x350),systems(0x100),map(0x120);
  std::array<const void*,2> world_handle{},system_handle{},system_holder{};
  auto write=[](std::vector<unsigned char>* bytes,size_t offset,const auto& value) {
    std::memcpy(bytes->data()+offset,&value,sizeof(value));
  };
  const unsigned char* game_pointer=game.data();
  native::game_address=&game_pointer;
  native::supported=native::weather_supported=true;
  native::area_name=Area;native::intern_name=Intern;
  void* manager=reinterpret_cast<void*>(1);native::name_manager=&manager;
  world_handle[1]=world.data();write(&game,0xf0,world_handle.data());
  write(&world,0x228,environment.data());write(&environment,0x92270,weather.data());
  system_handle[1]=system_holder.data();system_holder[1]=map.data();
  write(&game,0xfdb8,systems.data());write(&game,0xfdc0,uint32_t(24));
  write(&systems,0xb8,system_handle.data());write(&map,0x110,uint32_t(101));
  family::Update(true);
  for(auto& name:family::names)assert(name.native!=0);
  for(const auto& row:family::weather) {
    write(&map,0x110,uint32_t(100+row.region));
    write(&weather,0x18,family::names[row.name].native);
    family::Update(true);
    assert(uint8_t(family::current.load())==row.profile);
    if(std::string_view(family::names[row.name].text)=="WT_Light_Clouds")
      assert(family::profiles[row.profile].low[3]==1.f);
    if(std::string_view(family::names[row.name].text)=="WT_Clear")
      assert(family::profiles[row.profile].low[2]==1.f &&family::profiles[row.profile].low[3]==0.f);
    if(std::string_view(family::names[row.name].text).find("Rain")!=std::string_view::npos)
      assert(family::profiles[row.profile].high[3]==1.f);
  }
  uint32_t storm=0,light=0;
  for(const auto& name:family::names) {
    if(std::string_view(name.text)=="WT_Rain_Storm")storm=name.native;
    if(std::string_view(name.text)=="WT_Light_Clouds")light=name.native;
  }
  write(&map,0x110,uint32_t(101));write(&weather,0x128,storm);write(&weather,0x238,light);
  write(&weather,0x348,120.f);write(&weather,0x34c,60.f);
  // envBlend is deliberately zero; cloud selection is independent of it.
  family::Update(true);
  const auto mixed=family::current.load();
  assert(uint8_t(mixed)==family::Find(1,storm) &&uint8_t(mixed>>8)==family::Find(1,light));
  assert(std::bit_cast<float>(uint32_t(mixed>>16))==.5f);
  write(&weather,0x128,uint32_t(0x7fffffff));family::Update(true);
  assert(uint8_t(family::current.load())==0);
  write(&weather,0x128,storm);
  const auto begin=std::chrono::steady_clock::now();
  for(uint32_t i=0;i<10000;++i)family::Update(true);
  const auto end=std::chrono::steady_clock::now();
  std::cout<<"Native family snapshot present-thread CPU mean us="
      <<std::chrono::duration<double,std::micro>(end-begin).count()/10000.<<" (mock native memory; not gameplay FPS)\n";
  game_pointer=nullptr;family::Update(true);assert(family::current.load()==0);
  family::current.store(123);family::Update(false);assert(family::current.load()==0);
  std::cout<<"PASS native family selector, regional variants, exact source/target blend, zero envBlend, unknown/missing world and disabled fallback\n";
}
