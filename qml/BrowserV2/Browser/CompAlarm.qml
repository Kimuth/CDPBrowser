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
  * Displays the CDPObjects ALARMS.
*/

Item {
    id: componentSignal
    implicitWidth: 480
    implicitHeight: 800
    anchors.fill: parent

    property string m_sCompUrl          : ""                ///< Contains Url to CDP component
    property string m_sActiveCompPath   : ""                ///< Contains full path to active component.
    property string m_sActiveItemName   : ""                ///< Contains short name of active component.

    property alias m_aUpdatingXml    : updateTimer.running  ///< Indicates if the timer is running
    property alias m_aUpdateInterval : updateTimer.interval ///< Interval of timer in ms.


    signal s_ValueChanged(string signalName, string strValue)   ///< Signal to emit value of CDPObject changed
    signal s_ActiveSigChanged(string currSignalName)            ///< Signal to emit change in active CDPObject.

    /*Debug text
    onS_ValueChanged: {
        debugText1.debugTextProp = "Signal : "+ signalName + "\nValue : "+ strValue
    }*/

    Component.onCompleted: {
        signalFlickable.state = "initState"
    }

    /** Timer item to controll updating of CDPObject key values*/
    Item {
        Timer {
            id: updateTimer
            interval: 1000
            running: false
            repeat: true

            onTriggered: alarmModelXml.reload()
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

    /** Model retrieving data from the controller for each CDPObject */
    XmlListModel {
        id: alarmModelXml
        source: m_sCompUrl + m_sActiveCompPath + ".xml"
        query: "/Component/Alarms/Alarm"

        XmlRole {
            name: "alarmName"
            query: "@ShortName/string()"
        }
        XmlRole {
            name: "alarmDescription"
            query: "@Text/string()"
        }
        XmlRole {
            name: "alarmState"
            query: "@Status/string()"
            isKey: true
        }
        XmlRole {
            name: "alarmLevel"
            query: "@Level/string()"
        }
        XmlRole {
            name: "alarmTimeStamp"
            query: "@TimeStamp/string()"
        }


        onStatusChanged: {

            if (status == XmlListModel.Ready)
            {
                console.log(qsTr("Alarm Tab Updating!"))
            }
        }
    }

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

        /** Container to hold all items for the "simple list" for Alarms */
        Rectangle {
            id:mainListRect
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
                text: m_sActiveItemName
                color: "#ffffff"
                font.pointSize: 10
            }*/

            /** Delegate behavior for the alarm CDPObjects */
            Component {
                id: alarmListDelegate
                Rectangle {
                    id: signalDelegate
                    height: componentSignal.height/9
                    width: parent.width
                    color: "transparent"
                    border.color: "#808080"
                    focus: true

                    signal sigDelegateClicked(int delegateIndex)    ///< Signal emited when a delegate is clicked.

                    Component.onCompleted: {
                        sigDelegateClicked.connect(signalInputList.delegateClicked)
                    }

                    /** Layout to arrange "shortname", "alarmLevelText" and "signalTime" */
                    Column {
                        id: column_1
                        width: parent.width/2
                        spacing: 2

                        Text {
                            id: signalShortName
                            text: model.alarmName

                            font.bold: true
                            color: "#ffffff"
                            font.pointSize: 12

                            MouseArea {
                                id: mouse_area1
                                hoverEnabled: false
                                anchors.fill: parent

                                onClicked:{
                                    signalDelegate.forceActiveFocus()
                                    signalDelegate.sigDelegateClicked(index)
                                }
                            }
                        }
                        Text {
                            id: alarmLevelText
                            font.bold: true
                            color: "#dddddd"
                            font.pointSize: 8
                            text: model.alarmLevel
                            MouseArea {
                                id: mouse_area3
                                hoverEnabled: false
                                anchors.fill: parent

                                onClicked: {
                                    signalDelegate.forceActiveFocus()
                                    signalDelegate.sigDelegateClicked(index)
                                }
                            }
                        }
                        Text {
                            id: signalTime
                            text: model.alarmTimeStamp
                            font.bold: true
                            color: "#dddddd"
                            font.pointSize: 8

                            MouseArea {
                                id: mouse_area2
                                hoverEnabled: false
                                anchors.fill: parent

                                onClicked: {
                                    signalDelegate.forceActiveFocus()
                                    signalDelegate.sigDelegateClicked(index)
                                }
                            }
                        }




                    }//End Column

                    /** Text displays the active status text of the alarm */
                    Text {
                        id: alarmStatusText
                        anchors.left: column_1.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 5
                        width: (parent.width/2)/2
                        focus: false
                        font.bold: true
                        color: "#ffffff"
                        font.pointSize: 12
                        text: model.alarmState

                    }

                    /** Button to send a message to acknowledge any active alarms */
                    //TODO: Does not work atm, might need to update alarm name to meet url requirements. (%20)
                    Button {
                        id: ackButton
                        text: "Ack"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 5

                        /** Builds a string from the delegate to send a http request for acknowledgement to a "CDP controller */
                        onClicked: {
                            var http = new XMLHttpRequest()
                            var params = m_sActiveCompPath
                                        + "?Message=AcknowledgeAlarm&AlarmName="
                                        + m_sActiveItemName;
                            var url = m_sCompUrl+params;
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


                }//End Rectangle signalDelegate
            }//End Component alarmListDelegate

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
                    width: parent.width/2
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: parent.left
                    color: "transparent"
                    border.color: "black"
                    Text {
                        color: "white"
                        font.pointSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 8

                        text: "Alarm name: "
                    }
                }
                Rectangle {
                    id: headerRectColumn2
                    //x: parent.width/2
                    width: parent.width/2
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: headerRectColumn1.right
                    anchors.right: parent.right
                    color: "transparent"
                    border.color: "black"
                    Text {
                        color: "white"
                        font.pointSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 8

                        text: "Status:"
                    }
                }
            }//End HeaderRect

            /** The list displaying element */
            ListView {
                id: signalInputList
                anchors.top: headerRect.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                snapMode: ListView.SnapToItem
                clip: true
                model: alarmModelXml
                delegate: alarmListDelegate
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
            anchors.left: mainListRect.right

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
}//End Item componentSignal
