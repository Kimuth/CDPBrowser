import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Window 2.1

/**
  * File: Browser.qml
  *
  * The main container for "data view".
  * Contains :
  *     - "navigation view" to the left
  *     - "path view" to the top
  *     - "main view" center
*/

Item {
    id: browserItem

    implicitWidth: 480
    implicitHeight: 800

    property string m_sCompUrl          : ""                    ///< Contains Url to CDP component
    property string m_sUserName         : ""                    ///< Contains User name
    property string m_sPassWd           : ""                    ///< Contains Password
    property bool   m_bIsPreCdp4Release : true                  ///< Contains Type of controller
    property alias  m_aMainPageState    : mainPageRect.state    ///< State of mainpage in flickable
    property alias  m_aCurrentCompPath  : navPath.m_sFullListString ///< Full string to active CDP component

    /** After component creation sets the source to "navigation view" */
    Component.onCompleted: {
        sideList1.setSource("BrowserSideList.qml",{"m_sCompUrl" :m_sCompUrl,
                                                   "m_sUserName":m_sUserName,
                                                   "m_sPassWd"  :m_sPassWd,
                                                   "m_bIsPreCdp4Release":m_bIsPreCdp4Release})
    }

    /** When the active CDP component is changed update the "main view" */
    onM_aCurrentCompPathChanged: {
        mainPage.setSource("ComponentMain.qml",{"m_sCompUrl" :m_sCompUrl,
                                                "m_sActiveCompPath":m_aCurrentCompPath})
    }

    /* Debug text
    Text {
        id: debugText3
        z:1
        color: "white"
        text: qsTr("DebugText3 : \nScreen.pixelDensity : " + Screen.pixelDensity.toPrecision(4))
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    } */

    /** Container to enable the "flicking" to se the "navigation view" */
    Flickable{
        id: myFlickable
        anchors.fill: parent
        contentWidth: browserItem.width + sideBarRect.width
        boundsBehavior: Flickable.StopAtBounds

        /** After component creation set the view to hide "navigation view" to the left */
        Component.onCompleted: {
            myFlickable.state = "view1"
        }

        /** Implemented to ensure no middle state for showing "navigation view" */
        onMovementEnded: {
            myFlickable.state = '';
            if(myFlickable.contentX < sideBarRect.width*0.5)
                myFlickable.state = "view2";
            else
                myFlickable.state = "view1";
        }

        /** Container for the main part of the page, "path view" + "main view" */
        Rectangle{
            id: mainPageRect
            x: sideBarRect.width + 1
            width:  browserItem.width
            height: browserItem.height

            /** Container for the "navigation view" */
            Rectangle {
                id: topRect
                height: mainPageRect.height/7
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                border.width: 4
                color: "#333333"

                /** Creates an instance of a BrowserNavView, "path view" */
                BrowserNavView{
                    id: navPath
                    anchors.fill: parent
                }
            }//End topRect

            /** Implemented to enable loading of the "main view" only when needed */
            Loader {
                id: mainPage
                anchors.top: topRect.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                //asynchronous: true

            }
        }//End MainPage

        /** Container to hold the "navigation view" */
        Rectangle {
            id: sideBarRect
            x: 0
            y: 0

            // Width dependant on screen orientation.
            width:  (Screen.primaryOrientation === Qt.LandscapeOrientation) ?  browserItem.width*0.4 : browserItem.width*0.9
            height: browserItem.height

            /** Implemented to enable loading of the "navigation view" only when needed */
            Loader {
                id: sideList1
                anchors.fill: parent
                asynchronous: false

                onLoaded: {
                    sideList1.item.ms_selectPage.connect(navPath.itemAdd)
                    console.log("SideList1 loader is loaded!!")
                }
            }
        }//End SideBar

        states: [
            State {
                name: "view1"
                PropertyChanges { target: myFlickable; contentX: sideBarRect.width}
            },
            State {
                name: "view2"
                PropertyChanges { target: myFlickable; contentX: 0 }
            }
        ]

        transitions:
            Transition {
                PropertyAnimation {
                    property: "contentX"
                    easing.type: Easing.InOutQuart
                    duration: 750
                }
            }
    }//End myFlickable
}//End browserItem
