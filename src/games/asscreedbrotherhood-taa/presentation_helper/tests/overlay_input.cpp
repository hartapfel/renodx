#include "../overlay_input.hpp"
#include <cassert>
#include <iostream>
#include <vector>

struct Event { UINT message; WPARAM key; LPARAM detail; };
std::vector<Event> events;
LRESULT CALLBACK Record(HWND window, UINT message, WPARAM key, LPARAM detail) {
  if ((message >= WM_KEYFIRST && message <= WM_KEYLAST)
      || (message >= WM_MOUSEFIRST && message <= WM_MOUSELAST)
      || message == WM_SETFOCUS || message == WM_KILLFOCUS || message == WM_MOUSELEAVE)
    events.push_back({message, key, detail});
  return DefWindowProcW(window, message, key, detail);
}
int main() {
  WNDCLASSW wc{};
  wc.lpfnWndProc = DefWindowProcW;
  wc.hInstance = GetModuleHandleW(nullptr);
  wc.lpszClassName = L"BrotherhoodOverlayInputTest";
  assert(RegisterClassW(&wc));
  HWND parent = CreateWindowW(wc.lpszClassName, L"input test", WS_POPUP, 0, 0, 64, 64, nullptr, nullptr, wc.hInstance, nullptr);
  HWND window = CreateWindowW(wc.lpszClassName, L"output", WS_CHILD | WS_DISABLED, 0, 0, 64, 64, parent, nullptr, wc.hInstance, nullptr);
  assert(parent && window);
  const HWND focus = GetFocus();
  const HWND foreground = GetForegroundWindow();
  acbrotherhood::presentation::OverlayInput input(window);
  std::array<BYTE, 256> keys{};
  const POINT cursor{12, 24};
  input.Forward(true, keys, &cursor);
  assert(events.empty() && !input.focused);
  SetWindowLongPtrW(window, GWLP_WNDPROC, LONG_PTR(Record));
  keys[VK_INSERT] = 0x80;
  input.Forward(true, keys, &cursor);
  assert(events.size() == 1 && events[0].message == WM_SETFOCUS);
  events.clear();
  keys[VK_INSERT] = 0;
  input.Forward(true, keys, &cursor);
  assert(events.size() == 1 && events[0].message == WM_MOUSEMOVE); // Held on entry: no menu toggle.
  events.clear();
  keys[VK_INSERT] = 0x80;
  input.Forward(true, keys, nullptr);
  input.Forward(true, keys, nullptr);
  keys[VK_INSERT] = 0;
  input.Forward(true, keys, nullptr);
  assert(events.size() == 2 && events[0].message == WM_KEYDOWN && events[1].message == WM_KEYUP);
  assert(events[0].key == VK_INSERT && (events[1].detail & 0xc0000000u) == 0xc0000000u);
  events.clear();
  keys[VK_LBUTTON] = 0x80;
  input.Forward(true, keys, &cursor);
  keys[VK_LBUTTON] = 0;
  input.Forward(true, keys, &cursor);
  assert(events.size() == 4 && events[0].message == WM_LBUTTONDOWN && events[2].message == WM_LBUTTONUP);
  assert(events[0].detail == MAKELPARAM(12, 24));
  events.clear();
  input.Forward(false, {}, nullptr);
  input.Forward(false, {}, nullptr);
  assert(events.size() == 2 && events[0].message == WM_KILLFOCUS && events[1].message == WM_MOUSELEAVE);
  assert(GetFocus() == focus && GetForegroundWindow() == foreground);
  assert(!IsWindowEnabled(window));
  SetWindowLongPtrW(window, GWLP_WNDPROC, input.original_procedure);
  events.clear();
  input.Forward(true, keys, &cursor);
  assert(events.empty() && !input.focused);
  DestroyWindow(window);
  DestroyWindow(parent);
  std::cout << "PASS overlay subclass gating, press/release, held-key suppression, mouse coordinates, focus loss and unchanged native focus\n";
}
