/*
    Sailabag - A SailfishOS client for wallabag.
    Copyright (C) 2015 Thomas Eigel
    Contact: Thomas Eigel <yurumi@gmx.de>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QTranslator>
#include <QLocale>
#include <QGuiApplication>
#include <QtGui>
#include <QtQml>
#include <QProcess>
#include <QQuickView>
#include <sailfishapp.h>
#include <notification.h>
#include "DownloadManager.h"
#include "SslIgnoreNamFactory.h"

int main(int argc, char *argv[])
{
  QScopedPointer<QGuiApplication> application(SailfishApp::application(argc, argv));
  application->setApplicationName("harbour-sailabag");

  qmlRegisterType<Notification>("harbour.sailabag.notifications", 1, 0, "Notification");
  qmlRegisterType<DownloadManager>("harbour.sailabag.DownloadManager", 1, 0, "DownloadManager");

  QScopedPointer<QQuickView> view(SailfishApp::createView());
  QQmlEngine* engine = view->engine();
  QObject::connect(engine, SIGNAL(quit()), application.data(), SLOT(quit()));

  engine->setNetworkAccessManagerFactory(new SslIgnoreNamFactory());
  view->setSource(SailfishApp::pathTo("qml/harbour-sailabag.qml"));
  view->show();

  return application->exec();
}

