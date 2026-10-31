English | [简体中文](README.zh-CN.md)

# Launchy 2.6 Beta 2, rebuilt with Qt 4.8.7 and MinGW

[Launchy](https://www.launchy.net) is a keystroke launcher for Windows: press
Alt+Space, type part of a program, file or bookmark name, and press Enter.

This repository is the official Launchy 2.6 Beta 2 source (SourceForge SVN
r671, 2010-11-10) with a few additions, built with Qt 4.8.7 and MinGW 4.8.2.
It is Windows only.

The unmodified official source is tagged
[`official-2.6-beta2-r671`](https://github.com/halfmoonvic/launchy/tree/official-2.6-beta2-r671).
The original author's documentation is in [docs/original](docs/original).

## Changes from the official 2.6 Beta 2

Runner commands accept two new optional settings, also editable in the Runner
plugin options:

```ini
cmds\N\icon=C:\\path\\to\\app.ico     ; .ico or .png file
cmds\N\icon=C:\\path\\to\\app.dll,3   ; icon 3 inside an exe or dll
cmds\N\show=hidden                     ; normal (default), hidden or minimized
```

`show=hidden` runs a `.cmd` or `.bat` without flashing a console window.
If a command's icon file is missing, the program's own icon is used, then the
Runner icon, rather than a folder icon.

Also:

- Icons display correctly under Qt 4.8, at the system icon size for the
  display scaling (40 pixels at 125%)
- Suggestion list rows fit both the name and the path
- Black Glass Large skin: Black Glass at 1.5x size
- The Google Calculator (gcalc) plugin, which no longer works, is removed
- The Linux, Mac and Visual Studio 2005 build files are removed

## Installing

Download `Launchy-<version>-win32.zip` from
[Releases](https://github.com/halfmoonvic/launchy/releases), unzip it anywhere,
for example `%LOCALAPPDATA%\Programs\Launchy`, and run `Launchy.exe`. No
installer is needed. Press Alt+Space to show it.

Settings are kept in `%APPDATA%\Launchy\launchy.ini`. Launchy runs in portable
mode, with its settings next to `Launchy.exe`, whenever there is a
`launchy.ini` in the same folder.

## Building

See [BUILD.txt](BUILD.txt). In short, with Qt 4.8.7, MinGW 4.8.2 and the Boost
headers installed:

```powershell
powershell -File build-mingw.ps1            # build into dist\
powershell -File build-mingw.ps1 -Package   # also write package\Launchy-<version>-win32.zip
```

## License

Launchy is free software under the GNU General Public License version 2, see
[LICENSE.txt](LICENSE.txt). Launchy was written by Josh Karlin and Simon
Capewell. The release zip includes the Qt 4.8.7 libraries (LGPL 2.1) and the
MinGW-w64 GCC runtime, with their licenses in its `licenses` folder.
