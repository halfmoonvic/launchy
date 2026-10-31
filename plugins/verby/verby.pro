TEMPLATE = lib
CONFIG += plugin \
    release
VPATH += ../../src/
INCLUDEPATH += ../../src/
PRECOMPILED_HEADER = precompiled.h
UI_DIR = ../../plugins/Verby/
FORMS = dlg.ui
HEADERS = plugin_interface.h \
    gui.h \
    Verby.h \
    precompiled.h
SOURCES = plugin_interface.cpp \
    gui.cpp \
    Verby.cpp
TARGET = verby
win32 { 
	win32-g++:LIBS += -luser32 -lshell32
}
if(!debug_and_release|build_pass):CONFIG(debug, debug|release):DESTDIR = ../../debug/plugins
if(!debug_and_release|build_pass):CONFIG(release, debug|release):DESTDIR = ../../release/plugins
