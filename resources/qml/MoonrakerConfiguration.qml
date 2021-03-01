import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import UM 1.2 as UM
import Cura 1.0 as Cura


Cura.MachineAction
{
    id: base;

    property var finished: manager.finished
    onFinishedChanged: if(manager.finished) {completed()}

    function reset()
    {
        manager.reset()
    }

    anchors.fill: parent;
    property var selectedInstance: null

    property bool validUrl: true;

    Component.onCompleted: {
        actionDialog.minimumWidth = screenScaleFactor * 500;
        actionDialog.minimumHeight = screenScaleFactor * 270;
        actionDialog.maximumWidth = screenScaleFactor * 500;
        actionDialog.maximumHeight = screenScaleFactor * 270;
    }

    Column {
        anchors.fill: parent;

        Item { width: parent.width; }
        Label { text: catalog.i18nc("@label", "Moonraker Address (URL)"); }
        TextField {
            id: urlField;
            text: manager.printerSettingUrl;
            maximumLength: 1024;
            anchors.left: parent.left;
            anchors.right: parent.right;
            onTextChanged: {
                base.validUrl = manager.validUrl(urlField.text);
            }
        }

        Item { width: parent.width; }
        Label {
            visible: !base.validUrl;
            text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/");
            color: "red";
        }

        Item { width: parent.width;  height: 10; }
        Label { text: catalog.i18nc("@label", "API-Key (Optional - if the network is untrusted)"); }
        TextField {
            id: api_keyField;
            text: manager.printerSettingAPIKey;
            maximumLength: 1024;
            anchors.left: parent.left;
            anchors.right: parent.right;
        }

        Item { width: parent.width; height: 10; }
        Label { text: catalog.i18nc("@label", "Username (HTTP Basic Auth)"); }
        TextField {
            id: http_userField;
            text: manager.printerSettingHTTPUser;
            maximumLength: 1024;
            anchors.left: parent.left;
            anchors.right: parent.right;
        }

        Item { width: parent.width;  height: 10; }
        Label { text: catalog.i18nc("@label", "Password (HTTP Basic Auth)"); }
        TextField {
            id: http_passwordField;
            text: manager.printerSettingHTTPPassword;
            maximumLength: 1024;
            anchors.left: parent.left;
            anchors.right: parent.right;
        }

        Item { width: parent.width;  height: 10; }
        Label { text: catalog.i18nc("@label", "Output Format"); }
        RowLayout {
            id: outputFormat;
            ExclusiveGroup { id: outputFormatGroup }
            RadioButton {
                id: outputFormatGcode;
                checked: manager.printerOutputFormat != "ufp";
                text: "G-code";
                exclusiveGroup: outputFormatGroup;
            }
            RadioButton {
                id: outputFormatUfp;
                checked: manager.printerOutputFormat == "ufp";
                text: "UFP with Thumbnail";
                exclusiveGroup: outputFormatGroup;
            }
        }

        Item {
            width: saveButton.implicitWidth;
            height: saveButton.implicitHeight;
        }

        RowLayout {
            Button {
                id: saveButton;
                text: catalog.i18nc("@action:button", "Save Config");
                width: screenScaleFactor * 100;
                onClicked: {
                    manager.saveConfig(urlField.text, api_keyField.text, http_userField.text, http_passwordField.text, outputFormatUfp.checked);
                    actionDialog.reject();
                }
                enabled: base.validUrl;
            }

            Button {
                id: deleteButton;
                text: catalog.i18nc("@action:button", "Remove Config");
                width: screenScaleFactor * 100;
                onClicked: {
                    manager.deleteConfig();
                    actionDialog.reject();
                }
            }
        }
    }
}
