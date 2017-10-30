import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.0
import QtQuick.Window 2.1
import QtQuick.XmlListModel 2.0

/**
  * File: CompCDPSignal.qml
  *
  * The sub-type for "main view".
  *
  * Connects to the CDP controller->CDPcomponent->CDPmembers to retrieve its CDPObjects.
  * Displays the CDPObjects CDPSIGNAL.
  *
  * NOTE: No CDP controller with this CDPMember available during the project.
*/
//TODO: Need to make it like signal list , as this is a newer version of the same CDPMember type.

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

            onTriggered: cdpSigModelXml.reload()
        }
    }

    /** Model retrieving data from the controller for each CDPObject */
    XmlListModel {
        id: cdpSigModelXml
        source: m_sCompUrl + m_sActiveCompPath + ".xml"
        query: "/Component/CDPSignals/CDPSignal"

        XmlRole {
            name: "signalName"
            query: "@Name/string()"
        }
        XmlRole {
            name: "signalDescription"
            query: "@Description/string()"
        }
        XmlRole {
            name: "signalValue"
            query: "@Value/string()"
            isKey: true
        }
//        XmlRole {
//            name: "signalIsInput"
//            query: "@Input/number()"
//        }

        onStatusChanged: {
            if (status == XmlListModel.Ready)
            {
                //cdpSigModel.clear()
//                for (var i=0; i<count; i++)
//                {
//                    var item = get(i)

//                    if(item.signalIsInput == isInput)
//                    {
//                        console.log(item.signalName + " is added to signalModel " + isInput)
//                        cdpSigModel.append({signalName:         item.signalName,
//                                           signalDescription:   item.signalDescription,
//                                           signalValue:         item.signalValue})
//                    }
//                }
                console.log("CDPSignal Tab Updating!")
            }
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

        /** Container to hold all items for the "simple list" for CDPSignals */
        Rectangle {
            id: mainListRect
            width : parent.width/2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            gradient: Gradient {
                GradientStop {position: 0.0; color: "#666666"}
                GradientStop {position: 1.0; color: "#000000"}
                }


            Text{
                id: debugText2
                z:2
                anchors.centerIn: parent
                text: m_sActiveItemName
                color: "#ffffff"
                font.pointSize: 10
            }

            ListModel {
                id: cdpSigModel

            }//End ListModel sigListModel

            /** Delegate behavior for the CDPSignal CDPObjects */
            Component {
                id: signalListDelegate
                Rectangle {
                    id: signalDelegate
                    height: componentSignal.height/11
                    width: parent.width
                    color: "transparent"
                    border.color: "#808080"
                    focus: true

                    property string sigDelegateName : model.signalName

                    signal sigValueChanged(string sigName,string sigValue)
                    signal sigDelegateDetailRequest()
                    signal sigDelegateClicked(int delegateIndex)

                    Component.onCompleted: {
                        sigValueChanged.connect(s_ValueChanged)
                        sigDelegateClicked.connect(signalInputList.delegateClicked)
                        sigDelegateDetailRequest.connect(signalInputList.delegateDetailRequest)
                    }

                    Column {
                        id: column_1
                        width: parent.width*0.5
                        spacing: 2

                        Text {
                            id: signalShortName
                            text: model.signalName
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
                                  signalDelegate.forceActiveFocus()
                                  signalDelegate.sigDelegateClicked(index)
                              }

                              onDoubleClicked: {
                                  signalDelegate.sigDelegateDetailRequest()
                              }
                            }
                        }

                        Text {
                            id: signalDescription
                            text: model.signalDescription
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 10
                            focus: false
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
                              onDoubleClicked: {
                                  signalDelegate.sigDelegateDetailRequest()
                              }
                            }
                        }

                        }//End Column

                        Rectangle {
                            id: inputTextRect
                            width: parent.width/4
                            height: parent.height/2
                            //anchors.left: column_1.right
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#ffffff"
                            anchors.margins: 5

                            // This need functionality to get value from xml or CDPApi,
                            // this can not interfere with input "IF(!inputMethodeComposing)"
                            TextInput {
                                id: cdpSignalValue
                                anchors.fill: parent
                                font.pointSize: 10
                                color: "#000000"
                                focus: false
                                horizontalAlignment: TextInput.AlignHCenter
                                verticalAlignment: TextInput.AlignVCenter

                                text: signalValue
                                validator: DoubleValidator {

                                }

                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        cdpSignalValue.selectAll()
                                        signalDelegate.sigDelegateClicked(index)
                                    }
                                    else {
                                        cdpSignalValue.deselect()
                                        Qt.inputMethod.hide()
                                    }

                                }

                                onAccepted: {
                                    signalDelegate.sigValueChanged(signalShortName.text,cdpSignalValue.text)
                                    cdpSignalValue.deselect()
                                    signalDelegate.forceActiveFocus()
                                    Qt.inputMethod.hide()

                                    var http = new XMLHttpRequest()
                                    var params = m_sActiveCompPath
                                                + ".xml?Message=SetSignal&SignalName="
                                                + signalShortName.text
                                                + "&SignalValue="
                                                + cdpSignalValue.text;
                                    var url = m_sCompUrl + params;
                                    http.open("GET", url, true);

                                    // Send the proper header information along with the request
                                    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                                    http.setRequestHeader("Content-length", params.length);
                                    //http.setRequestHeader("Connection", "close");

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
                        }//End inputTextRect
                }//End Rectangle signalDelegate
            }//End Component signalListDelegate

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
                    anchors.right: headerRectColumn2.left
                    color: "transparent"
                    border.color: "black"
                    Text {
                        color: "white"
                        font.pointSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 8

                        text: "Signal short name: "
                    }
                }
                Rectangle {
                    id: headerRectColumn2
                    x: parent.width/2
                    width: parent.width/4 + 5
                    height: parent.height
                    anchors.top: parent.top
                    //anchors.left: headerRectColumn1.right
                    anchors.right: parent.right
                    color: "transparent"
                    border.color: "black"
                    Text {
                        color: "white"
                        font.pointSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 8

                        text: "Signal Value :"
                    }
                }

            }//End HeaderRect


            ListView {
                id: signalInputList
                anchors.top: headerRect.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                snapMode: ListView.SnapToItem
                clip: true
                model: cdpSigModelXml
                delegate: signalListDelegate
                highlight: highlightComp


                signal delegateClicked(int indexNr)
                signal delegateDetailRequest()

                /*Debug text
                Component.onCompleted: {
                    debugText1.debugTextProp = "List loaded and got access to debug text"
                }*/

                onDelegateClicked: {

                    debugText1.debugTextProp = indexNr
                    currentIndex = indexNr
                }

                onDelegateDetailRequest: {
                    signalFlickable.state = "detailView";
                }

                onCurrentIndexChanged: {
                    //mainListRect.m_sActiveItemName = currentItem.sigDelegateName
                    m_sActiveItemName = currentItem.sigDelegateName
                }
            }//End ListView
        }//End Item


        Rectangle {
            id: detailRect
            x: componentSignal.width/2 +1
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

                text: "DebugText2\nPath   : " + m_sActiveCompPath + "\nSignal : " + m_sActiveItemName
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
