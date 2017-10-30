import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.1

/**
  * File: BrowserMain.qml
  *
  * The main entry point for qml to the Browser.
  * Contain functionality :
  *     - Choose type of controller (old or new)
  *     - Type URL of controller
  *     - Type user name
  *     - Type password
*/

Item {
    id: browserMain
    implicitHeight: 800
    implicitWidth: 480
    focus: true

    property string m_sCompUrl          : ""            ///< Contains Url to CDP component
    property string m_sUserName         : ""            ///< Contains User name
    property string m_sPassWd           : ""            ///< Contains Password
    property bool   m_bIsPreCdp4Release : true          ///< Contains Type of controller
    property alias  m_aBrowserSide      : flipable.side ///< Contains current side of flipable

    signal s_browserFlip()                             ///< Signal emited when flipped

    /** Implemented to use native application back function */
    Keys.onReleased: {
        if(event.key == Qt.key_Back){
            console.log("Back button captured - wunderbar !")
            if(flipable.side == Flipable.Back)
                flipable.flip
        }
    }

    onS_browserFlip: {
        flipable.flip()
    }

    /** Container to enable flipping between "connection page" and the "data view" */
    Flipable {
         id: flipable
         anchors.fill: parent

         property bool      flipped: false          ///< True if "back" is shown on flipable.
         property string    functionSelection : ""  ///< Contains string of qml type to show on "back"

         signal flip                                ///< Signal emited to flip

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
                 asynchronous: false
                 anchors.fill: parent

                 onLoaded: {
                     backLoad.item.focus = false
                }
             }
         }

         /** Set how the flipable wil transform from front to back */
         transform: Rotation {
             id: rotation
             origin.x: flipable.width/2
             origin.y: flipable.height/2
             axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
             angle: 0    // the default angle
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
    }// End Flipable

    /** Design of the front page of the flickable */
    Item {
        id: mainPage
        anchors.fill: parent

        signal buttonClicked                        ///< Signal to emit a button clicked on "mainPage"

        /** Top image for "connect view" */
        Image {
            id: mainBgPix
            source: "../pics/logo.png"
            height: parent.height/8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            focus: false
        }

        /** Container to house selection of controller type */
        Rectangle {
            id: versionRect
            height: parent.height/9
            anchors.top : mainBgPix.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: "transparent"
            border.color: "#888888"
            focus: false

            Text {
                text: qsTr("Select what version of controler to connect to :")
                anchors.top  : parent.top
                anchors.left : parent.left
                anchors.leftMargin: 15
                anchors.topMargin: 5
                font.pointSize: 10
                color: "white"
            }

            /** Layout for RadioButton*/
            Row {
                spacing: 15
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                /** Implemented to only be able to select one button option */
                ExclusiveGroup {
                    id: versionGroup

                    onCurrentChanged: {
                        if(current == btn1)
                            m_bIsPreCdp4Release = true
                        else
                            m_bIsPreCdp4Release = false
                    }
                }

                RadioButton {
                    id: btn1
                    text: qsTr("Pre. CDP 4.0 Release")
                    exclusiveGroup: versionGroup
                    checked: true
                    activeFocusOnTab: false
                    style: RadioButtonStyle {
                        indicator: Rectangle {
                            implicitWidth: 30
                            implicitHeight: 30
                            radius: 29
                            border.color: control.activeFocus ? "darkblue" : "gray"
                            border.width: 1
                            Rectangle {
                                anchors.fill: parent
                                visible: control.checked
                                color: "#555"
                                radius: 9
                                anchors.margins: 4
                            }
                        }
                        label: Text {
                                text: btn1.text
                                color: "white"
                                font.pointSize: 14
                            }

                    }

                }
                RadioButton {
                    id: btn2
                    text: qsTr("CDP 4.0 Release")
                    exclusiveGroup: versionGroup
                    activeFocusOnTab: false
                    style: RadioButtonStyle {
                        indicator: Rectangle {
                            implicitWidth: 30
                            implicitHeight: 30
                            radius: 29
                            border.color: control.activeFocus ? "darkblue" : "gray"
                            border.width: 1
                            Rectangle {
                                anchors.fill: parent
                                visible: control.checked
                                color: "#555"
                                radius: 9
                                anchors.margins: 4
                            }
                        }
                        label: Text {
                                text: btn2.text
                                color: "white"
                                font.pointSize: 14
                            }

                    }
                }
            }


        }//End versionRect

        /** Layout to arrange input fields */
        Column {
            id: mainColumn
            spacing:  20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 15
            anchors.top: versionRect.bottom
            anchors.topMargin: 20
            focus: true

            Text {
                text: qsTr("URL to component :")
                font.pointSize: 10
                color: "white"
            }

            /** Input field to set URL of CDP controller */
            Rectangle {
                color: "white"
                width: parent.width*0.98
                height: appWindow.height/20
                clip: true

                TextInput {
                    id: inputUrlField
                    anchors.fill: parent
                    font.pointSize: 10
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    activeFocusOnTab: true
                    focus: true


                    onAccepted: {
                        m_sCompUrl = text

                        /** Implemented to move focus to next input field on completion */
                        nextItemInFocusChain().focus = true

                        /** Implemented to start loading CDP controller for smoother operation*/
                        backLoad.setSource("Browser.qml",{"m_sCompUrl":m_sCompUrl,
                                                            "m_sUserName":m_sUserName,
                                                            "m_sPassWd":m_sPassWd,
                                                            "m_bIsPreCdp4Release":m_bIsPreCdp4Release})
                    }

                }

            }//End input URL

            Text {
                text: qsTr("Username :")
                font.pointSize: 10
                color: "white"
            }

            /** Input field to set user name for conneciton to CDP controller */
            Rectangle {
                color: "white"
                width: parent.width*0.98
                height: appWindow.height/20
                clip: true

                TextInput {
                    id: inputUserField
                    anchors.fill: parent
                    font.pointSize: 10
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    activeFocusOnTab: true

                    onAccepted: {
                        m_sUserName = text

                        /** Implemented to move focus to next input field on completion */
                        nextItemInFocusChain().focus = true
                    }
                }

            }//End inpu user name

            Text {
                text: qsTr("Password :")
                font.pointSize: 10
                color: "white"
            }

            /** Input field to set user password for conneciton to CDP controller */
            Rectangle {
                color: "white"
                width: parent.width*0.98
                height: appWindow.height/20
                clip: true

                TextInput {
                    id: inputPasswdField
                    anchors.fill: parent
                    font.pointSize: 10
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter

                    /** Set password field to hide characters */
                    echoMode: TextInput.PasswordEchoOnEdit
                    activeFocusOnTab: true

                    onAccepted: {
                        m_sPassWd = text

                        /** Implemented to move focus to next input field on completion */
                        nextItemInFocusChain().focus = true

                        /** Implemented to start loading CDP controller for smoother operation*/
                        backLoad.setSource("Browser.qml",{"m_sCompUrl":m_sCompUrl,
                                                            "m_sUserName":m_sUserName,
                                                            "m_sPassWd":m_sPassWd,
                                                            "m_bIsPreCdp4Release":m_bIsPreCdp4Release})
                    }
                }

            }//End input password

            /** Button to start loading and flip to the "data view" */
            Button {
                id: btnConnect
                text: qsTr("Connect")
                anchors.horizontalCenter: parent.horizontalCenter
                style: ButtonStyle {
                    background: Rectangle {
                        implicitWidth: appWindow.width - appWindow.width/10
                        implicitHeight: appWindow.height/20
                        border.color: control.pressed ? "black" :"white"
                        radius: 10

                        gradient: Gradient {
                                        GradientStop { position: 0      ; color: control.pressed ? "#ccc" : "white" }
                                        GradientStop { position: 0.33   ; color: control.pressed ? "#ccc" : "lightGreen" }
                                        GradientStop { position: 1      ; color: control.pressed ? "#aaa" : "green" }
                                    }
                    }
                    label: Text {
                        text: btnConnect.text
                        font.pointSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                onClicked : {
                    if(backLoad.status !== Loader.Ready)
                    {
                        backLoad.setSource("Browser.qml",{"m_sCompUrl":m_sCompUrl,
                                                          "m_sUserName":m_sUserName,
                                                          "m_sPassWd":m_sPassWd,
                                                          "m_bIsPreCdp4Release":m_bIsPreCdp4Release})
                    }

                    /** Emit the buttonClicked signal to flip the view */
                    mainPage.buttonClicked()
                }
            }//End button connect

//            Text {
//                id: debugText5
//                text: "DebugText5 :\nPre CDP4.0 = " + browserMain.m_bIsPreCdp4Release +
//                      "\nUrl  : " + browserMain.m_sCompUrl +
//                      "\nUser : " + browserMain.m_sUserName +
//                      "\nPass : " + browserMain.m_sPassWd
//                anchors.horizontalCenter: parent.horizontalCenter
//                font.pointSize: 10
//                color: "white"
//            }

        }//End Column
    }//End MainPage
}//End browserMain
