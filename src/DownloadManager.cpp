#include "DownloadManager.h"
#include "SslIgnoreNetworkAccessManager.h"
#include <iostream>

using namespace std;

DownloadManager::DownloadManager(QObject *parent)
  : QObject(parent)
{
}

void DownloadManager::downloadFeed(const QString &url, const int &userID, const QString &userToken)
{
  SslIgnoreNetworkAccessManager *manager = new SslIgnoreNetworkAccessManager(this);
  connect(manager, SIGNAL(finished(QNetworkReply*)),
          this, SLOT(replyFinished(QNetworkReply*)));
 
  QString requestString(url);
  requestString.append("/?feed&type=home&user_id=");
  requestString.append(QString::number(userID));
  requestString.append("&token=");
  requestString.append(userToken);
  
  QUrl requestUrl(requestString);
  manager->get(QNetworkRequest(requestUrl));
}

void DownloadManager::updateSignInState(const QString &url)
{
  QNetworkAccessManager *manager = new QNetworkAccessManager(this);
  connect(manager, SIGNAL(finished(QNetworkReply*)),
          this, SLOT(updateSignInStateReplyFinished(QNetworkReply*)));

  QString requestString(url);
  requestString.append("/");

  QUrl requestUrl(requestString);
  manager->get(QNetworkRequest(requestUrl));
}

void DownloadManager::replyFinished(QNetworkReply* reply)
{
  if(reply->error() == QNetworkReply::NoError){
    QDomDocument doc("mydocument");
    QString errorStr;
    int errorLine;
    int errorColumn;

    if (!doc.setContent(reply, true, &errorStr, &errorLine, &errorColumn)) {
      emit notification("ERROR", tr("XML error"), tr("Check user ID and token."));
    }else{
      QDomElement root = doc.documentElement();
      if(root.tagName() != "rss"){
        emit notification("ERROR", tr("XML error"), tr("No RSS node found.  Check user ID and token."));
	return;
      }else{
        QDomElement channel = root.firstChildElement("channel");
        if(!channel.isNull()){
          QDomElement item = channel.firstChildElement("item");
          while(!item.isNull()){
            parseItem(item);
            item = item.nextSiblingElement("item");
          }
        }else{
          emit notification("ERROR", tr("XML error"), tr("No channel found. Check user ID and token."));
	  return;
        }
      }
    }
    emit notification("OK", "Success", "Database synchronized.");
  }
  else if(reply->error() == QNetworkReply::UnknownNetworkError){
    emit notification("ERROR", tr("Network error"), tr("Server unknown. Check server settings."));
  }
  else if(reply->error() == QNetworkReply::ContentNotFoundError){
    emit notification("ERROR", tr("Network error"), tr("Remote content not found. Check server settings."));
  }
  else{
    emit notification("ERROR", tr("Unknown error"), tr("QNetworkError::%1").arg(reply->error()));
  }

  reply->deleteLater();
  
  emit syncFinished();
}

void DownloadManager::updateSignInStateReplyFinished(QNetworkReply* reply)
{
  bool signedIn = false;
  
  if(reply->error() == QNetworkReply::NoError){
    QDomDocument doc("mydocument");
    QString errorStr;
    int errorLine;
    int errorColumn;

    
    qDebug() << "ByteArray: " << reply->url();
    qDebug() << reply->readAll();
    
    if (!doc.setContent(reply, true, &errorStr, &errorLine, &errorColumn)) {
      qDebug() << "errorStr: " << errorStr;
      qDebug() << "errorLine: " << errorLine;
      qDebug() << "errorColumn: " << errorColumn;
      emit notification("ERROR", tr("Html error"), tr("Check server sanity."));
    }else{
      QDomElement root = doc.documentElement();
      // if(root.tagName() != "rss"){
      //   emit notification("ERROR", tr("XML error"), tr("No RSS node found.  Check user ID and token."));
      // }else{
      //   QDomElement channel = root.firstChildElement("channel");
      //   if(!channel.isNull()){
      //     QDomElement item = channel.firstChildElement("item");
      //     while(!item.isNull()){
      //       parseItem(item);
      //       item = item.nextSiblingElement("item");
      //     }
      //   }else{
      //     emit notification("ERROR", tr("XML error"), tr("No channel found. Check user ID and token."));
      //   }
      // }

      emit notification("OK", "Signed in", "");
    }
  }
  else if(reply->error() == QNetworkReply::UnknownNetworkError){
    emit notification("ERROR", tr("Network error"), tr("Server unknown. Check server settings."));
  }
  else if(reply->error() == QNetworkReply::ContentNotFoundError){
    emit notification("ERROR", tr("Network error"), tr("Remote content not found. Check server settings."));
  }
  else{
    emit notification("ERROR", tr("Unknown error"), tr("QNetworkError::%1").arg(reply->error()));
  }

  reply->deleteLater();
  
  emit signInStateUpdate(signedIn);
}

void DownloadManager::parseItem(const QDomElement & e)
{
  QString title, url, content, pubDate, sourceUrl;
  title = e.firstChildElement("title").text();
  url = e.firstChildElement("link").text();
  content = e.firstChildElement("description").text();
  pubDate = e.firstChildElement("pubDate").text();
  sourceUrl = e.firstChildElement("source").attribute("url");
  

  QUrlQuery u(sourceUrl);
  QString id = u.queryItemValue("id");
  
  emit itemParsed(url, id.toInt(), title, content, pubDate);
}

