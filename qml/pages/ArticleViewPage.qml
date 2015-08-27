import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

Page {
    id: articleview

    property string articleUrl: ""
    property string articleTitle: ""
    property string articleContent: ""
    property string articlePubDate: ""

    SilicaWebView {
        id: webview
        anchors.fill: parent
        Component.onCompleted: {
            webview.loadHtml(createHtmlHeader() + articleContent + createHtmlFooter()) }
    }

    function createHtmlHeader(){
        var originalUrlText = ""
        var htmlHeader = "<html>\n" +
                "\t<head>\n" +
                "\t\t<meta name=\"viewport\" content=\"initial-scale=1.5, maximum-scale=1.5, user-scalable=no\" />\n" +
                "\t\t<meta charset=\"utf-8\">\n" +
                "\t\t<link rel=\"stylesheet\" href=\"main.css\" media=\"all\" id=\"main-theme\">\n" +
                "\t\t<link rel=\"stylesheet\" href=\"ratatouille.css\" media=\"all\" id=\"extra-theme\">\n" +
                "\t</head>\n" +
                "\t\t<div id=\"main\">\n" +
                "\t\t\t<body>\n" +
                "\t\t\t\t<div id=\"content\" class=\"w600p center\">\n" +
                "\t\t\t\t\t<div id=\"article\">\n" +
                "\t\t\t\t\t\t<header class=\"mbm\">\n" +
                "\t\t\t\t\t\t\t<h1>" + articleTitle + "</h1>\n" +
                "\t\t\t\t\t\t\t<p>Open Original: <a href=\"" + originalUrlText + "\">" + articleUrl + "</a></p>\n" +
                "\t\t\t\t\t\t</header>\n" +
                "\t\t\t\t\t\t<article>"
        return htmlHeader
    }

    function createHtmlFooter(){
        var htmlFooter = "</article>\n" +
                        "\t\t\t\t\t</div>\n" +
                        "\t\t\t\t</div>\n" +
                        "\t\t\t</body>\n" +
                        "\t\t</div>\n" +
                        "</html>"
        return htmlFooter
    }
}
