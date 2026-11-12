# Shareable game-root package

Double-click **package-release.cmd** in this folder, like the Classic mod's
packaging launcher. It packages the current Release addon and the complete
light-alignment companion into one ZIP under `build/Release/packages`, with a
matching `.zip.sha256` file. It does not install files or start/close the game.

Players extract the ZIP into the **main game installation folder**, alongside
`bin` and `content`. The package uses these paths, without an extra parent folder:

```text
bin/x64_dx12/renodx-thewitcher3remastered-hartapfelfx.addon64
bin/x64_dx12/renodx-hartapfelfx-licenses/...
Mods/mod0000_HartapfelLightAlignment/...
HartapfelFX-README.txt
HartapfelFX-manifest.json
```

The archive contains no ReShade loader, HDR addon, DevKit, personal profiles,
ReShade.ini, logs or base-game graphics settings. It uses the player's existing
Remastered/addon-capable ReShade setup. See `PACKAGE-INSTALL.txt`, included in
the ZIP, for installation, update and removal instructions.

## Author commands

From the repository root:

```powershell
# Package the existing Release build.
./src/games/thewitcher3remastered-hartapfelfx/package-release.ps1

# Rebuild with the established Clang Release workflow, then package.
# Close Witcher 3 first: its loaded addon is locked by Windows.
./src/games/thewitcher3remastered-hartapfelfx/package-release.ps1 -Build -Version 1.0

# Use another output directory or validated alignment seed archive.
./src/games/thewitcher3remastered-hartapfelfx/package-release.ps1 -Version 1.0 -OutputDirectory build/Release/share -AlignmentPackage '<standalone alignment ZIP>'
```

Without `-Version`, the archive uses the Release DLL's build timestamp. Repeating
the same version replaces that ZIP after validating the newly assembled archive.
The `.cmd` forwards the same arguments and pauses so errors remain visible.
Packaging alone can run while the game is open; `-Build` requires it closed.

The author needs Python 3 and the existing built Release DLL. Players need no
Python, compiler, NativeBridge or REDkit. The wrapper rejects missing/empty or
older-than-mod-source Release builds. The assembler validates the x64 addon PE
exports without loading its code.

## Alignment content

The default seed is the validated standalone archive:

```text
build/Release/packages/HartapfelFX-Light-Alignment-1.1.3/HartapfelFX-Light-Alignment-Remastered-1.1.3.zip
```

Only its pinned, accepted bathhouse cooked files are reused. Each packaging run
regenerates the scripts, 337-fixture map, metadata and documentation from current
alignment source using the existing standalone packager. Future catalog changes
therefore do not require maintaining a second map. The old separate World test
companion is consolidated into the single alignment mod folder.

On a clean checkout without this ignored build artifact, generate the standalone
seed using [the alignment build instructions](lighting/alignment/README.md), or
pass its path with `-AlignmentPackage`. Missing alignment content stops packaging;
it is never silently left out. The current cooked files are pinned by SHA-256;
a changed native patch needs an explicitly reviewed pin update.

## Validation

The packager verifies the decompressed bytes of every ZIP member, writes a
payload manifest and archive checksum, and permits only relative game-root
paths. It never copies an installed game folder or personal configuration.
The manifest records the current source commit and whether the mod source has
uncommitted changes; it does not infer a clean source state from the DLL name.
To check an archive and exercise invalid-addon/altered-native-patch rejection:

```powershell
python src/games/thewitcher3remastered-hartapfelfx/tests/package_release.py '<combined ZIP>' '<standalone alignment ZIP>'
```

The regression also extracts to an empty temporary game root, checks all fixture
identities and current runtime scripts, verifies licenses/hashes, and confirms
that no `dxgi.dll`, profile, log, PDB or DevKit is shipped. ZIP ordering and member
timestamps are fixed for reproducible assembly from identical input bytes.
