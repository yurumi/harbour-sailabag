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

#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>
#include <QHash>
#include <QStandardPaths>
#include <QtNetwork>
#include <QtXml>

class DownloadManager : public QObject
{
  Q_OBJECT

public:
  explicit DownloadManager(QObject *parent = 0);

  Q_INVOKABLE void downloadFeed(const QString &url, const int &userID, const QString &userToken);
  
  Q_INVOKABLE void updateSignInState(const QString &url);
				    
signals:
  void itemParsed(QString, int, QString, QString, QString);
  void syncFinished();
  void downloadError();                   
  void notification(QString, QString, QString);
  void signInStateUpdate(bool);
                      
public slots:
  void replyFinished(QNetworkReply*);
  void updateSignInStateReplyFinished(QNetworkReply*);

private:
  void parseItem(const QDomElement & e);
};

#endif // DOWNLOADMANAGER_H
