import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.0
import QtQuick.Window 2.1
import QtQuick.XmlListModel 2.0

/**
  * File: CompAlarm.qml
  *
  * The sub-type for "main view".
  *
  * Connects to the CDP controller->CDPcomponent->CDPmembers to retrieve its CDPObjects.
  * Displays the CDPObjects MESSAGES.
*/


Item {
    id: componentMessage
    implicitWidth: 480
    implicitHeight: 800
    anchors.fill: parent

    property string m_sCompUrl          : ""                ///< Contains Url to CDP component
    property string m_sActiveCompPath   : ""                ///< Contains full path to active component.
    property string m_sActiveItemName   : ""                ///< Contains short name of active component.

    signal s_ActiveSigChanged(string currSignalName)            ///< Signal to emit change in active CDPObject.

    /** Make sure the "Flickable" is in right state afther creation and fill it from CDP controller. */
    Component.onCompleted: {
        signalFlickable.state = "initState"
        messageModelXml.reload()
    }

    /** Model retrieving data from the controller for each CDPObject */
    XmlListModel {
        id: messageModelXml
        source: m_sCompUrl + m_sActiveCompPath + ".xml"
        query: "/Component/Model/Messages/Message"

        XmlRole {
            name: "messageName"
            query: "@Name/string()"
        }
        XmlRole {
            name: "messageDescription"
            query: "@Description/string()"
        }
        XmlRole {
            name: "messageCommand"
            query: "@Command/string()"
        }
    }

    /*Debug text
    Text {
        id: debugText1
        z:2
        anchors.bottom: parent.bottom
        color: "#ffffff"
        font.pointSize: 10
        property string debugTextProp: "debugText1!!"
        text: debugTextProp
    }*/

    /** Container to give "flicking" access to "detailed view" on "CDPObjects" */
    Flickable {
        id: signalFlickable
        contentHeight: parent.height

        /** Governs if the "details view" will be displayd on screen dependant on orientation */
        contentWidth: (Screen.primaryOrientation === Qt.PortraitOrientation) ? parent.width*2 : parent.width

        contentX: 0
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        interactive: true
        clip: true

        /** Make sure no middle state of showing details */
        onMovementEnded: {
            signalFlickable.state = '';
            if(signalFlickable.contentX < parent.width*0.5)
                signalFlickable.state = "initState";
            else
                signalFlickable.state = "detailView";
        }

        /** Make sure the "flickable" is in the right state after creation */
        Component.onCompleted: {
            signalFlickable.state = "initState";
        }

        /** Container to hold all items for the "simple list" for Messages */
        Rectangle {
            id:co
            width: parent.width/2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            gradient: Gradient {
                    GradientStop {position: 0.0; color: "#666666"}
                    GradientStop {position: 1.0; color: "#000000"}
                    }
            /*Debug text
            Text{
                id: debugText2
                z:2
                anchors.centerIn: parent
                text: "debugText2 : \nActiveItemName : "+m_sActiveItemName
                color: "#ffffff"
                font.pointSize: 10
            }*/

            /** Delegate behavior for the message CDPObjects */
            Component {
                id: messageListDelegate
                Rectangle {
                    id: messageDelegate
                    height: componentMessage.height/11
                    width: parent.width
                    color: "transparent"
                    border.color: "#808080"
                    focus: true

                    signal sigDelegateClicked(int delegateIndex)

                    Component.onCompleted: {
                        //console.log(messageName+" loaded!")
                        sigDelegateClicked.connect(signalInputList.delegateClicked)
                    }

                    /** Layout to arrange "shortname", "messageDescriotion" */
                    Column {
                        id: column_1
                        width: parent.width*0.70
                        spacing: 2

                        Text {
                            id: messageShortName
                            text: model.messageName
                            anchors.left: parent.left
                            anchors.right: parent.right
                            focus:false
                            anchors.leftMargin: 10
                            font.bold: true
                            color: "#ffffff"
                            font.pointSize: 12

                            MouseArea {
                              id: mouse_area1
                              hoverEnabled: false
                              anchors.fill: parent

                              onClicked:{
                                  messageDelegate.forceActiveFocus()
                                  messageDelegate.sigDelegateClicked(index)
                              }
                            }
                        }

                        Text {
                            id: signalDescription
                            text: model.messageDescription
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 10
                            focus: false
                            font.bold: true
                            color: "#dddddd"
                            font.pointSize: 8
                            wrapMode: "WordWrap"

                            MouseArea {
                              id: mouse_area2
                              hoverEnabled: false
                              anchors.fill: parent

                              onClicked: {
                                  messageDelegate.forceActiveFocus()
                                  messageDelegate.sigDelegateClicked(index)
                              }
                            }
                        }
                    }//End Column

                    /** Layout to arrange "Send button", "messageCommand" */
                    Column {
                        anchors.right: parent.right
                        width: parent.width/4
                        height: parent.height/2
                        anchors.margins: 5

                        /** Button to send a message to CDP controller state machine. */
                        Button {
                            text: qsTr("Send")

                            /** Builds a string from the delegate to send a http request to the state machine. */
                            onClicked: {
                                var http = new XMLHttpRequest()
                                var params = m_sActiveCompPath +"?Message="+ messageShortName.text;
                                var url = m_sCompUrl +params;
                                http.open("GET", url, true);

                                // Send the proper header information along with the request
                                http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                                http.setRequestHeader("Content-length", params.length);

                                http.onreadystatechange = function() { // Call a function when the state changes.
                                    if (http.readyState == 4) {
                                        if (http.status == 200) {
                                            console.log("ok")
                                        } else {
                                            console.log("error: " + http.status)
                                        }
                                    }
                                }
                                http.send(params);
                            }
                        }

                        Text {
                            focus: false
                            font.bold: true
                            color: "#dddddd"
                            font.pointSize: 8
                            text: model.messageCommand
                        }
                    }


                }//End Rectangle messageDelegate
            }//End Component messageListDelegate

            /** Sets the style an Behavior of the highlight component. */
            Component {
                id: highlightComp
                Rectangle {
                    id: highlightRect
                    width: parent.width // height: 40
                    color: "white"; radius: 5
                    opacity: 0.2
                    y: signalInputList.currentItem.y

                    Behavior on y {
                        SpringAnimation {
                            spring: 3
                            damping: 0.2
                        }
                    }
                }
            }

            /** Container for the header of the list.*/
            Rectangle{
                id: headerRect
                width: parent.width
                height: 30
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                color: "transparent"
                border.color: "black"


                Rectangle {
                    id: headerRectColumn1
                    width: parent.width
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: "transparent"
                    border.color: "black"
                    Text {
                        color: "white"
                        font.pointSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 8

                        text: "Message to state machine: "
                    }
                }


            }//End HeaderRect

            /** The list displaying elements. */
            ListView {
                id: signalInputList
                anchors.top: headerRect.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                snapMode: ListView.SnapToItem
                clip: true
                model: messageModelXml
                delegate: messageListDelegate
                highlight: highlightComp


                signal delegateClicked(int indexNr)

                /*Debug text
                Component.onCompleted: {
                    debugText1.debugTextProp = "List loaded and got access to debug text"
                }*/

                onDelegateClicked: {
                    debugText1.debugTextProp = indexNr
                    currentIndex = indexNr
                }

                //TODO: Implement Binding to avoid error on first call
                onCurrentIndexChanged: {
                    m_sActiveItemName = model.messageName
                }
            }//End ListView
        }//End Rectangle

        /** Container for the "detailed view" */
        Rectangle {
            id: detailRect
            x: parent.width/2 +1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: co.right

            Text {
                id: debugText3
                z:2
                anchors.centerIn: parent
                font.pointSize: 14
                color: "black"

                text: "DebugText3\nPath   : " + m_sActiveCompPath + "\nSignal : " + m_sActiveItemName
            }

            Image {
                id: underConstruction
                z:1
                anchors.fill: parent
                //anchors.centerIn: parent
                source: "../pics/logo.png"
            }

            Loader {
                id: detailLoader
                //sourceComponent: detailSignalList
            }
        }

        states: [
            State {
                name: "initState"
                PropertyChanges { target: signalFlickable ; contentX: 0}
            },
            State {
                name: "detailView"
                PropertyChanges { target: signalFlickable ; contentX: parent.width}
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
    }//End Flickable
}//End Item componentMessage
