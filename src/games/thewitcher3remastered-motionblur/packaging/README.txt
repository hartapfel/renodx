MOTION BLUR - REMASTERED
Standalone ReShade addon for The Witcher 3 Remastered (DirectX 12, x64)

INSTALL
Use a ReShade installation with full addon support.
Extract this ZIP into the game directory so the addon sits beside
bin/x64_dx12/witcher3.exe. Restart the game after installing.
The installed file is renodx-thewitcher3remastered-motionblur.addon64.
When updating, close the game and replace that file; do not keep another copy
under a different .addon64 filename. ReShade itself is not included in this ZIP.

Open ReShade and select the "Motion Blur - Remastered" tab.
Enhanced activates motion blur automatically, even when the game setting is Off.
Native follows the game's own Motion Blur On/Off setting. Your saved game
preference is preserved. On an unsupported executable, the menu will ask you
to enable the game setting manually.

CONTROLS
Mode: Enhanced activates custom blur; Native follows the game setting.
Camera Motion Blur: blur from camera movement and rotation.
Object Motion Blur: blur from moving/animated objects. In object-only mode,
trails follow visible screen movement, keeping camera-followed subjects sharp.
Both default to On. For object-only blur, turn Camera Motion Blur Off and leave
Object Motion Blur On. Both Off removes Enhanced blur. These toggles only apply
in Enhanced mode; Native keeps the game's original behavior.
Camera Intensity / Object Intensity: adjust each source independently.
0 removes that source, 50 = 180-degree shutter, 100 = 360-degree shutter.
Camera and Object both default to 50; an existing shared Intensity value initializes both.
Each slider is available when its source is enabled in Enhanced mode.
Sample Quality: choose 16 Samples - Low, 32 Samples - Medium,
64 Samples - High, or 128 Samples - Ultra. Higher tiers trade GPU cost for
smoother blur. The selected count is a fixed maximum, even at high intensity.
Very long trails can look noisier at Low quality.
Half-Resolution Blur: optional faster reconstruction, On by default.
On can soften moving fine detail. Static surfaces and incompatible edges keep
full-resolution reconstruction; the speedup depends on the scene.
Frame-rate response comes from native per-frame motion.
Reset All Settings restores the defaults. Settings save automatically.

COMPATIBILITY
Independent of HDR and tone mapping. Can be used alone or alongside the current
RenoDX Witcher HDR and Darker Nights addons. No DevKit is required.
Do not load two copies of this addon, or combine it with an older HDR addon
that already contains the same enhanced motion blur implementation.
If the expected game inputs are unavailable, the native blur dispatch is kept.

VERIFY IN GAME
Pan the camera and compare Native / Enhanced. In Enhanced, compare each
intensity at 0 / 50 / 100 and inspect character silhouettes, bright lights and long
trails. Also check resolution changes and loading a saved game.
For object-only blur, pan across stationary buildings and watch moving NPCs:
camera sway should leave the buildings sharp while the moving objects blur.

UNINSTALL
Close the game and remove renodx-thewitcher3remastered-motionblur.addon64 from
bin/x64_dx12. Keep your other addons installed.

CREDITS & SUPPORT
Game mod by Hartapfel; RenoDX framework by ShortFuse.
Build date and time are shown in the mod's About & Build section.
Hartapfel: https://ko-fi.com/hartapfel
ShortFuse: https://ko-fi.com/shortfuse
RenoDX: https://github.com/clshortfuse/renodx
RenoDX Discord: https://discord.gg/Ce9bQHQrSV
