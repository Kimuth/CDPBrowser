import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.1
import "Browser"
import "pics"

/**
  * File: main.qml
  *
  * The main entry point for qml to the application
  *
  *
*/

/** Main application window. */
ApplicationWindow {
    id: appWindow
    title: qsTr("BrowserV2")
    width: 480
    height: 800

    /** Menu that use native menu style on running platform */
    menuBar: MenuBar {
        Menu {
            title: qsTr("HOME")
            MenuItem {
                text: qsTr("Home")
                onTriggered: flipable.flip();
            }
            MenuItem {
                text: qsTr("Back")
                onTriggered: {
                    if(backLoad.item.m_aBrowserSide == Flipable.Back){
                        console.log("Backload's flipable is back.")
                        backLoad.item.s_browserFlip()
                    }
                    else if(flipable.side == Flipable.Back)
                        flipable.flip();
                    else
                        Qt.quit()
                }
            }
        }

        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }

    }//End MenuBar




    /** Container to enable Flipable trasition from main page*/
    Flipable {
        id: flipable
             implicitWidth: 480
             implicitHeight: 800
             anchors.fill: parent

             property bool flipped: false               ///< True when flipable shows back.
             property string functionSelection : ""     ///< Holds the name of qml type to show on back.
             signal flip                                ///< Signal to control flipping.

             /** After component is created connects a button from "mainPage" to "flip" signal*/
             Component.onCompleted: {
                 mainPage.onButtonClicked.connect(flip)
             }

             /** Sets the first page of flipable */
             front: mainPage

             /** Sets the second page of flipable */
             back: Rectangle {
                 anchors.fill: parent
                 gradient: Gradient {
                     GradientStop {position: 0.0; color: "#666666"}
                     GradientStop {position: 1.0; color: "#000000"}
                     }

                 /** Implemented to load the "back" page only when needed */
                 Loader {
                     id: backLoad
                     source: flipable.functionSelection
                     asynchronous: true
                     anchors.fill: parent

                     onLoaded: {
                         backLoad.item.focus = false
                    }
                 }
             }//End back

             /** Set how the flipable wil transform from front to back */
             transform: Rotation {
                 id: rotation
                 origin.x: flipable.width/2
                 origin.y: flipable.height/2
                 axis.x: 0; axis.y: 1; axis.z: 0    // set axis.y to 1 to rotate around y-axis
                 angle: 0                           // the default angle
             }

             /** Addes a second state to flipable */
             states: State {
                 name: "back"
                 PropertyChanges { target: rotation; angle: 180 }
                 PropertyChanges { target: mainPage; visible: false}
                 when: flipable.flipped
             }

             /** Adds animations with duration to object proprties */
             transitions: Transition {
                 NumberAnimation { target: rotation; property: "angle"; duration: 1000 }
                 NumberAnimation { target: mainPage; property: "visible"; duration: 1000 }
             }

             /** Adds function to perform when the signal flip is triggered */
             onFlip: {
                 flipable.flipped = !flipable.flipped
             }
    }

    /** Design of the front page of the flickable */
    Item {
        id: mainPage
        anchors.fill: parent

        signal buttonClicked                        ///< Signal to emit a button clicked on "mainPage"

        Component.onCompleted: {
            settings.clicked.connect(buttonClicked)
            browser.clicked.connect(buttonClicked)
        }

        /** Background image for "mainPage" */
        Image {
            id: mainBgPix
            source: "pics/doc_90_5_V2.png"
            anchors.fill: parent
        }

        /** Container to arange buttons added to "mainPage" */
        Column {
            id: mainColumn
            spacing:  20
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            /** Button to access application settings */
            //TODO: implement setting functionality.
            Button {
                id: settings
                text: "Settings"
                anchors.horizontalCenter: parent.horizontalCenter
                style: ButtonStyle {
                    background: Rectangle {
                    implicitWidth: appWindow.width - appWindow.width/10
                    implicitHeight: appWindow.height/20
                    border.color: control.pressed ? "black" :"white"
                    border.width: 3
                    radius: 10

                    gradient: Gradient {
                                    GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                                    GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                                }
                    }
                }

                onClicked: {
                    flipable.functionSelection = "Browser/CompSignal.qml"
                }
            }//End settings

            /** Button to access application Browser */
            Button {
                id: browser
                text: "Browser"
                anchors.horizontalCenter: parent.horizontalCenter
                style: ButtonStyle {
                    background: Rectangle {
                    implicitWidth: appWindow.width - appWindow.width/10
                    implicitHeight: appWindow.height/20
                    border.color: control.pressed ? "black" :"white"
                    border.width: 3
                    radius: 10

                    gradient: Gradient {
                                    GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                                    GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                                }
                    }
                }

                /** When button is clicked sets its value to be shown on "back" page */
                onClicked : {
                    flipable.functionSelection = "Browser/BrowserMain.qml"
                }
            }
        }//End Column
    }//End MainPage

}//End appWindow
