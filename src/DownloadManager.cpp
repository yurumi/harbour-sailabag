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

#include "DownloadManager.h"
#include "SslIgnoreNetworkAccessManager.h"
#include <iostream>

using namespace std;

DownloadManager::DownloadManager(QObject *parent)
  : QObject(parent),
    m_lastFeedType("invalid_feed_type")
{
}

void DownloadManager::downloadFeed(const QString &url, const int &userID, const QString &userToken, const QString &feedType)
{
  m_lastFeedType = feedType;
  
  SslIgnoreNetworkAccessManager *manager = new SslIgnoreNetworkAccessManager(this);
  connect(manager, SIGNAL(finished(QNetworkReply*)),
          this, SLOT(replyFinished(QNetworkReply*)));
 
  QString requestString(url);
  requestString.append("/?feed&type=");
  requestString.append(feedType);
  requestString.append("&user_id=");
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
  // TODO: Error notification, when no bytes were received --> check server settings (not just base domain)
  // qDebug() << "REPLY FINISHED. RECEIVED BYTES: " << reply->readBufferSize();
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
  
  emit itemParsed(url, id.toInt(), title, content, pubDate, m_lastFeedType);
}

