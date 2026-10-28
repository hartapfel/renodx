MOTION BLUR - REMASTERED
Standalone ReShade addon for The Witcher 3 Remastered (DX12, x64)

INSTALL
Use ReShade with full addon support. With the game closed, extract the ZIP
into the game root. The addon must sit beside bin/x64_dx12/witcher3.exe.
Do not keep duplicate .addon64 copies. ReShade itself is not included.
Launch the game yourself and open the Motion Blur - Remastered tab.

CONTROLS
Mode: Enhanced uses the Classic optical motion blur filter and automatically
activates the required native passes. Native follows the game's saved setting.
If automatic activation is unavailable, enable Motion Blur in the game settings.
Motion Blur: Camera + Object / Object Only / Off.
Object Only follows visible movement and keeps camera-followed subjects sharp.
Strength: 0 is sharp; 50 is a 1/60-second exposure; 100 is 1/30 second.
The two half-resolution gathers and adaptive sample counts match Classic.
Settings save automatically. Reset All Settings restores the new defaults.
Previous independent shutter/sample controls are replaced by Classic controls.

COMPATIBILITY
Works independently of HDR and tone mapping. No DevKit is required.
Use compatible Release builds when combining HDR, Darker Nights and Motion Blur.
Do not combine with historical HDR addons that already replace motion blur.
Missing native inputs or exhausted scratch capacity keep native rendering.
Remastered's native motion/depth grid still limits silhouette accuracy.

VERIFY
Compare Native/Enhanced while panning, then Camera + Object/Object Only/Off.
Try strength 0/50/100, moving NPCs, camera-followed Geralt and bright edges.
Repeatedly open/close inventory and map, load saves and change resolution.
GPU scratch uses completion fences and a fixed memory budget; gameplay keeps
an in-flight working set, while excess completed allocations are released.

UNINSTALL
Close the game and remove renodx-thewitcher3remastered-motionblur.addon64.

CREDITS
Game adaptation by Hartapfel; RenoDX framework by ShortFuse.
Optical filter copyright 2026 LoreanXavier / Hartapfel.
See LICENSE.txt and LICENSE-optics.txt for MIT license notices.
