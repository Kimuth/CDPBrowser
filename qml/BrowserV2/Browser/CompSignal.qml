import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.0
import QtQuick.Window 2.1
import QtQuick.XmlListModel 2.0

/**
  * File: CompSignal.qml
  *
  * The sub-type for "main view".
  *
  * Container type for the CDPObjects SIGNALS provided by CompSignalList.qml
*/

Item {
    id: componentSignal
    implicitWidth: 480
    implicitHeight: 800
    anchors.fill: parent

    property string m_sCompUrl          : ""        ///< Contains Url to CDP component
    property string m_sActiveCompPath   : ""        ///< Contains full path to active component.
    property string m_sActiveItemName   : ""        ///< Contains short name of active component.

    property bool m_bUpdatingXml    : true          ///< Indicates if the timer is running
    property int  m_nUpdateInterval : 1000          ///< Interval of timer in ms.


    signal s_ValueChanged(string signalName, string strValue)   ///< Signal to emit value of CDPObject changed
    signal s_ActiveSigChanged(string currSignalName)            ///< Signal to emit change in active CDPObject.

    /** Sets the current signal tab to update its CDPObjects */
    onM_bUpdatingXmlChanged: {
        signalTab.getTab(signalTab.currentIndex).item.m_aUpdatingXml = m_bUpdatingXml
    }

    /*Debug text
    onS_ValueChanged: {
        //debugText1.debugTextProp = "Signal : "+ signalName + "\nValue : "+ strValue
    }*/

    /** Make sure the "Flickable" is in right state afther creation.*/
    Component.onCompleted: {
        signalFlickable.state = "initState"
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

        /** Visual element to devide "input" from "output" */
        TabView {
            id: signalTab
            width: parent.width/2
            height: parent.height
            currentIndex: 0

            /** Implemented to get correct active item when tab selection changes */
            onCurrentIndexChanged: {
                m_sActiveItemName = signalTab.getTab(currentIndex).item.m_sActiveItemName
            }

            /** Initiates the sources for "input" and "output" */
            Component.onCompleted: {
                inn.setSource("CompSignalList.qml", {"m_sCompUrl" :m_sCompUrl,
                                                     "m_sActiveCompPath":m_sActiveCompPath,
                                                     "m_sActiveItemName":"Tryed to load inn",
                                                     "isInput":true /*,"m_aUpdatingXml":true*/})
                out.setSource("CompSignalList.qml", {"m_sCompUrl" :m_sCompUrl,
                                                     "m_sActiveCompPath":m_sActiveCompPath,
                                                     "m_sActiveItemName":"Tryed to load out",
                                                     "isInput":false})
            }

            /** Binding each tabs UpdatingXml property after tab source is loaded to avoid errors */
            Binding {
                target: inn.item
                property: "m_aUpdatingXml"
                value: inn.updateXmlInn
                when: inn.status == Loader.Ready
            }
            Binding {
                target: out.item
                property: "m_aUpdatingXml"
                value: out.updateXmlOut
                when: out.status == Loader.Ready
            }

            /** Initiates the Tabs for the view, without sources */
            Tab {
                id: inn
                title: qsTr("Input")
                anchors.fill: parent
                asynchronous: true
                active: true
                visible: signalTab.currentIndex == 0 ? true : false

                property bool updateXmlInn : signalTab.currentIndex==0 ? true : false

                onLoaded: {

                    //inn.item.m_aUpdatingXml = updateXmlInn
                    inn.item.m_aUpdateInterval = m_nUpdateInterval
                }


            }//End Input

            Tab {
                id: out
                title: qsTr("Output")
                anchors.fill: parent
                asynchronous: true
                active: true
                visible: signalTab.currentIndex === 1 ? true : false

                property bool updateXmlOut : signalTab.currentIndex==1 ? true : false

                onLoaded: {
                    out.item.m_aUpdateInterval = m_nUpdateInterval
                }

            }//End Output

            style: TabViewStyle {
                frameOverlap: 0
                //leftCorner: Item { implicitWidth: 12 }
                tab: Rectangle {
                    color: "#30ffffff"
                    gradient: styleData.selected ? grad2 : grad
                        Gradient {
                            id: grad
                            GradientStop {position: 0.0; color: "#666666"}
                            GradientStop {position: 1.0; color: "#000000"}
                            }
                        Gradient {
                            id: grad2
                            GradientStop {position: 0.0; color: "#30ffffff"}
                            GradientStop {position: 0.8; color: "#000000"}
                            }
                    border.color:  "black" //"steelblue"
                    implicitWidth: signalTab.width/2 //Math.max(text.width + 4, 80)
                    implicitHeight: componentSignal.height/11
                    //radius: 10

                    Text {
                        id: text
                        anchors.centerIn: parent
                        text: styleData.title
                        color: styleData.selected ? "red" : "white"
                        font.pointSize: 13
                    }
                }
                frame: Rectangle {
                    gradient: Gradient {
                            GradientStop {position: 0.0; color: "#666666"}
                            GradientStop {position: 1.0; color: "#000000"}
                            }
                }
            }
        }//End TabView

        /** Container for the "detailed view" */
        Rectangle {
            id: detailRect
            x: parent.width/2 +1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: signalTab.right

            Text {
                id: debugText2
                z:2
                anchors.centerIn: parent
                font.pointSize: 14
                color: "black"

                text: "DebugText2\nPath   : "
                      + m_sActiveCompPath
                      + "\nSignal : " + m_sActiveItemName
                      + "\nUrl    : " + m_sCompUrl
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
