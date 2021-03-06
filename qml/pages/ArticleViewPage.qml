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

import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

import "../components"
import "../js/articles/ArticlesDatabase.js" as ArticlesDatabase

Page {
    id: articleview

    property string articleUrl: ""
    property string articleTitle: ""
    property string articleContent: ""
    property variant articlesModel: null

    onStatusChanged: {
        if(status === PageStatus.Activating){
            loadScreen.state = "show"
            webview.visible = false
        }
    }
    
    Component.onCompleted: {
        loadScreen.state = "show"
        webview.visible = false
    }

    function markAsRead() {
        remorse.execute(qsTr("Stage for archiving"), function() {
            ArticlesDatabase.markAsRead(articlesModel, articleUrl)
            pageStack.navigateBack(PageStackAction.Animated) }, 2000)
    }

    function stageForDeletion() {
        remorse.execute(qsTr("Stage for deletion"), function() {
            ArticlesDatabase.stageForDeletion(articlesModel, articleUrl)
            pageStack.navigateBack(PageStackAction.Animated) }, 2000)
    }

    function shareArticle() {
        shareArticlePopup.articleURL = articleUrl
        shareArticlePopup.state = "visible"
    }
    
    RemorsePopup { id: remorse }
    
    SilicaWebView {
        id: webview
        anchors.fill: parent

        header: PageHeader {
            title: articleTitle
            // wrapMode: Text.Elide
        }

        VerticalScrollDecorator { flickable: webview; color: "black" }

        Component.onCompleted: {
            webview.loadHtml(createHtmlHeader() + articleContent + createHtmlFooter()) }

        PullDownMenu {
            MenuItem {
                text: qsTr("Stage for archiving")
                onClicked: { markAsRead() }
            }
            MenuItem {
                text: qsTr("Stage for deletion")
                onClicked: { stageForDeletion() }
            }
            MenuItem {
                text: qsTr("Share")
                onClicked: { shareArticle() }
            }            
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Share")
                onClicked: { shareArticle() }
            }            
            MenuItem {
                text: qsTr("Stage for deletion")
                onClicked: { stageForDeletion() }
            }
            MenuItem {
                text: qsTr("Stage for archiving")
                onClicked: { markAsRead() }
            }
        }

        onLoadingChanged: {
            if(loadRequest.status === WebView.LoadStartedStatus){
                loadScreen.state = "show"
                webview.visible = false
            }else{
                loadScreen.state = "hide"
                webview.visible = true
            }
        }
    }
    
    function createHtmlHeader(){
        var originalUrlText = ""
        var htmlHeader = "<html>\n" +
                "\t<head>\n" +
                "\t\t<meta name=\"viewport\" content=\"initial-scale=1.5, maximum-scale=1.5, user-scalable=no\" />\n" +
                "\t\t<meta charset=\"utf-8\">\n" +
                "\t\t<style type=\"text/css\">\n" +
                "\t\t\tbody {background-color: #EEE; }\n" +
                "\t\t\tp.orglink{\n" + 
                "\t\t\t\tcolor: #666;\n" +
                "\t\t\t\tfont-size: 0.8em;\n" +
                "\t\t\t}\n" +
                "\t\t\ta {\n" +
                "\t\t\t\tcolor: #000;\n" +
                "\t\t\t\tfont-weight: bold;\n" +
                "\t\t\t}\n" +
                "\t\t\th1, h2, h3, h4 {\n" +
                "\t\t\tfont-family: 'PT Sans', sans-serif;\n" +
                "\t\t\ttext-transform: uppercase;\n" +
                "\t\t\tfont-size: 1.2em;\n" +
                "\t\t\t}\n" +
                "\t\t</style>\n" +
                // "\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"main.css\" media=\"all\" id=\"main-theme\">\n" +
                // "\t\t<link rel=\"stylesheet\" href=\"ratatouille.css\" media=\"all\" id=\"extra-theme\">\n" +
                "\t</head>\n" +
                "\t\t<div id=\"main\">\n" +
                "\t\t\t<body>\n" +
                "\t\t\t\t<div id=\"content\" class=\"w600p center\">\n" +
                "\t\t\t\t\t<div id=\"article\">\n" +
                "\t\t\t\t\t\t<header class=\"mbm\">\n" +
                // "\t\t\t\t\t\t\t<h1>" + articleTitle + "</h1>\n" +
                "\t\t\t\t\t\t\t<p class=\"orglink\">Open Original: <a href=\"" + originalUrlText + "\">" + articleUrl + "</a></p>\n" +
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

    LoadScreen {id: loadScreen}
    ShareArticle { id: shareArticlePopup;}
}
