Param(
    [Switch]$Help = $(if (Test-Path variable:Help) { $Help }),
    [Switch]$Quiet = $(if (Test-Path variable:Quiet) { $Quiet }),
    [Switch]$Verbose = $(if (Test-Path variable:Verbose) { $Verbose }),
    [ValidateSet('x86', 'x64')]
    [String]$BuildArch = $(if (Test-Path variable:BuildArch) { "${BuildArch}" } else { ('x86', 'x64')[[System.Environment]::Is64BitOperatingSystem] })
)

##############################################################################
# Windows dependency management function
##############################################################################
#
# This script file can be included in build scripts for Windows or run
# directly
#
##############################################################################

$ErrorActionPreference = "Stop"

Function Install-obs-deps {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Version
    )

    Write-Status "Setup for pre-built Windows OBS dependencies v${Version}"
    Ensure-Directory $DepsBuildDir

    $ArchSuffix = $BuildArch

    if (!(Test-Path "${DepsBuildDir}/windows-deps-${Version}-${ArchSuffix}")) {

        Write-Step "Download..."
        curl.exe -Lf "https://github.com/obsproject/obs-deps/releases/download/${Version}/windows-deps-${Version}-${ArchSuffix}.zip" -o "windows-deps-${Version}-${ArchSuffix}.zip" $(if ($Quiet.isPresent) { "-s" })

        Write-Step "Unpack..."

        Expand-Archive -Path "windows-deps-${Version}-${ArchSuffix}.zip" -DestinationPath "${DepsBuildDir}/windows-deps-${Version}-${ArchSuffix}" -Force
    } else {
        Write-Step "Found existing pre-built dependencies..."
    }
}

function Install-Dependencies {
    Param(
        [String]$BuildArch = $(if (Test-Path variable:BuildArch) { "${BuildArch}" })
    )

    Install-Windows-Dependencies

    $BuildDependencies = @(
        @('obs-deps', $WindowsDepsVersion)
    )

    Foreach($Dependency in ${BuildDependencies}) {
        $DependencyName = $Dependency[0]
        $DependencyVersion = $Dependency[1]

        $FunctionName = "Install-${DependencyName}"
        Invoke-Expression "${FunctionName} -Version ${DependencyVersion}"
    }

    Ensure-Directory ${CheckoutDir}
}

function Install-Dependencies-Standalone {
    $ProductName = "OBS-Studio"
    $CheckoutDir = Resolve-Path -Path "$PSScriptRoot\..\.."
    $DepsBuildDir = "${CheckoutDir}/../obs-build-dependencies"
    $ObsBuildDir = "${CheckoutDir}/../obs-studio"

    . ${CheckoutDir}/CI/include/build_support_windows.ps1

    Write-Status "Setup of OBS build dependencies"
    Install-Dependencies
}

function Print-Usage {
    $Lines = @(
        "Usage: ${_ScriptName}",
        "-Help                    : Print this help",
        "-Quiet                   : Suppress most build process output",
        "-Verbose                 : Enable more verbose build process output",
        "-Choco                   : Enable automatic dependency installation via Chocolatey - Default: off"
        "-BuildArch               : Build architecture to use (x86 or x64) - Default: local architecture"
    )

    $Lines | Write-Host
}

if(!(Test-Path variable:_RunObsBuildScript)) {
    $_ScriptName = "$($MyInvocation.MyCommand.Name)"
    if($Help.isPresent) {
        Print-Usage
        exit 0
    }

    Install-Dependencies-Standalone
}
