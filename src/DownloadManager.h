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
