import QtQuick 2.0
import QtQuick.XmlListModel 2.0

/**
  * File: BrowserSideList.qml
  *
  * The type for "navigation view".
  *
  * Connects to the CDP controller to retrieve its components.
  * Displays the CDP components in a hiearchy tree view.
  *
  * TODO: Fix initial wrong value if lvl 1 is expanded.
*/

Rectangle {
    id: sidelist
    x: 0
    y: 0
    implicitWidth: 200
    implicitHeight: 800
    color: "#333333"

    property string m_sCompUrl          : ""                    ///< Contains Url to CDP component
    property string m_sUserName         : ""                    ///< Contains User name
    property string m_sPassWd           : ""                    ///< Contains Password
    property string m_sCurrentSelection : ""                    ///< Contains short name for active component.
    property bool   m_bIsPreCdp4Release : true                  ///< Contains type of controller.

    signal ms_selectPage(string compShortName, int selectLvl)   ///< Signal emited on active component changed.
    signal selectIndex(int pageIndex)                           ///< Singal emited on index changed.

    onMs_selectPage: {
        m_sCurrentSelection = compShortName
        listView1.expandColapsComponent(selectLvl)
    }

    onSelectIndex: {
        listView1.currentIndex = pageIndex
    }

    /** Model to contain data to be displayed */
    ListModel {
        id: sideListModel

    }

    /** Model that finds the initial components */
    XmlListModel{
        id: componentModel
        source: m_sCompUrl + "/?Command=GetComponentList&Name=All"
        query: "/Component/Subcomponent"

        XmlRole{
            name: "componentName"
            query:"@ShortName/string()"
            isKey: true
        }
        XmlRole{
            name: "componentFullName"
            query:"@Name/string()"
            isKey: true
        }
        XmlRole{
            name: "componentFirstSub"
            query: "Subcomponent[1]/@ShortName/string()"
        }

        onSourceChanged: reload()

        /** Fills the "sideListModel" with data from the CDP controller */
        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                var item
                for (var i=0; i<count; i++) {
                    item = get(i)
                    //console.log(item.componentName + " is added to componentModel ")
                    sideListModel.append({componentName: item.componentName,
                                       componentFullName: item.componentFullName,
                                       componentFirstSub: item.componentFirstSub})
                }

                item = get(0)
                sidelist.ms_selectPage(item.componentName, 0)
            }
        }
    }

    /** Current code require one XmlListModel for each sublayer to keep track of what is on that lvl*/
    XmlListModel{
        id: componentSubModel
        source: m_sCompUrl + "/?Command=GetComponentList&Name=" + m_sCurrentSelection
        query: "/Component/Subcomponent"

        XmlRole{
            name: "componentName"
            query:"@ShortName/string()"
            isKey: true
        }
        XmlRole{
            name: "componentFullName"
            query:"@Name/string()"
            isKey: true
        }
        XmlRole{
            name: "componentFirstSub"
            query: "Subcomponent[1]/@ShortName/string()"
        }

        onSourceChanged: reload()

        onStatusChanged: {
            /* Debug text
            if (status == XmlListModel.Ready) {
                for (var i=0; i<count; i++) {
                    var item = get(i)
                    console.log(item.componentName + " is added to sublist ")
                }
            }*/

        }
    }

    /** Current code require one XmlListModel for each sublayer to keep track of what is on that lvl*/
    XmlListModel{
        id: componentSubModel2
        source: m_sCompUrl + "/?Command=GetComponentList&Name=" + m_sCurrentSelection
        query: "/Component/Subcomponent"

        XmlRole{
            name: "componentName"
            query:"@ShortName/string()"
            isKey: true
        }
        XmlRole{
            name: "componentFullName"
            query:"@Name/string()"
            isKey: true
        }
        XmlRole{
            name: "componentFirstSub"
            query: "Subcomponent[1]/@ShortName/string()"
        }

        onSourceChanged: reload()

        onStatusChanged: {
            /*Debug text
            if (status == XmlListModel.Ready) {
                for (var i=0; i<count; i++) {
                    var item = get(i)
                    console.log(item.componentName + " is added to sublist 2 ")
                }
            }*/
        }
    }

    /** Delegate styling for the "navigation view" */
    Component {
        id: sideListDelegate
        Rectangle {
            id: delegateItem
            height: sidelist.height/15
            width: parent.width
            color: "transparent"
            border.color: "#444444"
            clip: true

            property int lvl : 0
            property bool gotChildren : (model.componentFirstSub.length > 0) ? true : false

            /** Function to derive the delegate lvl from its unique full name */
            function calculateDelegateLvl(fullName) {
                var splitName = fullName.split(".")
                /*Debug code
                console.log(fullName + " is split in to " + splitName.length)
                */

                return splitName.length -1
            }

            Component.onCompleted: {
                /*Debug code
                console.log(model.componentFirstSub + " is first child of : " + model.componentName)
                */

                lvl = calculateDelegateLvl(componentFullName)
            }

            /** Uses the with of a transparent rect to create the illusion of one lvl in to the list */
            Rectangle {
                id: colorRect
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 40*lvl
                height: 40
                color: "transparent"
            }

            /** Supply a picture to the delegate to indicate if it got children */
            Image {
                id: listImage
                anchors.left: colorRect.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                source: gotChildren ? "../pics/plus_sign.png" : "../pics/minus_sign.png"

            }

            /** The text displayd on the delegate */
            Text {
                text: lvl + " : " + componentName
                anchors.left: listImage.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8
                font.bold: true
                color: "#ffffff"
                font.pointSize: 10

            }

            MouseArea {
                id: mouse_area1
                z: 1
                hoverEnabled: false
                anchors.fill: parent

                onReleased: {
                    sidelist.selectIndex(model.index)
                    sidelist.ms_selectPage(model.componentName, lvl)
                }

                onDoubleClicked: listView1.delegateDclick(model.index, lvl)
            }

        }//End of delegateItem
    }


    /** The list displaying the hierachy tree of the CDP controllers */
    ListView {
        id: listView1
        anchors.fill: parent
        model: sideListModel
        delegate: sideListDelegate
        highlight: Rectangle {
            id: highlightRect
            width: parent.width // height: 40
            color: "white"; radius: 5
            opacity: 0.2
            y: listView1.currentItem.y

            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
        highlightFollowsCurrentItem: true

        property int lvl_1_lastIndex              : 0
        property int lvl_1_lastIndexNrOfSubComp   : 0
        property int lvl_2_lastIndex              : 0
        property int lvl_2_lastIndexNrOfSubComp   : 0
        //property int lvl_3_lastIndex              : 0
        //property int lvl_3_lastIndexNrOfSubComp   : 0
        //property int lvl_4_lastIndex              : 0
        //property int lvl_4_lastIndexNrOfSubComp   : 0

        property bool lvl_1_expanded        : false
        property bool lvl_2_expanded        : false
        //property bool lvl_3_expanded        : false
        //property bool lvl_4_expanded        : false

        signal delegateDclick(int delegateIndex, int delegateLvl)

        onDelegateDclick : {
            //expandColapsComponent(delegateLvl)
        }

        /** Keeps track of what comp is expanded on wich lvl,
            when one base comp is selected closes sub comp of active comp*/
        //TODO: Add support for more levels,currently only 2, either static or change the function to be more dynamic.
        function expandColapsComponent(deleLvl){
            //Need to keep track on what lvl the selected comp is on.
            var indexToUse = currentIndex
            var tempSubModel,i

            switch (deleLvl) {
                case 0:
                    if(lvl_1_expanded)
                    {
                        // Need to iterate through higher lvl's for clean up.
                        if(lvl_2_expanded)
                        {
                            if(lvl_2_lastIndexNrOfSubComp != 0)
                            {
                                model.remove(lvl_2_lastIndex+1,lvl_2_lastIndexNrOfSubComp)
                                lvl_2_lastIndexNrOfSubComp = 0
                            }
                        }

                        if(lvl_1_lastIndexNrOfSubComp != 0)
                        {
                            model.remove(lvl_1_lastIndex+1,lvl_1_lastIndexNrOfSubComp)
                            lvl_1_lastIndexNrOfSubComp = 0
                        }
                        lvl_2_expanded = false
                        lvl_1_expanded = false
                    }
                    else
                    {
                        //console.log("ExpandEvent Case 0 encountered: and lvl_1_isNOT Expanded")
                        for(i=componentSubModel.count-1 ; i>=0 ; --i)
                        {
                            tempSubModel = componentSubModel.get(i)
                            model.insert(indexToUse+1,{"componentName":tempSubModel.componentName ,
                                                        "componentFullName":tempSubModel.componentFullName ,
                                                        "gotChildren":tempSubModel.gotChildren})

                        }

                        lvl_1_lastIndexNrOfSubComp = componentSubModel.count
                        lvl_1_lastIndex = indexToUse
                        lvl_1_expanded = true
                    }
                    break

                case 1:
                    if(lvl_2_expanded)
                    {
                        // Need to iterate through higher lvl's for clean up.
                        if(lvl_2_lastIndexNrOfSubComp != 0)
                        {
                            model.remove(lvl_2_lastIndex+1,lvl_2_lastIndexNrOfSubComp)
                            lvl_2_expanded = false
                            lvl_2_lastIndexNrOfSubComp = 0
                        }
                    }
                    else
                    {
                        for(i=componentSubModel2.count-1;i>=0;--i)
                        {
                            tempSubModel = componentSubModel2.get(i)
                            model.insert(indexToUse+1,{"componentName":tempSubModel.componentName ,
                                                        "componentFullName":tempSubModel.componentFullName ,
                                                        "gotChildren":tempSubModel.gotChildren})
                        }
                        lvl_2_lastIndexNrOfSubComp = componentSubModel2.count
                        lvl_2_lastIndex = indexToUse
                        lvl_2_expanded = true
                    }
                    break
            }
        }//End of expandColapsComponent

        add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
                NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 400 }
            }

        displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.InOutSine}
                NumberAnimation { property: "opacity"; to: 1.0}
                NumberAnimation { property: "scale"; to: 1.0}
            }

    }//End ListView



}//End Column1
