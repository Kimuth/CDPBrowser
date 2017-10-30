import QtQuick 2.0
import QtQuick.Window 2.0

/**
  * File: BrowserNavView.qml
  *
  * The type for "path view".
  *
  * Recieves signal from the "navigation view" to determin current active
  * CDP component. Then displays the path to this CDP component .
  * Presents the full path to the active CDP component as a string to other types.
  *
*/

Rectangle {
    id: wrapp
    implicitWidth: 240
    implicitHeight: 200
    color: "transparent"

    property string     m_sFullListString   : ""            ///< Full string to active component
    property ListModel  m_vContMod          : contactModel  ///< The model used to display path
    property PathView   m_vPathW            : thisView      ///< The pathView used in display

    signal itemAdd(string item, int itemLvl)                ///< Signal recieving active component name and lvl in hierachy.

    /** Checks recieved signals lvl and inserts it to model correctly, then update path */
    onItemAdd: {
        if(itemLvl==0) {
            m_vContMod.clear()
            m_vContMod.append({"name": item})
            updateFullListString()
        }
        else {
            if(m_vContMod.count == itemLvl)
            {
                insertAndChangeView(item)
            }
            else
            {
                m_vContMod.remove(0,m_vContMod.count-itemLvl)
                insertAndChangeView(item)
            }
        }
    }


    Component.onCompleted: {
        updateFullListString()
    }

    /** Convenient function to insert component name and update the view*/
    function insertAndChangeView(itemName) {
        m_vContMod.insert(0,{"name":itemName})
        m_vPathW.positionViewAtIndex(0,PathView.Beginning)
        updateFullListString()
    }

    /** Convenient function to update the path to the active component */
    function updateFullListString(){
        m_sFullListString = ""
        for(var i = thisView.count-1; i >= 0 ; --i ){
            m_sFullListString += "/" + contactModel.get(i).name
        }
    }

    ListModel {
        id: contactModel
    }

    /** Component to style the delegates */
    Component {
        id: delegate
        Item {
            id: wrapper1
            width: 20; height: 20
            scale: PathView.iconScale
            opacity: PathView.iconOpacity

            property alias delegateName : nameText.text

            Row {
                id: wrapper
                spacing:  10
                Image {
                    anchors.verticalCenter:  nameText.verticalCenter
                    width: (thisView.count != 1) ? 16 : 0
                    height: 16
                    source: (thisView.count != 1) ? "../pics/Arrow-Left.ico" : ""
                    //rotation: wrapper1.PathView.itemRotation
                }
                Text {
                    id: nameText
                    text: name
                    font.pointSize: 14
                    color: wrapper1.PathView.isCurrentItem ? "red" : "white"
                }
            }
        }
    }

    /** The actual display of the components */
    PathView {
        id: thisView
        anchors.fill: wrapp
        model: contactModel
        delegate: delegate
        focus: false
        interactive: false
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()

        /** Controlls how the path moves */
        path: Path {
            startX: (wrapp.width/2)/2; startY:(thisView.count == 1) ? wrapp.height/2 : wrapp.height - (wrapp.height/7)
            PathAttribute { name: "iconScale"; value: 1.0 }
            PathAttribute { name: "iconOpacity"; value: 1.0 }
            PathAttribute { name: "itemRotation"; value: 0 }
            PathLine {x: 50; y: 0}
            PathAttribute { name: "iconScale"; value: 0.6 }
            PathAttribute { name: "iconOpacity"; value: 0.5 }
            PathAttribute { name: "itemRotation"; value: 90 }
        }

        onCurrentIndexChanged: {
            updateFullListString()
        }
    }
}

