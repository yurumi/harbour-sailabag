import QtQuick 2.1
import Sailfish.Silica 1.0
// import "../../../js/settings/Database.js" as Database
// import "../../../js/settings/Credentials.js" as Credentials

Item
{
    id: listener

    QtObject
    {
        readonly property var dispatcher: { "console_log": onConsoleLog,
                                            "submit": onFormSubmit }

        id: listenerprivate

        function onConsoleLog(data) {
            console.log(data.log);
        }

        function onFormSubmit(data) {
            // linkmenu.hide();

            // if((mainwindow.settings.clearonexit === false) && Credentials.needsDialog(Database.instance(), url.toString(), data)) {
            //     credentialdialog.url = url.toString();
            //     credentialdialog.logindata = data;
            //     credentialdialog.show();
            // }
        }
    }

    function execute(message)
    {
        var data = JSON.parse(message.data);
        var eventfn = listenerprivate.dispatcher[data.type];

        if(eventfn)
            eventfn(data);
    }
}
