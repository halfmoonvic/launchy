TEMPLATE = lib
CONFIG += plugin \
    release
VPATH += ../../src/
INCLUDEPATH += ../../src/
PRECOMPILED_HEADER = precompiled.h
DEFINES += WITH_GUI

# UI_DIR = ../../plugins/controly/
FORMS = dlg.ui
HEADERS = plugin_interface.h \
    controly.h \
    gui.h \
    ControlPanelItemFinder.h \
	fhoicon.h \
	fhoenv.h \
	fhoreg.h \
	fhores.h \
    precompiled.h
SOURCES = plugin_interface.cpp \
    controly.cpp \
    gui.cpp \
    ControlPanelItemFinder.cpp \
	fhoicon.cpp \
	fhoenv.cpp \
	fhoreg.cpp \
	fhores.cpp
TARGET = controly
win32 { 
	win32-g++:LIBS += -lshell32 -luser32 -lgdi32 -lcomctl32 -ladvapi32 -lole32 -lshlwapi -luuid
}

# *:debug {
# DESTDIR = ../../debug/plugins/
# }
# *:release {
# DESTDIR = ../../release/plugins/
# %QMAKE_CXXFLAGS += /Ox /Ob2 /Oi /Oy /GT /GA /WX
# }
if(!debug_and_release|build_pass):CONFIG(debug, debug|release):DESTDIR = ../../debug/plugins
if(!debug_and_release|build_pass):CONFIG(release, debug|release):DESTDIR = ../../release/plugins
