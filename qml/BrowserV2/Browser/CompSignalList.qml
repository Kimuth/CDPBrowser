import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.0
import QtQuick.Window 2.1
import QtQuick.XmlListModel 2.0

/**
  * File: CompSignalList.qml
  *
  * The sub-type for "Signals".
  *
  * Connects to the CDP controller->CDPcomponent->CDPmembers to retrieve its CDPObjects.
  *
*/

Item {
    id:mainListRect

    property string m_sCompUrl          : ""        ///< Contains Url to CDP component
    property string m_sActiveCompPath   : ""        ///< Contains full path to active component.
    property string m_sActiveItemName   : ""        ///< Contains short name of active component.
    property bool isInput : false                   ///< Used to divide signals in to inputs and outputs.

    property alias m_aUpdatingXml    : updateTimer.running  ///< Indicates if the timer is running
    property alias m_aUpdateInterval : updateTimer.interval ///< Interval of timer in ms.

    /** Timer item to controll updating of CDPObject key values*/
    Item {
        Timer {
            id: updateTimer
            interval: 1000
            running: false
            repeat: true

            onTriggered: signalModelXml.reload()
        }
    }

    /** Model retrieving data from the controller for each CDPObject */
    XmlListModel {
        id: signalModelXml
        source: m_sCompUrl + m_sActiveCompPath + ".xml"
        query: "/Component/Signals/Signal"

        XmlRole {
            name: "signalName"
            query: "@Name/string()"
            //isKey: true
        }
        XmlRole {
            name: "signalDescription"
            query: "@Description/string()"
            //isKey: true
        }
        XmlRole {
            name: "signalValue"
            query: "@Value/string()"
            isKey: true
        }
        XmlRole {
            name: "signalIsInput"
            query: "@Input/number()"
        }

        /** Implemented to fill a listmodel with only inputs or ouputs.*/
        //TODO: Implement another way of filling listmodel, model selection is reset each update!!
        //      Consider "WorkerScript".
        onStatusChanged: {
            //console.log("COMPSIGNALLIST XML MODEL STATUS CHANGED!")
            if (status == XmlListModel.Ready)
            {
                var item
                //console.log("COMPSIGNALLIST XML MODEL STATUS CHANGED TO rdy!")
                signalModel.clear()
                for (var i=0; i<count; i++)
                {
                    item = get(i)
                    if(item.signalIsInput == isInput)
                    {
                        //console.log(item.signalName + " is added to signalModel " + isInput)
                        signalModel.append({signalName:         item.signalName,
                                           signalDescription:   item.signalDescription,
                                           signalValue:         item.signalValue,
                                           signalIsInput:       item.signalIsInput})
                    }
                }
                if(isInput)
                    console.log("Updating innput Tab!")
                else
                    console.log("Updating output Tab!")
            }

        }

    }

    /** List model to keep selected inputs or outputs */
    ListModel {
        id: signalModel
    }

    /** Delegate behavior for the signal CDPObjects */
    Component {
        id: signalListDelegate
        Rectangle {
            id: signalDelegate
            height: componentSignal.height/11
            width: parent.width
            color: "transparent"
            border.color: "#808080"
            focus: true

            signal sigValueChanged(string sigName,string sigValue)  ///< Signal emited when value changed.
            signal sigDelegateClicked(int delegateIndex)            ///< Signal emited when delegate is clicked.

            /** Connects local signals to member signals .*/
            Component.onCompleted: {
                sigValueChanged.connect(s_ValueChanged)
                sigDelegateClicked.connect(signalInputList.delegateClicked)
            }

            /** Layout to arrange "shortname", "description"*/
            //TODO: Might need to adjust what is the mouse area, column do not support filling with MouseArea.
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
                    wrapMode: "WordWrap"

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

            /** Container for "input" visuals and logic */
            Rectangle {
                id: inputTextRect
                width: parent.width/4
                height: parent.height/2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                anchors.margins: 5

                //TODO: this can not interfere with input "IF(!inputMethodeComposing)"
                TextInput {
                    id: signalValueField
                    anchors.fill: parent
                    font.pointSize: 10
                    color: "#000000"
                    focus: false
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    text: signalValue

                    /** Ensures only number values are entered to signals values */
                    validator: DoubleValidator {

                    }

                    /** Implemented to make the text selected by default when field is selected*/
                    onActiveFocusChanged: {
                        if(activeFocus){
                            signalValueField.selectAll()
                            signalDelegate.sigDelegateClicked(index)
                        }
                        else {
                            signalValueField.deselect()
                            Qt.inputMethod.hide()
                        }

                    }

                    /** After text is confirmed done edited, creates a URL to update the CDP controller */
                    onAccepted: {
                        signalDelegate.sigValueChanged(signalShortName.text,signalValueField.text)
                        signalValueField.deselect()
                        signalDelegate.forceActiveFocus()
                        Qt.inputMethod.hide()

                        var http = new XMLHttpRequest()
                        var params = m_sActiveCompPath
                                    + ".xml?Message=SetSignal&SignalName="
                                    + signalShortName.text
                                    + "&SignalValue="
                                    + signalValueField.text;
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
        /*
        Rectangle {
            id: headerRectColumn3
            x: parent.width/2
            width: parent.width/4
            height: parent.height
            anchors.top: parent.top
            anchors.left: headerRectColumn2.right
            anchors.right: parent.right
            color: "transparent"
            border.color: "black"
            //border.width: 3
            Text {
                color: "white"
                font.pointSize: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 8

                text: "Options :"
            }
        }
        */
    }//End HeaderRect

    /** Display element for signal list*/
    ListView {
        id: signalInputList
        anchors.top: headerRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        snapMode: ListView.SnapToItem
        clip: true
        model: signalModel
        delegate: signalListDelegate
        highlight: highlightComp

        signal delegateClicked(int indexNr)     ///< Signal emits when a delegate is clicked.

        /** Implemented to set current index when clicking a delegate, not using keyboard. */
        onDelegateClicked: {
            //debugText1.debugTextProp = indexNr
            currentIndex = indexNr
        }

        /** Implemented to update CDPMemeber active signal property */
        //TODO: Implement Binding to avoid error on first call
        onCurrentIndexChanged: {
            m_sActiveItemName = model.signalName
        }
    }//End ListView
}//End Item
