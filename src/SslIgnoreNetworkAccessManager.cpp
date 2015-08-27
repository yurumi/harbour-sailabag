#include "SslIgnoreNetworkAccessManager.h"
#include <QNetworkReply>

SslIgnoreNetworkAccessManager::SslIgnoreNetworkAccessManager(QObject *parent)
  : QNetworkAccessManager(parent)
{
  QObject::connect(this, SIGNAL(sslErrors(QNetworkReply*, QList<QSslError>)),
		   this, SLOT(ignoreSslErrors(QNetworkReply*, QList<QSslError>)));
}


void SslIgnoreNetworkAccessManager::ignoreSslErrors(QNetworkReply* reply, QList<QSslError> errorList)
{
  reply->ignoreSslErrors(errorList);
}

