TEMPLATE = lib
CONFIG += plugin \
    debug_and_release
VPATH += ../../src
INCLUDEPATH += ../../src
INCLUDEPATH += ../../common
INCLUDEPATH += c:/boost/
PRECOMPILED_HEADER = precompiled.h
UI_DIR = ../../plugins/runner/
FORMS = dlg.ui
HEADERS = plugin_interface.h \
    runner.h \
    gui.h \
    globals.h \
    ../../common/FileBrowserDelegate.h \
    ../../common/FileBrowser.h \
    ../../common/DropTableWidget.h \
    precompiled.h
SOURCES = plugin_interface.cpp \
    runner.cpp \
    gui.cpp \
	../../common/FileBrowser.cpp \
	../../common/FileBrowserDelegate.cpp \
	../../common/DropTableWidget.cpp
TARGET \
    = \
    runner
win32 { 
	win32-g++:LIBS += -luser32 -lshell32
}
 
if(!debug_and_release|build_pass):CONFIG(debug, debug|release) {
    DESTDIR = ../../debug/plugins
}

if(!debug_and_release|build_pass):CONFIG(release, debug|release) {
    DESTDIR = ../../release/plugins
}
