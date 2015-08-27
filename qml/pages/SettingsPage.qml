import QtQuick 2.1
import Sailfish.Silica 1.0
import "../components"
import "../models"
import "../js/settings/Database.js" as Database
import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

Dialog {
    id: sailorbagsettings
    
    property Settings settings
    property ArticlesModel articlesModel

    allowedOrientations: defaultAllowedOrientations
    acceptDestinationAction: PageStackAction.Pop
    canAccept: true

    function acceptSettings() {
        settings.serverURL = serverurlTF.text;
        settings.userID = useridTF.text;
        settings.userToken = usertokenTF.text;      
        settings.userName = usernameTF.text;      
        settings.userPassword = userpasswordTF.text;      
    
        Database.transaction(function(tx) {
            Database.transactionSet(tx, "serverURL", settings.serverURL);
            Database.transactionSet(tx, "userID", settings.userID);
            Database.transactionSet(tx, "userToken", settings.userToken);
            Database.transactionSet(tx, "userName", settings.userName);
            Database.transactionSet(tx, "userPassword", settings.userPassword);
        });
    }
                   
    onAccepted: {
        acceptSettings()
    }

    RemorsePopup { id: remorseClearDatabase }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + dlgheader.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset Database")
                onClicked: {
                    remorseClearDatabase.execute("Database is going to be cleared",
                                                                                    function() {
                                                                                        ArticlesDatabase.clear(); articlesModel.clear()}
                           )}
            }
        }

        Column
        {
            id: column
            anchors.top: parent.top
            width: parent.width

            DialogHeader
            {
                id: dlgheader
                acceptText: qsTr("Save Settings")
            }

            TextField
            {
                id: serverurlTF
                placeholderText: qsTr("Wallabag URL")
                label: qsTr("Wallabag URL")
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly
                text: settings.serverURL
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: useridTF.focus = true                                                  
            }

            TextField
            {
                id: useridTF
                placeholderText: qsTr("User ID")
                label: qsTr("User ID")
                width: parent.width
                inputMethodHints: Qt.ImhDigitsOnly
                text: settings.userID
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: usertokenTF.focus = true                                                  
            }

            TextField
            {
                id: usertokenTF
                placeholderText: qsTr("User Token")
                label: qsTr("User Token")
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                text: settings.userToken
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: usernameTF.focus = true                                                  
            }

            TextField
            {
                id: usernameTF
                placeholderText: qsTr("Login Name")
                label: qsTr("Login Name")
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                text: settings.userName
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: userpasswordTF.focus = true                                                  
            }

            TextField
            {
                id: userpasswordTF
                placeholderText: qsTr("Password")
                label: qsTr("Password")
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                text: settings.userPassword
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    acceptSettings()
                //                    pageStack.push(Qt.resolvedUrl("ArticleOverviewPage.qml"))
                    // navigateBack(PageStackAction.Animated)
                }
            }

        }
    }
}

