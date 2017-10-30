#include "qtquick2controlsapplicationviewer.h"
#include <QQuickView>

int main(int argc, char *argv[])
{
    Application app(argc, argv);

    //QQuickView splashScreen;
    //splashScreen.setSource(QString("qml/BrowserV2/Splash.qml"));



    QtQuick2ControlsApplicationViewer viewer;
    viewer.setMainQmlFile(QStringLiteral("qml/BrowserV2/main.qml"));
    viewer.show();

    return app.exec();
}
