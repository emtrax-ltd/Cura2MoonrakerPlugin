import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import UM 1.5 as UM
import Cura 1.1 as Cura

Cura.MachineAction {

    UM.I18nCatalog { id: catalog; name: "cura" }

    id: base
    anchors.fill: parent
    
    property bool validUrl: true
    property bool validTranslation: true

    function outputFormat() {
        return outputFormatUfp.checked ? "ufp" : "gcode"
    }

    function updateConfig() {
        manager.saveConfig({
            url: urlField.text,
            api_key: apiKeyField.text,
            power_device: powerDeviceField.text,
            output_format: outputFormat(),
            upload_remember_state: uploadRememberStateBox.checked,
            upload_autohide_messagebox: uploadAutohideMessageboxBox.checked,
            trans_input: translateInputField.text,
            trans_output: translateOutputField.text,
            trans_remove: translateRemoveField.text
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

                    UM.Label {
                        id: connectionLabel
                        text: catalog.i18nc("@title:label", "Connection")
                        font: UM.Theme.getFont("medium_bold")
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

                        UM.Label {
                            text: catalog.i18nc("@label", "Moonraker Address (URL)")
                        }
                        UM.Label {
                            visible: !base.validUrl
                            text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                            font: UM.Theme.getFont("default_italic")
                            color: UM.Theme.getColor("error")
                            leftPadding: 15
                        }
                    }
                    Cura.TextField {
                        id: urlField
                        text: manager.settingsUrl                 
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
                    UM.Label {
                        text: catalog.i18nc("@label", "API-Key (Optional - if the network is untrusted)")
                        x: 15
                    }
                    Cura.TextField {
                        id: apiKeyField
                        text: manager.settingsApiKey
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
                        onEditingFinished: { updateConfig() }
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    UM.Label {
                        text: catalog.i18nc("@label", "Name of Moonraker Power Device(s) in moonraker.conf")
                        x: 15
                    }
                    Cura.TextField {
                        id: powerDeviceField
                        text: manager.settingsPowerDevice
                        maximumLength: 1024
                        width: parent.width - 40
                        x: 25
                        onEditingFinished: { updateConfig() }
                    }

                    UM.Label {
                        text: catalog.i18nc("@title:label", "Upload")
                        font: UM.Theme.getFont("medium_bold")
                        width: parent.width
                        topPadding: 25
                        elide: Text.ElideRight
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    UM.Label {
                        text: catalog.i18nc("@label", "Format")
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
                            checked: manager.settingsOutputFormat != "ufp"
                            ButtonGroup.group: outputFormatValue
                            onClicked: { updateConfig() }
                        }
                        Cura.RadioButton {
                            id: outputFormatUfp
                            text: catalog.i18nc("@label", "UFP with Thumbnail")
                            checked: manager.settingsOutputFormat == "ufp"
                            ButtonGroup.group: outputFormatValue
                            onClicked: { updateConfig() }
                        }
                    }

        		    Item {
                        width: parent.width
                        height: 10
                    }
                    UM.Label {
                        text: catalog.i18nc("@label", "Process")
                        x: 15
                    }
                    UM.CheckBox {
                        id: uploadRememberStateBox
                        text: catalog.i18nc("@label", "Remember state of \"Start print job\"")
                        x: 25
                        checked: manager.settingsUploadRememberState
                        onClicked: { updateConfig() }
                    }
                    UM.CheckBox {
                        id: uploadAutohideMessageboxBox
                        text: catalog.i18nc("@label", "Auto hide messagebox for successful upload (30 seconds)")
                        x: 25
                        checked: manager.settingsUploadAutohideMessagebox
                        onClicked: { updateConfig() }
                    }

                    Item {
                        width: parent.width
                        height: 10
                    }
                    RowLayout {
                        x: 15

                        UM.Label {
                            text: catalog.i18nc("@label", "Filename Translation ")
                        }
                        UM.Label {
                            text: catalog.i18nc("@label", "filename.translate(filename.maketrans(input[], output[], remove[])")
                            font: UM.Theme.getFont("default_italic")
                            color: "gray"
                            leftPadding: 25
                        }
                    }
                    RowLayout {
                        x: 25
                        Layout.alignment: Qt.AlignVCenter

                        UM.Label {
                            text: catalog.i18nc("@label", "Input")
                            
                        }
                        Rectangle {
                            width: 120
                            implicitHeight: translateInputField.implicitHeight

                            Cura.TextField {
                                id: translateInputField
                                text: manager.settingsTranslateInput
                                width: parent.width
                                maximumLength: 128
                                onTextChanged: base.validTranslation = manager.validTranslation(translateInputField.text, translateOutputField.text)
                                onEditingFinished: { updateConfig() }
                            }
                        }
                        
                        UM.Label {
                            text: catalog.i18nc("@label", "Output")
                            leftPadding: 15
                        }                        
                        Rectangle { 
                            width: 120
                            implicitHeight: translateOutputField.implicitHeight

                            Cura.TextField {
                                id: translateOutputField
                                text: manager.settingsTranslateOutput
                                width: parent.width
                                maximumLength: 128
                                onTextChanged: base.validTranslation = manager.validTranslation(translateInputField.text, translateOutputField.text)
                                onEditingFinished: { updateConfig() }
                            }
                        }
                        
                        UM.Label {
                            text: catalog.i18nc("@label", "Remove")
                            leftPadding: 15
                        }                        
                        Rectangle {
                            width: 120
                            implicitHeight: translateRemoveField.implicitHeight

                            Cura.TextField {
                                id: translateRemoveField
                                text: manager.settingsTranslateRemove
                                width: parent.width
                                maximumLength: 128
                                onEditingFinished: { updateConfig() }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                    }
                    UM.Label {
                        visible: !base.validTranslation
                        text: catalog.i18nc("@error", "Number of mapping characters in the input must be equal to the output!")
                        font: UM.Theme.getFont("default_italic")
                        color: UM.Theme.getColor("error")
                        x: 25
                    }
                }
            }

        }
    }

    UM.Label {
        id: machineLabel
        anchors.top: parent.top
        anchors.left: parent.left        
        anchors.leftMargin: UM.Theme.getSize("default_margin").width
        text: Cura.MachineManager.activeMachine.name
        horizontalAlignment: Text.AlignHCenter
        font: UM.Theme.getFont("large_bold")
    }
}
