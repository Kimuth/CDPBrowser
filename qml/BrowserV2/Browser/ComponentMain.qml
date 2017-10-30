import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.0

/**
  * File: ComponentMain.qml
  *
  * The type for "main view".
  *
  * Connects to the CDP controller->component to retrieve its CDPmembers.
  * Displays the CDPmembers.
*/

Rectangle {
    id: compMain
    implicitWidth: 480
    implicitHeight: 800
    color: "#333333"

    property string m_sCompUrl        : ""
    property string m_sActiveCompPath : ""

    /** After component is created loads the source for all tabs */
    Component.onCompleted: {
        sig.setSource   ("CompSignal.qml",      {"m_sCompUrl"           :m_sCompUrl,
                                                 "m_sActiveCompPath"    :m_sActiveCompPath})
        cdpSig.setSource("CompCDPSignal.qml",   {"m_sCompUrl"           :m_sCompUrl,
                                                 "m_sActiveCompPath"    :m_sActiveCompPath})
        parameters.setSource("CompParameter.qml",{"m_sCompUrl"          :m_sCompUrl,
                                                  "m_sActiveCompPath"   :m_sActiveCompPath})
        alarms.setSource("CompAlarm.qml",       {"m_sCompUrl"           :m_sCompUrl,
                                                 "m_sActiveCompPath"    :m_sActiveCompPath})
        messages.setSource("CompMessage.qml",   {"m_sCompUrl"           :m_sCompUrl,
                                                 "m_sActiveCompPath"    :m_sActiveCompPath})
    }

    TabView {
        id: myTabView
        currentIndex: 0
            anchors.fill: parent
            //anchors.margins: 4

            /** Binding each tabs UpdatingXml property after tab source is loaded to avoid errors */
            Binding {
                target: sig.item
                property: "m_bUpdatingXml"
                value: sig.updateXmlSig
                when: sig.status == Loader.Ready
            }
            Binding {
                target: cdpSig.item
                property: "m_aUpdatingXml"
                value: cdpSig.updateXmlCdpSig
                when: cdpSig.status == Loader.Ready
            }
            Binding {
                target: parameters.item
                property: "m_aUpdatingXml"
                value: parameters.updateXmlParam
                when: parameters.status == Loader.Ready
            }
            Binding {
                target: alarms.item
                property: "m_aUpdatingXml"
                value: alarms.updateXmlAlarms
                when: alarms.status == Loader.Ready
            }

            /** Each tab is initialized with default values and no source*/
            Tab {
                id: sig
                title: "Signals"
                asynchronous: false
                active: myTabView.currentIndex==0 ? true : false
                visible: myTabView.currentIndex==0 ? true : false

                /** Property to only make the source update from controller if its active*/
                property bool updateXmlSig : myTabView.currentIndex==0 ? true : false
            }
            Tab {
                id: cdpSig
                title: "CDPSignals"
                active: myTabView.currentIndex==1 ? true : false
                visible: myTabView.currentIndex==1 ? true : false

                /** Property to only make the source update from controller if its active*/
                property bool updateXmlCdpSig : myTabView.currentIndex==1 ? true : false
            }
            Tab {
                id: parameters
                title: "Parameters"
                active: myTabView.currentIndex==2 ? true : false
                visible: myTabView.currentIndex==2 ? true : false

                /** Property to only make the source update from controller if its active*/
                property bool updateXmlParam : myTabView.currentIndex==2 ? true : false
            }
            Tab {
                id: alarms
                title: "Alarms"
                active: myTabView.currentIndex==3 ? true : false
                visible: myTabView.currentIndex==3 ? true : false

                /** Property to only make the source update from controller if its active*/
                property bool updateXmlAlarms : myTabView.currentIndex==3 ? true : false
            }
            Tab {
                id: messages
                title: "Messages"
                active: myTabView.currentIndex==4 ? true : false
                visible: myTabView.currentIndex==4 ? true : false
            }

            style: TabViewStyle {
                frameOverlap: 0
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
                    border.color:  "black"
                    implicitWidth: myTabView.width/5 //Math.max(text.width + 16)
                    implicitHeight: compMain.height/11

                    Text {
                        id: text
                        anchors.centerIn: parent
                        text: styleData.title
                        color: styleData.selected ? "red" : "white"
                        font.pointSize: 13
                    }
                }
                frame: Rectangle {
                    id: placeHolder
                    color: "#333333"

                    /** Image to illustrate loading while the frame is not filled */
                    //TODO: Need review of functionality.
                    AnimatedImage{
                        id: loading
                        width: 200
                        height: 200
                        anchors.centerIn: parent
                        source: "../pics/loading2.gif"
                        visible: true
                    }
                }
            }//End of tab styling
    }//End of tabView
}//End of compMain
