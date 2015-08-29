#ifndef SSLIGNORENETWORKACCESSMANAGER_H 
#define SSLIGNORENETWORKACCESSMANAGER_H 

#include <QNetworkAccessManager>

class SslIgnoreNetworkAccessManager : public QNetworkAccessManager
{
  Q_OBJECT

public:
  SslIgnoreNetworkAccessManager(QObject *parent = 0);
                      
public slots:
  void ignoreSslErrors(QNetworkReply* reply, QList<QSslError> errorList);
};

#endif // SSLIGNORENETWORKACCESSMANAGER_H
