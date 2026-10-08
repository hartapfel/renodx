Darker Nights - Remastered
Standalone lighting and moon controls for The Witcher 3 Remastered (DX12)

REQUIREMENT
Install ReShade with full add-on support for bin\x64_dx12\witcher3.exe first.
Download: https://reshade.me/
An existing full-add-on ReShade installation can be used. No effect packages
or HDR addon are required.

INSTALL
Close the game. Extract this ZIP into the game installation folder containing
bin, content and Mods. Merge the bin folder when prompted.
The addon must end up here:
  <game folder>\bin\x64_dx12\tw3-darkernights-remastered.addon64

The Witcher 3 Mod Manager currently installs script mods and
configuration files, but does not install native addon DLLs from archives.
Install this ZIP manually using the steps above. Putting it in Mods will not
load the addon. No Script Merger step is needed.

If upgrading an older Darker Nights release, remove its old standalone addon
(renodx-darkernights-remastered.addon64 or
renodx-thewitcher3remastered-darkernights.addon64) so only one copy is loaded. Remove
Artificial Player Lights. An HDR addon without these lighting hooks can remain;
use only one implementation if your HDR addon already includes Darker Nights.

SETTINGS
Restart the game, open ReShade's Add-ons tab, and expand Darker Nights - Remastered.
Night Lighting: enable the night adjustments and choose Soft Nights or Dark Nights.
Night Schedule: select the fade-in, full darkness, fade-out and end times.
Night Illumination: adjust skylight, direct light and water lighting.
Night Atmosphere: adjust fog, haze, sky, clouds and rain brightness.
Night Colour Grading: adjust brightness/contrast, tint/saturation and vegetation tones.
Camera Lighting: control gameplay and cutscene camera fill independently.
Sky Appearance: set Moon Size (1-500%; 100% is the original size).

Light intensity: 0 = off, 50 = native, 100 = double. Times use a 24-hour clock
and can cross midnight. Camera lighting and moon size ignore the night schedule.
The selected preset and settings are saved between sessions. Preset Off restores
native values. Torches and ordinary local lights retain their original behaviour.
Skylight also controls the sky illumination and sky fill on water; reflections
of scene lights and refraction remain intact.

UNINSTALL
Close the game and remove bin\x64_dx12\tw3-darkernights-remastered.addon64.
Keep ReShade if another addon or preset uses it. This addon does not change saves.

CREDITS AND SUPPORT
Game addon: Hartapfel. RenoDX framework: ShortFuse.
RenoDX: https://github.com/clshortfuse/renodx
RenoDX Discord: https://discord.gg/Ce9bQHQrSV
HDR Den Discord: https://discord.gg/5WZXDpmbpP
Hartapfel: https://ko-fi.com/hartapfel
ShortFuse: https://ko-fi.com/shortfuse
