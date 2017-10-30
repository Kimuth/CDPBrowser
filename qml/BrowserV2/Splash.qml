import QtQuick 2.0

/**
  *
  * Copy from Qt example code.
  *
  * http://developer.nokia.com/community/wiki/Simple_Splash_Screen_in_QML
*/

Item {
    id: splashScreenContainer
    anchors.fill: parent
    z: 1

    // image source is kept as an property alias, so that it can be set from outside
    property alias imageSource: splashImage.source

    // signal emits when splashscreen animation completes
    signal splashScreenCompleted()
    Image {
        id: splashImage
        source: "pics/logo.png" /*imageSource*/
        anchors.fill: splashScreenContainer // do specify the size and position
    }

    // simple QML animation to give a good user experience
    SequentialAnimation {
        id:splashanimation
        PauseAnimation { duration: 4200 }
        PropertyAnimation {
            target: splashImage
            duration: 700
            properties: "opacity"
            to:0
        }

        onStopped: {
            splashScreenContainer.splashScreenCompleted()
            splashScreenContainer.visible = false
        }
    }
    //starts the splashScreen
    Component.onCompleted: splashanimation.start()
 }
