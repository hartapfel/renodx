/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include "../temporal/object_history.hpp"
#include <cassert>
#include "../temporal/rigid_history.hpp"
#include "../temporal/swarm_history.hpp"

using namespace witcher3classic::temporal;
int main() {
  ObjectHistory history;
  WorldTransform first = {1, 0, 0, 2, 0, 1, 0, 3, 0, 0, 1, 4};
  WorldTransform moved = first;
  moved[3] += 10;
  std::array<BoneAllocation, 2> allocations = {{{100, 1000, 1, 32}, {200, 2000, 33, 64}}};
  history.Record(0, 100, first);
  history.Record(0, 200, moved);
  assert(!history.Previous(0, allocations[0]).valid);
  history.Commit(0, allocations);
  // Engine packing order changes; retain each allocation's own old palette.
  std::swap(allocations[0], allocations[1]);
  allocations[0].base = 1;
  allocations[1].base = 65;
  assert(history.Previous(1, allocations[0]).previous_base == 33);
  assert(history.Previous(1, allocations[1]).world == first);
  history.Record(1, 100, moved);
  history.Record(1, 100, moved);  // Several parts, identical world: valid.
  history.Commit(1, allocations);
  assert(history.Previous(2, allocations[1]).world == moved);
  assert(!history.Previous(2, allocations[0]).valid);  // Not observed.
  assert(!history.Previous(3, allocations[1]).valid);  // Frame gap.
  ++allocations[1].storage;
  assert(history.Previous(2, allocations[1]).valid);  // Rotating native pose storage.
  --allocations[1].storage;
  ++allocations[1].count;
  assert(!history.Previous(2, allocations[1]).valid);
  --allocations[1].count;
  history.Record(2, 100, first);
  history.Record(2, 100, moved);  // Shared allocation, different worlds.
  history.Commit(2, allocations);
  assert(!history.Previous(3, allocations[1]).valid);
  history.Record(3, 100, first);
  history.Commit(3, allocations);
  assert(history.Previous(4, allocations[1]).valid);
  history.Erase(100);  // Destructor, then reuse of the same native address.
  history.Record(4, 100, moved);
  assert(!history.Previous(4, allocations[1]).valid);
  history.Clear();
  history.Commit(20, allocations);
  assert(!history.Previous(21, allocations[0]).valid && history.Previous(21, allocations[0]).palette_valid);
  history.Erase(allocations[0].id);
  assert(!history.Previous(21, allocations[0]).palette_valid);
  SwarmHistory swarm;
  assert(!swarm.Record(0, 1, 10, 2, 0, first).valid);
  assert(!swarm.Record(0, 1, 10, 2, 1, moved).valid);
  // Visibility sorting reverses order; full native slots keep their own poses.
  assert(swarm.Record(1, 1, 10, 2, 1, first).world == moved);
  assert(swarm.Record(1, 1, 10, 2, 0, moved).world == first);
  assert(swarm.Record(1, 1, 10, 2, 0, moved).valid);
  assert(!swarm.Record(1, 1, 10, 2, 0, first).valid);  // Conflicting views.
  assert(!swarm.Record(3, 1, 10, 2, 0, moved).valid);  // Visibility gap.
  assert(!swarm.Record(4, 1, 10, 3, 0, moved).valid);  // Population changed.
  assert(!swarm.Record(5, 1, 20, 3, 0, moved).valid);  // Animation group changed.
  swarm.Erase(1);
  assert(!swarm.Record(6, 1, 20, 3, 0, moved).valid);  // Owner address reused.
  RigidHistory rigid;
  rigid.Record(0, 1, 10, first);
  rigid.Record(1, 1, 10, moved);
  assert(rigid.Previous(1, 1, 10, moved).valid && rigid.Previous(1, 1, 10, moved).world == first);
  rigid.Record(2, 1, 20, moved);
  assert(!rigid.Previous(2, 1, 20, moved).valid);  // Reused identity with a different mesh.
  rigid.Record(4, 1, 20, first);
  assert(!rigid.Previous(4, 1, 20, first).valid);  // Frame gap.
  rigid.Record(5, 1, 20, moved);
  rigid.Record(5, 1, 20, first);
  assert(!rigid.Previous(5, 1, 20, moved).valid && !rigid.Previous(5, 1, 20, first).valid);
  assert(!rigid.Record(6, 1, 20, first).valid);  // Previous frame was ambiguous.
  rigid.Clear();
  rigid.Record(0, 1, 10, first);
  rigid.Record(0, 2, 20, moved);
  rigid.Record(1, 1, 10, moved);
  rigid.Record(1, 2, 20, moved);  // A stationary object overlaps the moving object.
  assert(rigid.Previous(1, 1, 10, moved).valid && rigid.Previous(1, 1, 10, moved).world == first);
  assert(rigid.Previous(1, 2, 20, moved).valid && rigid.Previous(1, 2, 20, moved).world == moved);
  // A newly visible part at that same world does not poison either history.
  assert(!rigid.Record(1, 3, 30, moved).valid);
  assert(rigid.Previous(1, 1, 10, moved).valid && rigid.Previous(1, 2, 20, moved).valid);
  rigid.Erase(2);
  assert(!rigid.Previous(1, 2, 20, moved).valid && rigid.Previous(1, 1, 10, moved).valid);
}
