TEMPLATE = lib
QT += network
CONFIG += plugin \
    debug_and_release
VPATH += ../../src/
PRECOMPILED_HEADER = precompiled.h
INCLUDEPATH += ../../src/
INCLUDEPATH += c:/boost/
INCLUDEPATH += ../../common
UI_DIR = ../../plugins/weby/
FORMS = dlg.ui
HEADERS = plugin_interface.h \
    weby.h \
    gui.h \
    globals.h \
    ../../common/DropTableWidget.h \
    precompiled.h \
    IconCache.h
SOURCES = plugin_interface.cpp \
    weby.cpp \
    gui.cpp \
    ../../common/DropTableWidget.cpp \
    IconCache.cpp
TARGET = weby
win32 { 
	win32-g++:LIBS += -luser32 -lshell32
}
if(!debug_and_release|build_pass):CONFIG(debug, debug|release):DESTDIR = ../../debug/plugins
if(!debug_and_release|build_pass):CONFIG(release, debug|release):DESTDIR = ../../release/plugins
