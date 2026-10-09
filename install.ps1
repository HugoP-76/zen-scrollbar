param(
  [string]$Color = "#7e62b8",
  [string]$Track = "#80808033",
  [ValidateSet("auto","thin","none")][string]$Width = "auto",
  [string]$ProfilePath
)
$ErrorActionPreference = "Stop"

if (-not $ProfilePath) {
  $ProfilePath = (Get-ChildItem "$env:APPDATA\zen\Profiles" -Directory |
    Where-Object Name -like "*Default (release)*" | Select-Object -First 1).FullName
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