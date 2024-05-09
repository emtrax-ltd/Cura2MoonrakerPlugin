import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1

import UM 1.3 as UM
import Cura 1.1 as Cura

UM.Dialog {
    property variant catalog: UM.I18nCatalog { id: catalog; name: "cura" }
    
    property bool validPath: true
    property string validationPathError
    property bool validName: true
    property string validationNameError

    id: base
    title: catalog.i18nc("@title:window", "Upload to Moonraker")
    minimumWidth: screenScaleFactor * 500
    minimumHeight: screenScaleFactor * 230 + UM.Theme.getSize("default_margin").width * 4 * screenScaleFactor

    signal pathesChanged(variant pathes)
    signal textChanged(string text)

    Cura.RoundedRectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        cornerSide: Cura.RoundedRectangle.Direction.Down
        border.color: UM.Theme.getColor("lining")
        border.width: UM.Theme.getSize("default_lining").width
        radius: UM.Theme.getSize("default_radius").width
        color: UM.Theme.getColor("main_background")

        Item {
            id: dialogBase
            anchors.fill: parent

            property int columnSpacing: 3 * screenScaleFactor

            RowLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: UM.Theme.getSize("default_margin").width
                }
                spacing: UM.Theme.getSize("default_margin").width
                
                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: dialogBase.columnSpacing

                    RowLayout {
                        width: parent.width
                        
                        Label {
                            anchors.bottomMargin: 10
                            text: catalog.i18nc("@label", "Path")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                        }
                        Label {
                            visible: true
                            text: !base.validPath ? base.validationPathError : '*Edit the text and press Enter to add it to the list'
                            font: UM.Theme.getFont("default_italic")
                            color: !base.validPath ? UM.Theme.getColor("error") : UM.Theme.getColor("text_disabled")
                            leftPadding: 15
                        }
                    }

                    Cura.ComboBox {
                        objectName: "pathField"
                        id: pathField
                        width: parent.width
                        font: UM.Theme.getFont("default")
                        editable: true
                        property string path
                        property var pathes
                        property bool initialized: false

                        onPathesChanged: {
                            if (!initialized) {
                                initialized = true
                                model.clear()
                                model.append({text: ''})
                                for (var i = 0; i < pathes.length; i++) {
                                    var p = pathes[i].replace(/^[\s\/]+|[\s\/]+$/g, '')
                                    if (p != "" && p != "/" && find(p) === -1) {
                                        model.append({text: p})
                                    }
                                }
                                model.sort()
                                pathes = model.array()
                                currentIndex = find(path)
                                if (currentIndex === -1) {
                                    editText = path
                                }                                
                            }
                        }

                        onCurrentTextChanged: {
                            editText = currentText
                            base.textChanged(currentText)
                        }

                        onEditTextChanged: {
                            path = editText
                            base.textChanged(editText)
                        }

                        model: ListModel {
                            id: pathModel

                            function sort() {
                                for (var n = 0; n < count; n++) {
                                    for (var i = n + 1; i < count; i++) {
                                        if (get(n).text.localeCompare(get(i).text) > 0) {
                                            move(i, n, 1)
                                            break
                                        }                            
                                    }
                                }
                            }

                            function array() {
                                var values = []
                                for (var i = 0; i < count; ++i) {
                                    if (get(i).text != '') {
                                        values.push(get(i).text)
                                    }
                                }
                                return values
                            }
                        }

                        contentItem: Cura.TextField {
                            id: contentLabel
                            anchors.left: parent.left
                            anchors.right: pathField.indicator.left
                            wrapMode: Text.NoWrap
                            text: pathField.editable ? pathField.editText : pathField.displayText
                            font: pathField.font
                            color: UM.Theme.getColor("setting_control_text")
                         
                            background: Rectangle {
                                anchors.fill: parent
                                opacity: 0
                                color:  "transparent"
                                border.width: 0
                            }
                        }

                        delegate: ItemDelegate {
                            id: delegateItem
                            width: pathField.width - 2 * UM.Theme.getSize("default_lining").width
                            height: pathField.height
                            highlighted: pathField.highlightedIndex == index
                            text: modelData

                            contentItem: Label {
                                id: delegateLabel
                                anchors.fill: parent
                                anchors.leftMargin: UM.Theme.getSize("setting_unit_margin").width
                                anchors.rightMargin: UM.Theme.getSize("setting_unit_margin").width
                                wrapMode: Text.NoWrap
                                text: delegateItem.text
                                textFormat: Text.PlainText
                                renderType: Text.NativeRendering
                                font: pathField.font
                                color: UM.Theme.getColor("setting_control_text")
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight

                                UM.SimpleButton {
                                    id: removeItem
                                    iconSource: UM.Theme.getIcon("cross1").toString().length > 0 ? UM.Theme.getIcon("cross1") : UM.Theme.getIcon("Cancel");
                                    visible: delegateItem.text != ""
                                    height: Math.round(parent.height * 0.5)
                                    width: visible ? height : 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right

                                    color: UM.Theme.getColor("setting_control_button")
                                    hoverColor: UM.Theme.getColor("setting_control_button_hover")

                                    onClicked:  {
                                        var itemIndex = pathField.find(delegateItem.text)
                                        var currentIndex = pathField.currentIndex
                                        pathField.model.remove(itemIndex)
                                        if (itemIndex == currentIndex) {
                                            pathField.currentIndex = pathField.find("")
                                        }
                                        pathField.pathes = pathField.model.array()
                                        base.pathesChanged(pathField.pathes)
                                    }
                                }
                            }

                            background: UM.TooltipArea {
                                acceptedButtons: Qt.NoButton
                                Rectangle {
                                    color: delegateItem.highlighted ? UM.Theme.getColor("setting_control_highlight") : "transparent"
                                    border.color: delegateItem.highlighted ? UM.Theme.getColor("setting_control_border_highlight") : "transparent"
                                    anchors.fill: parent
                                }
                                text: delegateLabel.truncated ? delegateItem.text : ""
                            }
                        }

                        onAccepted: {
                            editText = editText.replace(/^[\s\/]+|[\s\/]+$/g, '')
                            if (editText != "" && editText != "/" && find(editText) === -1) {
                                model.append({text: editText})
                                model.sort()
                                pathes = model.array()
                                pathField.currentIndex = find(editText)
                                base.pathesChanged(pathes)
                            }
                        }                        
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    RowLayout {
                        width: parent.width
                        
                        Label {
                            anchors.bottomMargin: 10
                            text: catalog.i18nc("@label", "Filename")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                        }
                        Label {
                            visible: !base.validName
                            text: base.validationNameError
                            font: UM.Theme.getFont("default_italic")
                            color: UM.Theme.getColor("error")
                            leftPadding: 15
                        }
                    }

                    Cura.TextField {
                        objectName: "nameField"
                        id: nameField
                        text: ''
                        font: UM.Theme.getFont("default")
                        maximumLength: 1024
                        width: parent.width
                        onTextChanged: base.textChanged(text)
                        Keys.onReturnPressed: { if (base.validName) base.accept() }
                        Keys.onEnterPressed: { if (base.validName) base.accept() }
                        Keys.onEscapePressed: base.reject()
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    RowLayout {
                        Cura.CheckBox {
                            objectName: "printField"
                            id: printField
                            text: catalog.i18nc("@label", "Start print job")
                            font: UM.Theme.getFont("default")
                        }
                    }
                }
            }
        }
    }

    rightButtons: [
        Cura.PrimaryButton {
            text: catalog.i18nc("@action:button", "Upload")
            enabled: base.validPath && base.validName
            onClicked: base.accept()
        },
        Label {            
            text: ''
            width: 10
        },
        Cura.SecondaryButton {
            text: catalog.i18nc("@action:button", "Cancel")
            onClicked: base.reject()
        }
    ]
}
