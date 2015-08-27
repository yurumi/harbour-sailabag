# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailabag

CONFIG += sailfishapp c++11
QT += dbus xml

SOURCES += src/harbour-sailabag.cpp \
    src/DownloadManager.cpp \
    src/SslIgnoreNetworkAccessManager.cpp

OTHER_FILES += qml/harbour-sailabag.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-sailabag.changes.in \
    rpm/harbour-sailabag.spec \
    rpm/harbour-sailabag.yaml \
    translations/*.ts \
    harbour-sailabag.desktop \
    qml/pages/ArchiveOverviewPage.qml \
    qml/pages/ArticleOverviewPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/ArticleViewPage.qml \
    qml/js/articles/ArticlesDatabase.js \
    qml/models/ArticlesModel.qml \
    qml/models/Settings.qml \
    qml/pages/SignInPage.qml \
    qml/js/Console.js \
    qml/js/settings/Database.js

include(third_party/notifications.pri)

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-sailabag-de.ts

HEADERS += \
    src/DownloadManager.h \
    src/SslIgnoreNetworkAccessManager.h \
    src/SslIgnoreNamFactory.h

RESOURCES += \
    res.qrc

