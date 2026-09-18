/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <windows.h>
#include <utility>
namespace acbrotherhood::dlaa {
// Own only handles created/duplicated by us. Legacy GPU shared handles are
// driver identifiers and must NOT be closed with CloseHandle.
struct Handle {
  HANDLE value = nullptr;
  Handle() = default;
  explicit Handle(HANDLE handle) : value(handle) {}
  Handle(const Handle&) = delete;
  Handle& operator=(const Handle&) = delete;
  Handle(Handle&& other) noexcept : value(std::exchange(other.value, nullptr)) {}
  Handle& operator=(Handle&& other) noexcept {
    if (this != &other) { if (value) CloseHandle(value); value = std::exchange(other.value, nullptr); }
    return *this;
  }
  ~Handle() { if (value) CloseHandle(value); }
};
}  // namespace acbrotherhood::dlaa
