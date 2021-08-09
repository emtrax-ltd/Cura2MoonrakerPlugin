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
    property bool validTrans: true;

    Component.onCompleted: {
        actionDialog.minimumWidth = screenScaleFactor * 580;
        actionDialog.minimumHeight = screenScaleFactor * 410;
        actionDialog.maximumWidth = screenScaleFactor * 580;
        actionDialog.maximumHeight = screenScaleFactor * 410;
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

        Item { width: parent.width; height: 10; }
        Label { text: catalog.i18nc("@label", "Name of Moonraker Power Device in moonraker.conf"); }
        TextField {
            id: power_deviceField;
            text: manager.printerSettingPowerDevice;
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

        Item { width: parent.width;  height: 10; }
        RowLayout {
            Label { text: catalog.i18nc("@label", "Filename Translation "); }
            Label { text: "filename.translate(filename.maketrans(input[], output[], remove[])"; font.italic: true }
        }
        RowLayout {
            Label { text: catalog.i18nc("@label", "Input:"); }
            TextField {
                id: transInputField;
                text: manager.printerTransInput;
                width: 60;
                maximumLength: 128;
                onTextChanged: {
                    base.validTrans = manager.validTrans(transInputField.text, transOutputField.text);
                }
            }

            Label { text: catalog.i18nc("@label", "Output:"); }
            TextField {
                id: transOutputField;
                text: manager.printerTransOutput;
                width: 60;
                maximumLength: 128;
                onTextChanged: {
                    base.validTrans = manager.validTrans(transInputField.text, transOutputField.text);
                }
            }

            Label { text: catalog.i18nc("@label", "Remove:"); }
            TextField {
                id: transRemoveField;
                text: manager.printerTransRemove;
                width: 60;
                maximumLength: 128;
            }
        }
        Item { width: parent.width; }
        Label {
            visible: !base.validTrans;
            text: catalog.i18nc("@error", "Number of mapping characters in the input must be equal to the output!");
            color: "red";
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
                    manager.saveConfig({
                        'url': urlField.text,
                        'api_key': api_keyField.text,
                        'http_user': http_userField.text,
                        'http_password': http_passwordField.text,
                        'power_device': power_deviceField.text,
                        'output_format_ufp': outputFormatUfp.checked,
                        'trans_input': transInputField.text,
                        'trans_output': transOutputField.text,
                        'trans_remove': transRemoveField.text
                    });
                    actionDialog.reject();
                }
                enabled: base.validUrl & base.validTrans;
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
