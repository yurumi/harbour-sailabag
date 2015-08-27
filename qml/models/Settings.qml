import QtQuick 2.1

QtObject
{
    property int userID   
    property string userToken
    property string serverURL
    property string userName
    property string userPassword

    readonly property string version: "1.0"
}
