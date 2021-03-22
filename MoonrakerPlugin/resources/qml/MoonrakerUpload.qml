import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1

import UM 1.1 as UM

UM.Dialog
{
    id: base;
    property string object: "";

    property alias newName: nameField.text;
    property bool validName: true;
    property string validationError;
    property string dialogTitle: "Upload to Moonraker";

    title: dialogTitle;

    minimumWidth: screenScaleFactor * 400
    minimumHeight: screenScaleFactor * 100

    property variant catalog: UM.I18nCatalog { name: "uranium"; }

    signal textChanged(string text);
    signal selectText()
    onSelectText: {
        nameField.selectAll();
        nameField.focus = true;
    }

    Column {
        anchors.fill: parent;

        Label {
            text: "Filename";
        }

        TextField {
            objectName: "nameField";
            id: nameField;
            width: parent.width;
            text: base.object;
            maximumLength: 100;
            onTextChanged: base.textChanged(text);
            Keys.onReturnPressed: { if (base.validName) base.accept(); }
            Keys.onEnterPressed: { if (base.validName) base.accept(); }
            Keys.onEscapePressed: base.reject();
        }

        Label {
            visible: !base.validName;
            text: base.validationError;
            color: "red";
        }

        Item { width: parent.width;  height: 10; }
        
        CheckBox {
            objectName: "printField";
            id: printField;
            text: "Start print job";
        }
    }

    rightButtons: [
        Button {
            text: catalog.i18nc("@action:button", "Upload");
            onClicked: base.accept();
            enabled: base.validName;
            isDefault: true;
        },
        Button {
            text: catalog.i18nc("@action:button", "Cancel");
            onClicked: base.reject();
        }
    ]
}
