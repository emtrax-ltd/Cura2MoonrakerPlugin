import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1

import UM 1.3 as UM
import Cura 1.1 as Cura

UM.Dialog {

    property variant catalog: UM.I18nCatalog { id: catalog; name: "cura" }
    property string object: "";
    property alias newName: nameField.text;
    property bool validName: true;
    property string validationError;

    id: base;
    title: catalog.i18nc("@title:window", "Upload to Moonraker");
    minimumWidth: screenScaleFactor * 400
    minimumHeight: screenScaleFactor * 130 + UM.Theme.getSize("default_margin").width * 2 * screenScaleFactor

    signal textChanged(string text)
    signal selectText()

    onSelectText: {
        nameField.selectAll()
        nameField.focus = true
    }

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
                            text: catalog.i18nc("@label", "Filename")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            anchors.bottomMargin: 10
                        }
                        Label {
                            text: base.validationError
                            font: UM.Theme.getFont("default_italic")
                            color: UM.Theme.getColor("error")
                            leftPadding: 15
                            visible: !base.validName
                        }
                    }

                    Cura.TextField {
                        objectName: "nameField"
                        id: nameField
                        text: base.object
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
                            objectName: "printField";
                            id: printField;
                            text: catalog.i18nc("@label", "Start print job")
                            font: UM.Theme.getFont("default")
                        }
                    }
                }
            }
        }
    }

    rightButtons: [
        Button {
            text: catalog.i18nc("@action:button", "Upload")
            enabled: base.validName
            isDefault: true
            onClicked: base.accept()
        },
        Button {
            text: catalog.i18nc("@action:button", "Cancel")
            onClicked: base.reject()
        }
    ]
}
