/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <windows.h>
#include <array>

namespace acbrotherhood::presentation {

// Overlays can subclass the helper's disabled child canvas, but Windows sends
// input to the game's parent HWND. Mirror foreground input to that subclass
// without activating the canvas or installing hooks in the game process.
struct OverlayInput {
  HWND window;
  LONG_PTR original_procedure;
  LONG_PTR procedure = 0;
  bool focused = false;
  std::array<BYTE, 256> previous{}, suppressed{};

  explicit OverlayInput(HWND output)
      : window(output), original_procedure(GetWindowLongPtrW(output, GWLP_WNDPROC)) {}

  // A snapshot boundary also lets the regression verify focus/held-key behavior
  // without injecting real keystrokes into the desktop.
  void Forward(bool active, const std::array<BYTE, 256>& keys, const POINT* cursor) {
    const LONG_PTR current = GetWindowLongPtrW(window, GWLP_WNDPROC);
    if (!current || current == original_procedure) {
      focused = false;
      procedure = current;
      return;
    }
    if (procedure != current) {
      focused = false;
      procedure = current;
    }
    if (!active) {
      if (focused) {
        SendMessageW(window, WM_KILLFOCUS, 0, 0);
        SendMessageW(window, WM_MOUSELEAVE, 0, 0);
      }
      focused = false;
      return;
    }
    if (!focused) {
      previous = suppressed = keys;  // Do not turn an Alt-Tab-held key into a shortcut.
      focused = true;
      SendMessageW(window, WM_SETFOCUS, 0, 0);
      return;
    }
    auto thread_keys = keys;
    SetKeyboardState(thread_keys.data());  // ImGui queries modifiers on this thread.
    const WPARAM buttons = ((keys[VK_LBUTTON] & 0x80) ? MK_LBUTTON : 0)
        | ((keys[VK_RBUTTON] & 0x80) ? MK_RBUTTON : 0)
        | ((keys[VK_MBUTTON] & 0x80) ? MK_MBUTTON : 0)
        | ((keys[VK_XBUTTON1] & 0x80) ? MK_XBUTTON1 : 0)
        | ((keys[VK_XBUTTON2] & 0x80) ? MK_XBUTTON2 : 0)
        | ((keys[VK_SHIFT] & 0x80) ? MK_SHIFT : 0)
        | ((keys[VK_CONTROL] & 0x80) ? MK_CONTROL : 0);
    for (UINT key = 1; key < keys.size(); ++key) {
      const bool down = (keys[key] & 0x80) != 0;
      if (suppressed[key] & 0x80) {
        if (!down) suppressed[key] = 0;
        continue;
      }
      if (down == ((previous[key] & 0x80) != 0)) continue;
      UINT message = down ? WM_KEYDOWN : WM_KEYUP;
      WPARAM value = key;
      const UINT scan = MapVirtualKeyW(key, MAPVK_VK_TO_VSC_EX);
      LPARAM detail = 1 | ((scan & 0xff) << 16) | ((scan & 0xff00) ? (1 << 24) : 0);
      if (!down) detail |= LPARAM(0xc0000000u);
      if (key == VK_LBUTTON || key == VK_RBUTTON || key == VK_MBUTTON || key == VK_XBUTTON1 || key == VK_XBUTTON2) {
        if (!cursor) continue;
        message = key == VK_LBUTTON ? (down ? WM_LBUTTONDOWN : WM_LBUTTONUP)
            : key == VK_RBUTTON ? (down ? WM_RBUTTONDOWN : WM_RBUTTONUP)
            : key == VK_MBUTTON ? (down ? WM_MBUTTONDOWN : WM_MBUTTONUP)
            : (down ? WM_XBUTTONDOWN : WM_XBUTTONUP);
        value = buttons;
        if (key == VK_XBUTTON1 || key == VK_XBUTTON2) value |= WPARAM(key == VK_XBUTTON1 ? XBUTTON1 : XBUTTON2) << 16;
        detail = MAKELPARAM(cursor->x, cursor->y);
      }
      SendMessageW(window, message, value, detail);
    }
    if (cursor) SendMessageW(window, WM_MOUSEMOVE, buttons, MAKELPARAM(cursor->x, cursor->y));
    previous = keys;
  }

  void Update(HWND game_window) {
    // No polling cost in the normal helper: only a third-party window subclass
    // activates this bridge. Never read keys belonging to other applications.
    if (GetWindowLongPtrW(window, GWLP_WNDPROC) == original_procedure) {
      focused = false;
      return;
    }
    if (GetAncestor(GetForegroundWindow(), GA_ROOT) != GetAncestor(game_window, GA_ROOT) || IsIconic(game_window)) {
      Forward(false, {}, nullptr);
      return;
    }
    std::array<BYTE, 256> keys{};
    GetKeyboardState(keys.data());
    for (UINT key = 1; key < keys.size(); ++key)
      keys[key] = (keys[key] & 1) | ((GetAsyncKeyState(key) & 0x8000) ? 0x80 : 0);
    POINT cursor{};
    const bool has_cursor = GetCursorPos(&cursor) && ScreenToClient(window, &cursor);
    Forward(true, keys, has_cursor ? &cursor : nullptr);
  }
};
}  // namespace acbrotherhood::presentation
