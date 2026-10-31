TEMPLATE = lib
CONFIG += plugin \
    debug_and_release
VPATH += ../../src/
INCLUDEPATH += ../../src/
INCLUDEPATH += c:/boost/
PRECOMPILED_HEADER = precompiled.h
UI_DIR = ../../plugins/calcy/
HEADERS = plugin_interface.h \
    calcy.h \
    precompiled.h \
    gui.h
SOURCES = plugin_interface.cpp \
    calcy.cpp \
    gui.cpp
TARGET = calcy
win32 { 
	win32-g++:LIBS += -luser32 -lshell32
}
if(!debug_and_release|build_pass):CONFIG(debug, debug|release):DESTDIR = ../../debug/plugins
if(!debug_and_release|build_pass):CONFIG(release, debug|release):DESTDIR = ../../release/plugins

FORMS += dlg.ui
