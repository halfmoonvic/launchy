/*
Launchy: Application Launcher
Copyright (C) 2007  Josh Karlin

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#include "precompiled.h"
#include "runner.h"
#include "gui.h"


void RunnerPlugin::init()
{
	QSettings* set = *settings;
	cmds.clear();

	if ( set->value("runner/version", 0.0).toDouble() == 0.0 )
	{
		set->beginWriteArray("runner/cmds");
		set->setArrayIndex(0);
		#ifdef Q_WS_WIN
		set->setValue("name", "cmd");
		set->setValue("file", "C:\\Windows\\System32\\cmd.exe");
		set->setValue("args", "/K $$");
		#endif
		#ifdef Q_WS_X11
		set->setValue("name", "cmd");
		set->setValue("file", "/usr/bin/xterm");
		set->setValue("args", "-hold -e $$");
		#endif
                /*
                #ifdef Q_WS_MAC
                set->setValue("name", "cmd");
                set->setValue("file", "")
                #endif
                */
		set->endArray();
	}
	set->setValue("runner/version", 2.0);

	// Read in the array of websites
	int count = set->beginReadArray("runner/cmds");
	for(int i = 0; i < count; ++i)
	{
		set->setArrayIndex(i);
		runnerCmd cmd;
		cmd.file = set->value("file").toString();
		cmd.name = set->value("name").toString();
		cmd.args = set->value("args").toString();
		// QSettings reads an unquoted "file,index" as a string list
		cmd.icon = set->value("icon").toStringList().join(",");
		cmds.push_back(cmd);
	}
	set->endArray();
}


void RunnerPlugin::getID(uint* id)
{
	*id = HASH_runner;
}


void RunnerPlugin::getName(QString* str)
{
	*str = "Runner";
}


QString RunnerPlugin::getIcon()
{
    return libPath + "/icons/runner.png";
}


// Pick the icon for a command: its own icon if that exists, then the icon of
// the program it runs, then the runner icon. A missing file would otherwise
// be shown with the shell's folder icon.
QString RunnerPlugin::getIcon(const runnerCmd& cmd)
{
	if (!cmd.icon.isEmpty())
	{
		// "file,index" refers to an icon inside an exe or dll
		QString iconFile = cmd.icon;
		QRegExp resourceRx("^(.+),-?\\d+$");
		if (!QFile::exists(iconFile) && resourceRx.exactMatch(iconFile))
			iconFile = resourceRx.cap(1);
		if (QFile::exists(iconFile))
			return cmd.icon;
	}

#ifdef Q_WS_WIN
	// Relative names such as notepad.exe are resolved by the shell, so only
	// absolute paths can be checked
	QRegExp rx("\\.(exe|lnk)$", Qt::CaseInsensitive);
	if (rx.indexIn(cmd.file) != -1 && (QFileInfo(cmd.file).isRelative() || QFile::exists(cmd.file)))
		return cmd.file;
#endif
	return getIcon();
}


void RunnerPlugin::getCatalog(QList<CatItem>* items)
{
	foreach(runnerCmd cmd, cmds)
	{
		items->push_back(CatItem(cmd.file + "%%%" + cmd.args, cmd.name, HASH_runner, getIcon(cmd)));
	}
}


void RunnerPlugin::getResults(QList<InputData>* inputData, QList<CatItem>* results)
{
    if (inputData->count() <= 1)
		return;

	CatItem& catItem = inputData->first().getTopResult();
        if (catItem.id == (int) HASH_runner && inputData->last().hasText())
	{
		const QString & text = inputData->last().getText();
		// This is user search text, create an entry for it
		results->push_front(CatItem(text, text, HASH_runner, catItem.icon));
	}
}


void RunnerPlugin::launchItem(QList<InputData>* inputData, CatItem* item)
{
	item = item; // Compiler warning

	QString file = "";
	QString args = "";

	CatItem* base = &inputData->first().getTopResult();

	file = base->fullPath;

	// Replace the $'s with arguments
	QStringList spl = file.split("$$");

	file = spl[0];
	for (int i = 1; i < spl.size(); ++i)
	{
		if (inputData->count() >= i+1)
		{ 
//			const InputData* ij = &inputData->at(i);
			CatItem* it = &((InputData)inputData->at(i)).getTopResult();
			file += it->fullPath;
		}
		file += spl[i];
	}

	// Split the command from the arguments
	spl = file.split("%%%");

	file = spl[0];
	if (spl.count() > 0)
		args = spl[1];

	if (file.contains("http://"))
	{
		QUrl url(file);
		file = url.toEncoded();
	}
	//	qDebug() << file << args;
	runProgram(file, args);
}


void RunnerPlugin::doDialog(QWidget* parent, QWidget** newDlg)
{
	if (gui != NULL)
		return;
	gui.reset(new Gui(parent, *settings));
	*newDlg = gui.get();
}


void RunnerPlugin::endDialog(bool accept)
{
	if (accept)
	{
		gui->writeOptions();
		init();
	}
	gui.reset();
}

void RunnerPlugin::setPath(QString * path)
{
    libPath = *path;
}


int RunnerPlugin::msg(int msgId, void* wParam, void* lParam)
{
	bool handled = false;
	switch (msgId)
	{		
	case MSG_INIT:
		init();
		handled = true;
		break;
	case MSG_GET_ID:
		getID((uint*) wParam);
		handled = true;
		break;
	case MSG_GET_NAME:
		getName((QString*) wParam);
		handled = true;
		break;
	case MSG_GET_CATALOG:
		getCatalog((QList<CatItem>*) wParam);
		handled = true;
		break;
	case MSG_GET_RESULTS:
		getResults((QList<InputData>*) wParam, (QList<CatItem>*) lParam);
		handled = true;
		break;
	case MSG_LAUNCH_ITEM:
		launchItem((QList<InputData>*) wParam, (CatItem*) lParam);
		handled = true;
		break;
	case MSG_HAS_DIALOG:
		handled = true;
		break;
	case MSG_DO_DIALOG:
		doDialog((QWidget*) wParam, (QWidget**) lParam);
		break;
	case MSG_END_DIALOG:
		endDialog(wParam != 0);
		break;
	case MSG_PATH:
	    setPath((QString*) wParam);

	default:
		break;
	}
		
	return handled;
}

Q_EXPORT_PLUGIN2(runner, RunnerPlugin) 
