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
$package = Join-Path $PSScriptRoot 'package'
if (!(Test-Path -LiteralPath (Join-Path $game 'Undisputed.exe'))) { throw 'Undisputed.exe is missing from the selected directory.' }
if (Get-Process -Name Undisputed -ErrorAction SilentlyContinue) { throw 'Close Undisputed before installing.' }
if (!(Test-Path -LiteralPath $package)) { throw 'The built package directory is missing.' }
$nativeAssembly = Join-Path $game 'GameAssembly.dll'
if (!(Test-Path -LiteralPath $nativeAssembly -PathType Leaf) -or
    (Get-FileHash -LiteralPath $nativeAssembly -Algorithm SHA256).Hash -ne
        'EE5FBE3B2D389697EF9A958CDB31FE51434C0FD3F193B577CB3A81133B32E3F3') {
    throw 'This release supports a specific Steam build of Undisputed. The GameAssembly.dll version in this folder does not match.'
}
$roots = @(Get-ChildItem -LiteralPath $package -Force)
foreach ($entry in $roots) {
    if (Test-Path -LiteralPath (Join-Path $game $entry.Name)) {
        throw "Existing file or folder would be overwritten: $($entry.Name). Nothing has been copied."
    }
}
$manifestPath = Join-Path $game 'UndisputedVR.install.json'
if (Test-Path -LiteralPath $manifestPath) { throw 'An installation manifest already exists.' }
$copied = [Collections.Generic.List[string]]::new()
try {
    foreach ($entry in $roots) {
        $destination = Join-Path $game $entry.Name
        Copy-Item -LiteralPath $entry.FullName -Destination $destination -Recurse
        $copied.Add($entry.Name)
    }
    $manifest = [ordered]@{
        Version = '0.1.0-experimental'
        GameDirectory = $game
        InstalledAt = (Get-Date).ToString('o')
        RootEntries = $copied.ToArray()
        OriginalFilesReplaced = @()
        PluginHash = (Get-FileHash -LiteralPath (Join-Path $game 'BepInEx\plugins\UndisputedVR\UndisputedVR.dll') -Algorithm SHA256).Hash
    }
    $manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    Write-Output 'Prototype installed. Existing game and ReShade files were not overwritten.'
    Write-Output 'Use Start-VR.cmd for the prototype; the normal game launch leaves the loader disabled.'
} catch {
    Write-Error "Installation did not complete. Successfully added roots: $($copied -join ', '). Error: $_"
    throw
}

Set-Content -LiteralPath (Join-Path $PSScriptRoot "GameDirectory.txt") -Value $game -Encoding UTF8
