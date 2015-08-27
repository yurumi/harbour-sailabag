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
