# Build Launchy with Qt 4.8.7 (MinGW 4.8.2) and collect a runnable copy in dist/.
#
# Toolchain layout (override with parameters):
#   Qt     C:\Qt\4.8.7   qt-opensource-windows-x86-mingw482-4.8.7.exe
#   MinGW  C:\mingw32    i686-4.8.2-release-posix-dwarf-rt_v3-rev3
#   Boost  C:\boost      headers only (referenced by the .pro files)
param(
    [string]$QtDir = 'C:\Qt\4.8.7',
    [string]$MinGWDir = 'C:\mingw32',
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$dist = Join-Path $root 'dist'

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

# Collect the release build and its runtime into dist/
New-Item -ItemType Directory -Force "$dist\plugins\icons", "$dist\imageformats", "$dist\tr" | Out-Null
Copy-Item "$root\release\Launchy.exe" $dist
Copy-Item "$root\release\plugins\*.dll" "$dist\plugins"
foreach ($plugin in 'runner', 'weby', 'calcy', 'verby', 'controly') {
    Copy-Item "$root\plugins\$plugin\*.png" "$dist\plugins\icons"
}
foreach ($dll in 'QtCore4', 'QtGui4', 'QtNetwork4') {
    Copy-Item "$QtDir\bin\$dll.dll" $dist
}
foreach ($dll in 'libgcc_s_dw2-1', 'libstdc++-6', 'libwinpthread-1') {
    Copy-Item "$MinGWDir\bin\$dll.dll" $dist
}
foreach ($fmt in 'qico4', 'qjpeg4', 'qgif4') {
    Copy-Item "$QtDir\plugins\imageformats\$fmt.dll" "$dist\imageformats"
}
Copy-Item "$root\translations\*.qm" "$dist\tr"
Copy-Item "$root\skins", "$root\win\Utilities" $dist -Recurse -Force

Write-Host "Build collected in $dist"
