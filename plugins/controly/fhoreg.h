// Copyright 2009 Fabian Hofsaess

#ifndef FHOREG_H
#define FHOREG_H


// implement a convenient class instead of an aggregation of static semi-convenient methods!
class FhoReg {
	private:
		static const DWORD maxSize = 256;

	public:
		static HKEY OpenKey(HKEY baseKey, const QString &subKeyName, DWORD options);
		static void CloseKey(HKEY key);

		static QString GetKeyValue(HKEY key, const QString &valueName);
		static QString GetKeyValue(HKEY parentKey, const QString &parentSubKeyName, const QString &valueName);
		static QString GetKeyDefaultValue(HKEY key);
		static QString GetKeyDefaultValue(HKEY parentKey, const QString &parentSubKeyName);

		static QStringList* EnumValues(HKEY parentKey, const QString &parentSubKeyName);
		static QStringList* EnumSubKeys(HKEY key);
		static QStringList* EnumSubKeys(HKEY parentKey, const QString &parentSubKeyName);

};


#endif
