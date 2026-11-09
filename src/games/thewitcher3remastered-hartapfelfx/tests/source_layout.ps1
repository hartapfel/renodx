# Regression checks for decompiled scalar constant aliases and active receiver hooks.
$ErrorActionPreference='Stop'
$modRoot=Split-Path -Parent $PSScriptRoot
$aliases=0
foreach($file in Get-ChildItem -LiteralPath $modRoot -Filter '0x*.hlsl' -File) {
  $source=Get-Content -Raw -LiteralPath $file.FullName
  foreach($match in [regex]::Matches($source,'(?m)^#define cb12_(\d+)([xyzw])\s+([^\r\n]+)')) {
    $row=[int]::Parse($match.Groups[1].Value)
    $component=$match.Groups[2].Value
    if($match.Groups[3].Value -notmatch ('(?:receiver_frame|cb12_raw)\['+$row+'\]\.'+$component+'\b')) { throw "Incorrect constant alias in $($file.Name): $($match.Value)" }
    ++$aliases
  }
  if($source.Contains('#define FOG_RECEIVER_FRAME') -and -not $source.Contains('ReceiverFrameMatches()')) {
    throw "Receiver hook missing in $($file.Name)"
  }
}
if($aliases -lt 100) {throw 'Receiver alias coverage unexpectedly small.'}
$addon=Get-Content -Raw -LiteralPath (Join-Path $modRoot 'addon.cpp')
$registered=$addon+(Get-Content -Raw -LiteralPath (Join-Path $modRoot 'night/settings.hpp'))
$keys=@{}
foreach($match in [regex]::Matches($registered,'\.key\s*=\s*"([^"]+)"')) { $keys[$match.Groups[1].Value]=$true }
foreach($match in [regex]::Matches($addon,'UpdateSetting\("([^"]+)"')) {
  if(-not $keys.ContainsKey($match.Groups[1].Value)) {throw "Preset Off references an unregistered setting: $($match.Groups[1].Value)"}
}
Write-Host "PASS: $aliases decimal native-frame aliases, receiver hooks and registered Preset Off keys"
