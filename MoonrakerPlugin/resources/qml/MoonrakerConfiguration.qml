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

        Cura.ScrollView {
            id: configurationBase
            anchors.fill: parent
            bottomPadding: machineLabel.height * screenScaleFactor + UM.Theme.getSize("default_margin").width * screenScaleFactor
            scrollAlwaysVisible: false

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
                        x: 15

                        Label {
                            text: catalog.i18nc("@label", "Moonraker Address (URL)")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                        }
                        Label {
                            visible: !base.validUrl
                            text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                            font: UM.Theme.getFont("default_italic")
                            renderType: Text.NativeRendering
                            color: UM.Theme.getColor("error")
                            leftPadding: 15
                        }
                    }
                    Cura.TextField {
                        id: urlField
                        text: manager.printerSettingUrl                 
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
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
                        x: 15
                    }
                    Cura.TextField {
                        id: apiKeyField
                        text: manager.printerSettingAPIKey
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
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
                        x: 15
                    }
                    Cura.TextField {
                        id: powerDeviceField
                        text: manager.printerSettingPowerDevice
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
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
                        x: 15
                    }
                    ButtonGroup {
                        id: outputFormatValue
                    }
                    RowLayout {
                        x: 25

                        Cura.RadioButton {
                            id: outputFormatGcode
                            text: catalog.i18nc("@label", "G-code")
                            checked: manager.printerOutputFormat != "ufp"
                            ButtonGroup.group: outputFormatValue
                            onClicked: { updateConfig() }
                        }
                        Cura.RadioButton {
                            id: outputFormatUfp
                            text: catalog.i18nc("@label", "UFP with Thumbnail")
                            checked: manager.printerOutputFormat == "ufp"
                            ButtonGroup.group: outputFormatValue
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
                        x: 15
                    }
                    Cura.CheckBox {
                        id: uploadRememberStateBox
                        text: catalog.i18nc("@label", "Remember state of \"Start print job\"")
                        font: UM.Theme.getFont("default")
                        x: 25
                        checked: manager.printerUploadRememberState
                        onClicked: { updateConfig() }
                    }
                    Cura.CheckBox {
                        id: uploadAutoHideMessageboxBox
                        text: catalog.i18nc("@label", "Auto hide messagebox for successful upload (30 seconds)")
                        font: UM.Theme.getFont("default")
                        x: 25
                        checked: manager.printerUploadAutoHideMessagebox
                        onClicked: { updateConfig() }
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    RowLayout {
                        x: 15

                        Label {
                            text: catalog.i18nc("@label", "Filename Translation ")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
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
                        x: 25
                        Layout.alignment: Qt.AlignVCenter

                        Label {
                            text: catalog.i18nc("@label", "Input")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            
                        }
                        Rectangle {
                            width: 120
                            implicitHeight: transInputField.implicitHeight

                            Cura.TextField {
                                id: transInputField
                                text: manager.printerTransInput
                                width: parent.width
                                maximumLength: 128
                                onTextChanged: base.validTrans = manager.validTrans(transInputField.text, transOutputField.text)
                                onEditingFinished: { updateConfig() }
                            }
                        }
                        
                        Label {
                            text: catalog.i18nc("@label", "Output")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            leftPadding: 15
                        }                        
                        Rectangle { 
                            width: 120
                            implicitHeight: transOutputField.implicitHeight

                            Cura.TextField {
                                id: transOutputField
                                text: manager.printerTransOutput
                                width: parent.width
                                maximumLength: 128
                                onTextChanged: base.validTrans = manager.validTrans(transInputField.text, transOutputField.text)
                                onEditingFinished: { updateConfig() }
                            }
                        }
                        
                        Label {
                            text: catalog.i18nc("@label", "Remove")
                            font: UM.Theme.getFont("default")
                            color: UM.Theme.getColor("text")
                            renderType: Text.NativeRendering
                            leftPadding: 15
                        }                        
                        Rectangle {
                            width: 120
                            implicitHeight: transRemoveField.implicitHeight

                            Cura.TextField {
                                id: transRemoveField
                                text: manager.printerTransRemove
                                width: parent.width
                                maximumLength: 128
                                onEditingFinished: { updateConfig() }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                    }
                    Label {
                        visible: !base.validTrans
                        text: catalog.i18nc("@error", "Number of mapping characters in the input must be equal to the output!")
                        font: UM.Theme.getFont("default_italic")
                        color: UM.Theme.getColor("error")
                        renderType: Text.NativeRendering
                        x: 25
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
