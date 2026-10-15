param(
  [string]$Color = "#7e62b8",
  [string]$Track = "#80808033",
  [ValidateSet("auto","thin","none")][string]$Width = "auto",
  [string]$ProfilePath
)
$ErrorActionPreference = "Stop"

# Profile in use, per profiles.ini: [Install*] Default=, else the [Profile*] with Default=1.
if (-not $ProfilePath) {
  $root = Join-Path $env:APPDATA "zen"
  $ini = Join-Path $root "profiles.ini"
  if (Test-Path $ini) {
    $sec = ""; $inst = $null; $paths = @{}; $def = $null
    foreach ($line in Get-Content $ini) {
      if ($line -match '^\[(.+)\]$') { $sec = $Matches[1]; continue }
      if ($line -notmatch '^([^=]+)=(.*)$') { continue }
      $k = $Matches[1]; $v = $Matches[2]
      if ($sec -like "Install*" -and $k -eq "Default" -and -not $inst) { $inst = $v }
      if ($sec -like "Profile*" -and $k -eq "Path") { $paths[$sec] = $v }
      if ($sec -like "Profile*" -and $k -eq "Default" -and $v -eq "1") { $def = $sec }
    }
    $p = if ($inst) { $inst } elseif ($def) { $paths[$def] }
    if ($p) {
      if (-not [IO.Path]::IsPathRooted($p)) { $p = Join-Path $root $p }
      if (Test-Path $p -PathType Container) { $ProfilePath = $p }
    }
  }
}
if (-not $ProfilePath) { throw "Profile not found. Use -ProfilePath (about:support > Profile Folder)." }
Write-Host "Profile: $ProfilePath"

$chrome = Join-Path $ProfilePath "chrome"
New-Item -ItemType Directory -Force $chrome | Out-Null
$css = Join-Path $chrome "userContent.css"
if (Test-Path $css) { Copy-Item $css "$css.bak" -Force }

@"
:root {
  --zsc-thumb: $Color;
  --zsc-track: $Track;
  --zsc-width: $Width;
}
* {
  scrollbar-color: var(--zsc-thumb) var(--zsc-track) !important;
  scrollbar-width: var(--zsc-width) !important;
}
"@ | Set-Content $css -Encoding ascii

$uj = Join-Path $ProfilePath "user.js"
if (-not (Test-Path $uj) -or -not (Select-String $uj -Pattern "legacyUserProfileCustomizations" -Quiet)) {
  Add-Content $uj 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
}
Write-Host "Done. Restart Zen completely."