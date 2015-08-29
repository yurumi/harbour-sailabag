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

#ifndef SSLIGNORENAMFACTORY_H 
#define SSLIGNORENAMFACTORY_H 

#include <QObject>
#include <QQmlNetworkAccessManagerFactory>
#include "SslIgnoreNetworkAccessManager.h"

class SslIgnoreNamFactory : public QObject, public QQmlNetworkAccessManagerFactory
{
  Q_OBJECT

public:
  virtual QNetworkAccessManager *create(QObject *parent){
    SslIgnoreNetworkAccessManager* manager = new SslIgnoreNetworkAccessManager(parent);
    return manager;
  }
};

#endif // SSLIGNORENAMFACTORY_H
