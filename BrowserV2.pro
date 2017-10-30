# Add more folders to ship with the application, here
folder_01.source = qml/BrowserV2
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2controlsapplicationviewer/qtquick2controlsapplicationviewer.pri)
qtcAddDeployment()

QT += xmlpatterns xml

OTHER_FILES += \
    qml/BrowserV2/Browser/CompSignal.qml \
    qml/BrowserV2/Browser/Browser.qml \
    android/AndroidManifest.xml \
    qml/BrowserV2/Browser/ComponentMain.qml \
    qml/BrowserV2/Browser/BrowserNavView.qml \
    qml/BrowserV2/Browser/BrowserSideList.qml \
    qml/BrowserV2/Browser/BrowserMain.qml \
    qml/BrowserV2/Splash.qml \
    qml/BrowserV2/Browser/CompCDPSignal.qml \
    qml/BrowserV2/Browser/CompSignalList.qml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
