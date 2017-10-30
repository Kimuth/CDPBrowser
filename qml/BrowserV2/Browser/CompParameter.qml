import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.0
import QtQuick.Window 2.1
import QtQuick.XmlListModel 2.0

/**
  * File: CompParameter.qml
  *
  * The sub-type for "main view".
  *
  * Connects to the CDP controller->CDPcomponent->CDPmembers to retrieve its CDPObjects.
  * Displays the CDPObjects PARAMETER.
*/


Item {
    id: componentParameter
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
        parameterFlickable.state = "initState"
    }

    /** Timer item to controll updating of CDPObject key values*/
    Item {
        Timer {
            id: updateTimer
            interval: 1000
            running: false
            repeat: true

            onTriggered: paramModelXml.reload()
        }
    }

    /** Model retrieving data from the controller for each CDPObject */
    XmlListModel {
        id: paramModelXml
        source: m_sCompUrl + m_sActiveCompPath + ".xml"
        query: "/Component/Parameters/Parma"

        XmlRole {
            name: "paramName"
            query: "@ShortName/string()"
        }
        XmlRole {
            name: "paramDescription"
            query: "@Description/string()"
        }
        XmlRole {
            name: "paramValue"
            query: "@Value/number()"
            isKey: true
        }

        onStatusChanged: {
            if (status == XmlListModel.Ready)
            {
                console.log("Parameter Tab Updating!")
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
        id: parameterFlickable
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
            parameterFlickable.state = '';
            if(parameterFlickable.contentX < parent.width*0.5)
                parameterFlickable.state = "initState";
            else
                parameterFlickable.state = "detailView";
        }

        /** Make sure the "flickable" is in the right state after creation */
        Component.onCompleted: {
            parameterFlickable.state = "initState";
        }

        /** Container to hold all items for the "simple list" for Parameters */
        Rectangle {
            id:mainListRect
            width: parent.width/2
            height: parent.height/2
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

            /** Delegate behavior for the parameter CDPObjects */
            Component {
                id: parameterListDelegate
                Rectangle {
                    id: parameterDelegate
                    height: 60
                    width: parent.width
                    color: "transparent"
                    border.color: "#808080"
                    focus: true

                    signal sigValueChanged(string sigName,string sigValue)
                    signal sigDelegateClicked(int delegateIndex)

                    Component.onCompleted: {
                        sigValueChanged.connect(s_ValueChanged)
                        sigDelegateClicked.connect(signalInputList.delegateClicked)
                    }

                    /** Layout to arrange "shortname", "description" */
                    Column {
                        id: column_1
                        width: parent.width*0.5
                        spacing: 2

                        Text {
                            id: parameterShortName
                            text: model.paramName
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
                                  parameterDelegate.forceActiveFocus()
                                  parameterDelegate.sigDelegateClicked(index)
                              }
                            }
                        }

                        Text {
                            id: parameterDescription
                            text: model.paramDescription
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 10
                            focus: false
                            font.bold: true
                            color: "#dddddd"
                            font.pointSize: 8
                            wrapMode: "WordWrap" //TextEdit.WordWrap

                            MouseArea {
                              id: mouse_area2
                              hoverEnabled: false
                              anchors.fill: parent

                              onClicked: {
                                  parameterDelegate.forceActiveFocus()
                                  parameterDelegate.sigDelegateClicked(index)
                              }
                            }
                        }
                        }//End Column

                    /** Container for input text */
                    Rectangle {
                        id: inputTextRect
                        width: parent.width/4
                        height: parent.height/2
                        anchors.left: column_1.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#ffffff"

                        //TODO: this can not interfere with input "IF(!inputMethodeComposing)"
                        TextInput {
                            id: signalValue
                            anchors.fill: parent
                            font.pointSize: 10
                            color: "#000000"
                            focus: false
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            text: model.paramValue

                            /** Implemented to make the text selected by default when field is selected*/
                            onActiveFocusChanged: {
                                if(activeFocus){
                                    signalValue.selectAll()
                                    parameterDelegate.sigDelegateClicked(index)
                                }
                                else {
                                    signalValue.deselect()
                                    Qt.inputMethod.hide()
                                }

                            }

                            /** After text is confirmed done edited, create a url string to update the CDP controller */
                            onAccepted: {
                                parameterDelegate.sigValueChanged(parameterShortName.text,signalValue.text)
                                signalValue.deselect()
                                parameterDelegate.forceActiveFocus()
                                Qt.inputMethod.hide()

                                var http = new XMLHttpRequest()
                                var params = m_sActiveCompPath
                                            + "?Message=SetParma&ParmaName="
                                            + parameterShortName.text
                                            + "&ParmaValue="
                                            + signalValue.text;
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
                }//End Rectangle parameterDelegate
            }//End Component parameterListDelegate

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

                        text: "parameter name: "
                    }
                }
                Rectangle {
                    id: headerRectColumn2
                    x: parent.width/2
                    width: parent.width/3
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: headerRectColumn1.right
                    color: "transparent"
                    border.color: "black"
                    Text {
                        color: "white"
                        font.pointSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 8

                        text: "Value :"
                    }
                }
                Rectangle {
                    id: headerRectColumn3
                    x: parent.width/3 + parent.width/3
                    width: parent.width/3
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: headerRectColumn2.right
                   // anchors.right: parent.right
                    color: "transparent"
                    border.color: "black"
                    //border.width: 3
                    Text {
                        color: "white"
                        font.pointSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.margins: 8

                        text: "Unit:"
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
                model: paramModelXml
                delegate: parameterListDelegate
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

                onCurrentIndexChanged: {
                    m_sActiveItemName = model.paramName
                }
            }//End ListView
        }//End Item

        /** Container for the "detailed view" */
        Rectangle {
            id: detailRect
            x: parent.width/2 +1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: mainListRect.right

            Text {
                id: debugText277
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
                PropertyChanges { target: parameterFlickable ; contentX: 0}
            },
            State {
                name: "detailView"
                PropertyChanges { target: parameterFlickable ; contentX: parent.width}
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

}//End Item componentParameter
