/*
Launchy: Application Launcher
Copyright (C) 2007-2010  Josh Karlin, Simon Capewell

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
#include "icon_delegate.h"
#include "globals.h"
#include "catalog_types.h"

extern QLabel* alternativesPath;

IconDelegate::IconDelegate(QObject *parent) :
	QStyledItemDelegate(parent)
{
}

void IconDelegate::paint(QPainter *painter, const QStyleOptionViewItem &option,
						 const QModelIndex &index) const
{
	painter->save();
	if (option.state & QStyle::State_Selected)
	{
		painter->fillRect(option.rect, option.palette.highlight());
		painter->setPen(option.palette.color(QPalette::HighlightedText));
	}

	// Icon centred vertically with a small margin, both lines of text to its right
	QRect iconRect(option.rect.left() + 4, option.rect.top() + (option.rect.height() - 32) / 2, 32, 32);

	int fontHeight = painter->fontMetrics().height();
	QRect shortRect = option.rect;
	shortRect.setLeft(shortRect.left() + 46);
	shortRect.setBottom(shortRect.top() + fontHeight);

	QRect longRect = option.rect;
	longRect.setLeft(longRect.left() + 58);
	longRect.setTop(longRect.top() + fontHeight);

	QString text = Catalog::decorateText(index.data(ROLE_SHORT).toString(), gSearchText);
	painter->drawText(shortRect, Qt::AlignTop | Qt::TextShowMnemonic, text);

	if (option.state & QStyle::State_Selected)
		painter->setPen(alternativesPath->palette().color(QPalette::HighlightedText));
	else
		painter->setPen(alternativesPath->palette().color(QPalette::WindowText));

	painter->setFont(alternativesPath->font());

	QString full = index.data(ROLE_FULL).toString();
	full = painter->fontMetrics().elidedText(full, option.textElideMode, longRect.width());
	painter->drawText(longRect, Qt::AlignTop, full);

	// Draw the smallest pixmap of at least 32 pixels without shrinking it, up to the
	// system's large icon size (40 pixels at 125% DPI), centred on the icon area.
	// Shrinking a 40 pixel shell icon into 32 pixels makes it look undersized.
	QIcon p = index.data(ROLE_ICON).value<QIcon>();
	int maxSize = 32 * painter->device()->logicalDpiX() / 96;
	QSize size;
	foreach (QSize available, p.availableSizes())
	{
		if (available.width() >= 32 && available.width() <= maxSize &&
			(!size.isValid() || available.width() < size.width()))
			size = available;
	}
	if (!size.isValid())
		size = QSize(32, 32);
	QRect drawRect(QPoint(0, 0), size);
	drawRect.moveCenter(iconRect.center());
	p.paint(painter, drawRect);
	painter->restore();
}


QSize IconDelegate::sizeHint(const QStyleOptionViewItem & option,
							 const QModelIndex & /* index */) const
{
	// Fit both lines of text in the fonts the skin uses, and at least the icon.
	// A fixed 32 pixels cuts off the path line with larger skin fonts.
	int textHeight = option.fontMetrics.height() + alternativesPath->fontMetrics().height() + 4;
	return QSize(10, qMax(32, textHeight));
}
