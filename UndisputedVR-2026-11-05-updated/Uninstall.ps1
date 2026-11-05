param([string]$GameDirectory)
$ErrorActionPreference = 'Stop'
if (!$GameDirectory) {
    $selection = Join-Path $PSScriptRoot 'GameDirectory.txt'
    if (Test-Path -LiteralPath $selection) {
        $GameDirectory = (Get-Content -LiteralPath $selection -Raw).Trim()
    }
    if (!$GameDirectory) {
        $GameDirectory = (Read-Host 'Paste the folder containing Undisputed.exe').Trim().Trim('"')
    }
    if (!$GameDirectory) { throw 'No game folder was provided.' }
}
$game = [IO.Path]::GetFullPath($GameDirectory).TrimEnd('\')
$manifestPath = Join-Path $game 'UndisputedVR.install.json'
if (!(Test-Path -LiteralPath $manifestPath)) { throw 'No prototype installation manifest was found.' }
if (Get-Process -Name Undisputed -ErrorAction SilentlyContinue) { throw 'Close Undisputed before uninstalling.' }
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($manifest.GameDirectory -ne $game) { throw 'Manifest game directory does not match.' }
$otherPlugins = @(Get-ChildItem -LiteralPath (Join-Path $game 'BepInEx\plugins') -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne 'UndisputedVR' })
if ($otherPlugins.Count -gt 0) { throw 'Other BepInEx plugins are present. Preserve those separately before removing this loader.' }
$archive = Join-Path (Join-Path $PSScriptRoot 'uninstalled') (Get-Date -Format 'yyyyMMdd-HHmmss')
$archive = [IO.Path]::GetFullPath($archive)
if (!$archive.StartsWith([IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Invalid archive destination.'
}
$targets = foreach ($name in @($manifest.RootEntries) + 'UndisputedVR.install.json') {
    if ([IO.Path]::IsPathRooted($name) -or $name -match '[\\/]' -or $name -in '.', '..') { throw 'Invalid manifest entry.' }
    $resolved = [IO.Path]::GetFullPath((Join-Path $game $name))
    if (!$resolved.StartsWith($game + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Target is outside the game directory.' }
    $resolved
}
New-Item -ItemType Directory -Path $archive -Force | Out-Null
foreach ($target in $targets) {
    if (Test-Path -LiteralPath $target) { Move-Item -LiteralPath $target -Destination $archive }
}
Write-Output "Prototype files removed from the game and preserved at $archive"

