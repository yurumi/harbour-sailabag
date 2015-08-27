#include "SslIgnoreNetworkAccessManager.h"
#include <QNetworkReply>

SslIgnoreNetworkAcessManager::SslIgnoreNetworkAcessManager(QObject *parent)
  : QNetworkAccessManager(parent)
{
  QObject::connect(this, SIGNAL(sslErrors(QNetworkReply*, QList<QSslError>)),
		   this, SLOT(ignoreSslErrors(QNetworkReply*, QList<QSslError>)));
}


void SslIgnoreNetworkAcessManager::ignoreSslErrors(QNetworkReply* reply, QList<QSslError> errorList)
{
  qDebug() << "IGNORING SSL ERRORS!";
  reply->ignoreSslErrors(errorList);
}

