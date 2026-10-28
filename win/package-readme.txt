Launchy 2.6 Beta 2, rebuilt with Qt 4.8.7 and MinGW
====================================================

This is the official Launchy 2.6 Beta 2 (SVN r671) with a few additions,
built from https://github.com/halfmoonvic/launchy


Running
-------
Unzip anywhere, for example %LOCALAPPDATA%\Programs\Launchy, and run
Launchy.exe. No installation is needed. Press Alt+Space to show it.

Settings are kept in %APPDATA%\Launchy\launchy.ini. To keep them next to
Launchy.exe instead, e.g. on a USB drive, tick "Portable mode (USB stick)"
in Options > General. Launchy uses portable mode whenever there is a
launchy.ini in the same folder as Launchy.exe.

Skins are read from the skins folder here and from %APPDATA%\Launchy\skins.


Changes from the official 2.6 Beta 2
------------------------------------
Runner commands accept two new optional settings, also editable in the
Runner plugin options:

  cmds\N\icon=C:\\path\\to\\app.ico     .ico or .png file
  cmds\N\icon=C:\\path\\to\\app.dll,3   icon 3 inside an exe or dll
  cmds\N\show=hidden                     normal (default), hidden or minimized

"show=hidden" runs a .cmd or .bat without flashing a console window.

If a command's icon file is missing, the program's own icon is used, then
the Runner icon, rather than a folder icon.

Also:
- Icons display correctly under Qt 4.8, at the system icon size for the
  display scaling (40 pixels at 125%)
- Suggestion list rows fit both the name and the path
- Black Glass Large skin: Black Glass at 1.5x size
- The Google Calculator (gcalc) plugin, which no longer works, is removed


License
-------
Launchy is free software under the GNU General Public License version 2,
see LICENSE.txt. It uses the Qt 4.8.7 libraries under the GNU Lesser
General Public License version 2.1 and the MinGW-w64 GCC runtime; their
licenses are in the licenses folder.
