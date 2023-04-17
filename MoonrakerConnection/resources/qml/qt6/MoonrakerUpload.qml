import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.1

import UM 1.5 as UM
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
    minimumHeight: screenScaleFactor * 140 + UM.Theme.getSize("default_margin").width * 4 * screenScaleFactor

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
                        
                        UM.Label {
                            anchors.bottomMargin: 10
                            text: catalog.i18nc("@label", "Filename")
                        }
                        UM.Label {
                            visible: !base.validName
                            text: base.validationError
                            font: UM.Theme.getFont("default_italic")
                            color: UM.Theme.getColor("error")
                            leftPadding: 15

                        }
                    }

                    Cura.TextField {
                        objectName: "nameField"
                        maximumLength: 1024

                        id: nameField

                        text: base.object
                        font: UM.Theme.getFont("default")
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
                        UM.CheckBox {
                            objectName: "printField";

                            id: printField;
                            text: catalog.i18nc("@label", "Start print job")
                        }
                    }
                }
            }
        }
    }

    rightButtons: [
        Cura.PrimaryButton {
            text: catalog.i18nc("@action:button", "Upload")
            enabled: base.validName
            onClicked: base.accept()
        },
        Rectangle {
            Layout.fillHeight: true
            width: 10
        },
        Cura.SecondaryButton {
            text: catalog.i18nc("@action:button", "Cancel")
            onClicked: base.reject()
        }
    ]
}
