param(
    [string]$GameDirectory,
    [switch]$DiagnosticsOnly,
    [switch]$RenderOnly,
    [switch]$SingleThreadedRenderer = $true,
    [switch]$ExperimentalSinglePass,
    [switch]$SinglePassDiagnostics,
    [switch]$TestImplicitHandoff = $true,
    [switch]$GpuAudit,
    [switch]$KeepNativeCameraRender,
    [switch]$NoWait
)
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
$game = [IO.Path]::GetFullPath($GameDirectory)
$exe = Join-Path $game 'Undisputed.exe'
if (!(Test-Path -LiteralPath $exe)) { throw "Undisputed.exe not found in $game" }
if (!(Test-Path -LiteralPath (Join-Path $game 'UndisputedVR.install.json'))) { throw 'Install the prototype with Install.ps1 first.' }
if (Get-Process -Name Undisputed -ErrorAction SilentlyContinue) { throw 'Close the existing Undisputed session first.' }
$nativeAssembly = Join-Path $game 'GameAssembly.dll'
if (!(Test-Path -LiteralPath $nativeAssembly -PathType Leaf) -or
    (Get-FileHash -LiteralPath $nativeAssembly -Algorithm SHA256).Hash -ne
        'EE5FBE3B2D389697EF9A958CDB31FE51434C0FD3F193B577CB3A81133B32E3F3') {
    throw 'This release supports a specific Steam build of Undisputed. The GameAssembly.dll version in this folder does not match.'
}
$manifestPath = Join-Path $game 'UndisputedVR.install.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$installedDll = Join-Path $game 'BepInEx\plugins\UndisputedVR\UndisputedVR.dll'
$candidateDll = Join-Path $PSScriptRoot 'package\BepInEx\plugins\UndisputedVR\UndisputedVR.dll'
if (Test-Path -LiteralPath $candidateDll) {
    $installedHash = (Get-FileHash -LiteralPath $installedDll -Algorithm SHA256).Hash
    $candidateHash = (Get-FileHash -LiteralPath $candidateDll -Algorithm SHA256).Hash
    if ($installedHash -ne $candidateHash) {
        if ($installedHash -ne $manifest.PluginHash) { throw 'The installed prototype DLL was changed outside this package; preserve it before updating.' }
        Copy-Item -LiteralPath $candidateDll -Destination $installedDll -Force
        $manifest.PluginHash = $candidateHash
        $manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    }
}
$info = [Diagnostics.ProcessStartInfo]::new()
$info.FileName = $exe
$info.WorkingDirectory = $game
$info.Arguments = '-force-d3d11 --doorstop-enabled true'
if ($SingleThreadedRenderer) { $info.Arguments += ' -force-gfx-direct' }
$info.UseShellExecute = $false
$info.EnvironmentVariables['UNDISPUTED_VR_SINGLE_PASS'] = $(if ($SinglePassDiagnostics) { 'probe' } elseif ($ExperimentalSinglePass) { '1' } else { '0' })
$info.EnvironmentVariables['UNDISPUTED_VR_IMPLICIT_HANDOFF'] = $(if ($TestImplicitHandoff) { '1' } else { '0' })
$info.EnvironmentVariables['UNDISPUTED_VR_GPU_AUDIT'] = $(if ($GpuAudit) { '1' } else { '0' })
$info.EnvironmentVariables['UNDISPUTED_VR_KEEP_NATIVE_CAMERA'] = $(if ($KeepNativeCameraRender) { '1' } else { '0' })
if ($TestImplicitHandoff) { Write-Host 'VR pacing: explicit PostPresentHandoff omitted. Use -TestImplicitHandoff:$false for the original path.' }
$info.EnvironmentVariables['UNDISPUTED_VR_DIAGNOSTICS'] = $(if ($DiagnosticsOnly) { '1' } else { '0' })
$info.EnvironmentVariables['UNDISPUTED_VR_NO_SUBMIT'] = $(if ($RenderOnly) { '1' } else { '0' })
$process = [Diagnostics.Process]::Start($info)
Write-Output "Undisputed launched (PID $($process.Id)). Log: $game\BepInEx\LogOutput.log"
if (!$NoWait) { $process.WaitForExit() }

