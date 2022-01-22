import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import UM 1.3 as UM
import Cura 1.1 as Cura

Cura.MachineAction {

    UM.I18nCatalog { id: catalog; name: "cura" }

    id: base
    anchors.fill: parent
    
    property bool validUrl: true
    property bool validTrans: true

    function outputFormat() {
        if (outputFormatUfp.checked) {
            return "ufp"
        }
        return "gcode"
    }

    function updateConfig() {
        manager.saveConfig({
            'url': urlField.text,
            'api_key': apiKeyField.text,
            'power_device': powerDeviceField.text,
            'output_format': outputFormat(),
            'upload_remember_state': uploadRememberStateBox.checked,
            'upload_autohide_messagebox': uploadAutoHideMessageboxBox.checked,
            'trans_input': transInputField.text,
            'trans_output': transOutputField.text,
            'trans_remove': transRemoveField.text
        })
    }

    Cura.RoundedRectangle {
        anchors {
            top: machineLabel.bottom
            topMargin: UM.Theme.getSize("default_margin").height
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
            id: configurationBase
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

                    spacing: configurationBase.columnSpacing

                    Label {
                        id: connectionLabel
                        text: catalog.i18nc("@title:label", "Connection")
                        font: UM.Theme.getFont("medium_bold")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    RowLayout {
                        width: parent.width
                        Label {
                            text: catalog.i18nc("@label", "Moonraker Address (URL)")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            leftPadding: 15
                        }
                        Label {
                            visible: !base.validUrl
                            text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                            font: UM.Theme.getFont("default_italic")
                            renderType: Text.NativeRendering
                            color: "red"
                            leftPadding: 15
                        }
                    }
                    TextField {
                        id: urlField
                        text: manager.printerSettingUrl
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering                        
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
                        padding: 0
                        leftPadding: UM.Theme.getSize("narrow_margin").width
                        onTextChanged: base.validUrl = manager.validUrl(urlField.text)
                        onEditingFinished: { updateConfig() }
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    Label {
                        text: catalog.i18nc("@label", "API-Key (Optional - if the network is untrusted)")
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        leftPadding: 15
                    }
                    TextField {
                        id: apiKeyField
                        text: manager.printerSettingAPIKey
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
                        padding: 0
                        leftPadding: UM.Theme.getSize("narrow_margin").width
                        onEditingFinished: { updateConfig() }
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    Label {
                        text: catalog.i18nc("@label", "Name of Moonraker Power Device(s) in moonraker.conf")
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        leftPadding: 15
                    }
                    TextField {
                        id: powerDeviceField
                        text: manager.printerSettingPowerDevice
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
                        padding: 0
                        leftPadding: UM.Theme.getSize("narrow_margin").width
                        onEditingFinished: { updateConfig() }
                    }

                    Label {
                        text: catalog.i18nc("@title:label", "Upload")
                        font: UM.Theme.getFont("medium_bold")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        width: parent.width
                        topPadding: 25
                        elide: Text.ElideRight
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    Label {
                        text: catalog.i18nc("@label", "Format")
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        leftPadding: 15
                    }
                    ButtonGroup {
                        buttons: outputFormatValue.children
                    }
                    RowLayout {
                        id: outputFormatValue
                        RadioButton {
                            id: outputFormatGcode
                            checked: manager.printerOutputFormat != "ufp"
                            text: catalog.i18nc("@option:radio", "G-code")
                            font: UM.Theme.getFont("default")
                            leftPadding: 25
                            onClicked: { updateConfig() }
                        }
                        RadioButton {
                            id: outputFormatUfp
                            checked: manager.printerOutputFormat == "ufp"
                            text: catalog.i18nc("@option:radio", "UFP with Thumbnail")
                            font: UM.Theme.getFont("default")
                            onClicked: { updateConfig() }
                        }
                    }

        		    Item {
                        width: parent.width
                        height: 10
                    }
                    Label {
                        text: catalog.i18nc("@label", "Process")
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        leftPadding: 15
                    }
                    CheckBox {
                        id: uploadRememberStateBox
                        checked: manager.printerUploadRememberState
                        text: catalog.i18nc("@option:check", "Remember state of \"Start print job\"")
                        font: UM.Theme.getFont("default")
                        leftPadding: 25
                        onClicked: { updateConfig() }
                    }
                    CheckBox {
                        id: uploadAutoHideMessageboxBox
                        checked: manager.printerUploadAutoHideMessagebox
                        text: catalog.i18nc("@option:check", "Auto hide messagebox for successful upload (30 seconds)")
                        font: UM.Theme.getFont("default")
                        leftPadding: 25
                        onClicked: { updateConfig() }
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    RowLayout {
                        Label {
                            text: catalog.i18nc("@label", "Filename Translation ")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            leftPadding: 15
                        }
                        Label {
                            text: catalog.i18nc("@label", "filename.translate(filename.maketrans(input[], output[], remove[])")
                            font: UM.Theme.getFont("default_italic")
                            color: "gray"
                            renderType: Text.NativeRendering
                            leftPadding: 25
                        }
                    }
                    RowLayout {
                        Label {
                            text: catalog.i18nc("@label", "Input")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            leftPadding: 25
                        }
                        TextField {
                            id: transInputField
                            text: manager.printerTransInput
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            width: 60
                            maximumLength: 128
                            padding: 0
                            leftPadding: UM.Theme.getSize("narrow_margin").width
                            onTextChanged: base.validTrans = manager.validTrans(transInputField.text, transOutputField.text)
                            onEditingFinished: { updateConfig() }
                        }

                        Label {
                            text: catalog.i18nc("@label", "Output")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            leftPadding: 15
                        }
                        TextField {
                            id: transOutputField
                            text: manager.printerTransOutput
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            width: 60
                            maximumLength: 128
                            padding: 0
                            leftPadding: UM.Theme.getSize("narrow_margin").width
                            onTextChanged: base.validTrans = manager.validTrans(transInputField.text, transOutputField.text)
                            onEditingFinished: { updateConfig() }
                        }

                        Label {
                            text: catalog.i18nc("@label", "Remove")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            leftPadding: 15
                        }
                        TextField {
                            id: transRemoveField
                            text: manager.printerTransRemove
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            width: 60
                            padding: 0
                            leftPadding: UM.Theme.getSize("narrow_margin").width
                            maximumLength: 128
                            onEditingFinished: { updateConfig() }
                        }
                    }

                    Item {
                        width: parent.width
                    }
                    Label {
                        visible: !base.validTrans
                        text: catalog.i18nc("@error", "Number of mapping characters in the input must be equal to the output!")
                        font: UM.Theme.getFont("default_italic")
                        color: "red"
                        renderType: Text.NativeRendering
                        leftPadding: 25
                    }
                }
            }

        }
    }

    Label {
        id: machineLabel
        anchors.top: parent.top
        anchors.left: parent.left        
        anchors.leftMargin: UM.Theme.getSize("default_margin").width
        text: Cura.MachineManager.activeMachine.name
        horizontalAlignment: Text.AlignHCenter
        font: UM.Theme.getFont("large_bold")
        renderType: Text.NativeRendering
    }
}
