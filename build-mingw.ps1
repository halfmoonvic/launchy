# Build Launchy with Qt 4.8.7 (MinGW 4.8.2) and collect a runnable copy in dist/.
# With -Package, collect a fresh copy plus licenses into package/ and zip it
# instead; dist/ is left alone, so a copy running from there needn't be closed.
#
# Toolchain layout (override with parameters):
#   Qt     C:\Qt\4.8.7   qt-opensource-windows-x86-mingw482-4.8.7.exe
#   MinGW  C:\mingw32    i686-4.8.2-release-posix-dwarf-rt_v3-rev3
#   Boost  C:\boost      headers only (referenced by the .pro files)
param(
    [string]$QtDir = 'C:\Qt\4.8.7',
    [string]$MinGWDir = 'C:\mingw32',
    [switch]$Clean,
    [switch]$Package,
    # Defaults to 2.6b2-<commit>, the official 2.6 Beta 2 plus this repo's changes
    [string]$Version
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# Before PATH is narrowed to the toolchain below
if ($Package -and -not $Version) {
    $Version = '2.6b2-' + (git -C $root rev-parse --short HEAD)
}

$env:QTDIR = $QtDir
$env:QMAKESPEC = 'win32-g++'
$env:PATH = "$QtDir\bin;$MinGWDir\bin;$env:SystemRoot\System32;$env:SystemRoot"

Push-Location $root
try {
    if ($Clean -and (Test-Path Makefile)) { mingw32-make distclean }
    qmake -r Launchy.pro
    if ($LASTEXITCODE) { throw 'qmake failed' }
    mingw32-make -j $env:NUMBER_OF_PROCESSORS release
    if ($LASTEXITCODE) { throw 'build failed' }
    lrelease -silent src\src.pro
    if ($LASTEXITCODE) { throw 'lrelease failed' }
}
finally {
    Pop-Location
}

# Copy the release build and everything it needs at runtime into $dest
function Copy-Build([string]$dest) {
    New-Item -ItemType Directory -Force "$dest\plugins\icons", "$dest\imageformats", "$dest\tr" | Out-Null
    Copy-Item "$root\release\Launchy.exe" $dest
    Copy-Item "$root\release\plugins\*.dll" "$dest\plugins"
    foreach ($plugin in 'runner', 'weby', 'calcy', 'verby', 'controly') {
        Copy-Item "$root\plugins\$plugin\*.png" "$dest\plugins\icons"
    }
    foreach ($dll in 'QtCore4', 'QtGui4', 'QtNetwork4') {
        Copy-Item "$QtDir\bin\$dll.dll" $dest
    }
    foreach ($dll in 'libgcc_s_dw2-1', 'libstdc++-6', 'libwinpthread-1') {
        Copy-Item "$MinGWDir\bin\$dll.dll" $dest
    }
    # qmng4 plays skin animations such as spinner.mng
    foreach ($fmt in 'qico4', 'qjpeg4', 'qgif4', 'qmng4') {
        Copy-Item "$QtDir\plugins\imageformats\$fmt.dll" "$dest\imageformats"
    }
    Copy-Item "$root\translations\*.qm" "$dest\tr"
    Copy-Item "$root\skins", "$root\win\Utilities" $dest -Recurse -Force
}

if (-not $Package) {
    $dist = Join-Path $root 'dist'
    Copy-Build $dist
    Write-Host "Build collected in $dist"
    return
}

$packageDir = Join-Path $root 'package'
$stage = Join-Path $packageDir 'Launchy'
$zip = Join-Path $packageDir "Launchy-$Version-win32.zip"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
Copy-Build $stage

# Launchy is GPL; the Qt libraries are LGPL and the MinGW runtime DLLs carry
# their own notices, all of which go along with the binaries
Copy-Item "$root\LICENSE.txt" $stage
Copy-Item "$root\win\package-readme.txt" "$stage\README.txt"
New-Item -ItemType Directory -Force "$stage\licenses" | Out-Null
Copy-Item "$QtDir\LICENSE.LGPL" "$stage\licenses\Qt-LICENSE.LGPL.txt"
Copy-Item "$QtDir\LGPL_EXCEPTION.txt" "$stage\licenses\Qt-LGPL_EXCEPTION.txt"
Copy-Item "$MinGWDir\licenses\gcc\COPYING.RUNTIME" "$stage\licenses\GCC-RUNTIME-LIBRARY-EXCEPTION.txt"
Copy-Item "$MinGWDir\licenses\gcc\COPYING3" "$stage\licenses\GCC-COPYING3.txt"
Copy-Item "$MinGWDir\licenses\winpthreads\COPYING" "$stage\licenses\winpthreads-COPYING.txt"

if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path $stage -DestinationPath $zip
Write-Host "Package written to $zip"
