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
    property bool validFrontendUrl: true
    property bool validTranslation: true

    function outputFormat() {
        return outputFormatUfp.checked ? "ufp" : "gcode"
    }

    function updateConfig() {
        manager.saveConfig({
            url: urlField.text,
            api_key: apiKeyField.text,
            power_device: powerDeviceField.text,
            frontend_url: frontendUrlField.text,
            output_format: outputFormat(),
            upload_dialog: uploadDialogVisible.checked,
            upload_start_print_job: uploadStartPrintJobBox.checked,
            upload_remember_state: uploadRememberStateBox.checked,
            upload_autohide_messagebox: uploadAutohideMessageboxBox.checked,
            trans_input: translateInputField.text,
            trans_output: translateOutputField.text,
            trans_remove: translateRemoveField.text,
            camera_url: cameraUrlField.text
        })
    }

    ListModel {
        id: tabNameModel

        Component.onCompleted: update()

        function update() {
            clear()
            append({ name: catalog.i18nc("@title:tab", "Connection") })
            append({ name: catalog.i18nc("@title:tab", "Upload") })
            append({ name: catalog.i18nc("@title:tab", "Monitor") })

        }
    }

    Label {
        id: machineLabel

        anchors{
            top: parent.top
            left: parent.left        
            leftMargin: UM.Theme.getSize("default_margin").width
        }
        color: UM.Theme.getColor("text")
        font: UM.Theme.getFont("large_bold")
        text: Cura.MachineManager.activeMachine.name
        horizontalAlignment: Text.AlignHCenter
        renderType: Text.NativeRendering
    }

    UM.TabRow  {
        id: tabBar

        z: 5

        anchors {
            top: machineLabel.bottom
            topMargin: UM.Theme.getSize("default_margin").height
        }
        width: parent.width

        Repeater {
            model: tabNameModel
            delegate: UM.TabRowButton {
                checked: model.index == 0
                text: model.name
            }
        }
    }

    Cura.RoundedRectangle {
        id: tabView

        anchors {
            top: tabBar.bottom
            topMargin: -UM.Theme.getSize("default_lining").height
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        border {
            color: UM.Theme.getColor("lining")
            width: UM.Theme.getSize("default_lining").width
        }
        color: UM.Theme.getColor("main_background")
        radius: UM.Theme.getSize("default_radius").width
        cornerSide: Cura.RoundedRectangle.Direction.Down

        StackLayout {
            id: tabStack

            anchors.fill: parent
            currentIndex: tabBar.currentIndex

            Item {
                id: connectionPane

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

                        spacing: UM.Theme.getSize("default_margin").height

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            width: parent.width
                            x: 15

                            Label {                         
                                color: UM.Theme.getColor("text")
                                font: UM.Theme.getFont("default")       
                                text: catalog.i18nc("@label", "Address (URL)")
                                renderType: Text.NativeRendering
                            }
                            Label {
                                visible: !base.validUrl
                                leftPadding: 15
                                color: UM.Theme.getColor("error")
                                font: UM.Theme.getFont("default_italic")
                                text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                                renderType: Text.NativeRendering
                            }
                        }
                        Cura.TextField {
                            id: urlField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsUrl
                            maximumLength: 1024
                            onTextChanged: base.validUrl = manager.validUrl(urlField.text)
                            onEditingFinished: { updateConfig() }
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        Label {
                            x: 15
                            color: UM.Theme.getColor("text")
                            font: UM.Theme.getFont("default")       
                            text: catalog.i18nc("@label", "API-Key (Optional - if the network is untrusted)")
                            renderType: Text.NativeRendering
                        }
                        Cura.TextField {
                            id: apiKeyField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsApiKey
                            maximumLength: 1024
                            onEditingFinished: { updateConfig() }
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        Label {
                            x: 15
                            color: UM.Theme.getColor("text")
                            font: UM.Theme.getFont("default")       
                            text: catalog.i18nc("@label", "Power Device(s) (Name configured in moonraker.conf)")
                            renderType: Text.NativeRendering
                        }
                        Cura.TextField {
                            id: powerDeviceField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsPowerDevice
                            maximumLength: 1024
                            onEditingFinished: { updateConfig() }
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            width: parent.width
                            x: 15

                            Label {                         
                                color: UM.Theme.getColor("text")
                                font: UM.Theme.getFont("default")       
                                text: catalog.i18nc("@label", "Frontend (alternative URL instead of Moonraker's address for \"Open Browser\")")
                                renderType: Text.NativeRendering
                            }
                            Label {
                                visible: !base.validFrontendUrl
                                leftPadding: 15
                                color: UM.Theme.getColor("error")
                                font: UM.Theme.getFont("default_italic")
                                text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                                renderType: Text.NativeRendering
                            }
                        }
                        Cura.TextField {
                            id: frontendUrlField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsFrontendUrl
                            maximumLength: 1024
                            onTextChanged: base.validFrontendUrl = manager.validUrl(frontendUrlField.text)
                            onEditingFinished: { updateConfig() }
                        }
                    }
                }
            }
            
            Item {
                id: processPane

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

                        spacing: UM.Theme.getSize("default_margin").height

                        Item {
                         width: parent.width
                            height: 10
                        }
                        Label {
                            x: 15
                            color: UM.Theme.getColor("text")
                            font: UM.Theme.getFont("default")       
                            text: catalog.i18nc("@label", "Format")
                            renderType: Text.NativeRendering
                        }
                        ButtonGroup {
                            id: outputFormatValue
                        }
                        RowLayout {
                            x: 25

                            Cura.RadioButton {
                                ButtonGroup.group: outputFormatValue

                                id: outputFormatGcode

                                text: catalog.i18nc("@label", "G-code")
                                checked: manager.settingsOutputFormat != "ufp"
                                onClicked: { updateConfig() }
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: outputFormatValue

                                id: outputFormatUfp

                                text: catalog.i18nc("@label", "UFP with Thumbnail")
                                checked: manager.settingsOutputFormat == "ufp"
                                onClicked: { updateConfig() }
                            }
                        }

        		        Item {
                            width: parent.width
                            height: 10
                        }
                        Label {
                            x: 15
                            color: UM.Theme.getColor("text")
                            font: UM.Theme.getFont("default")       
                            text: catalog.i18nc("@label", "Process")
                            renderType: Text.NativeRendering
                        }
                        ButtonGroup {
                            id: uploadDialogValue
                        }
                        RowLayout {
                            x: 25

                            Cura.RadioButton {
                                ButtonGroup.group: uploadDialogValue

                                id: uploadDialogVisible

                                text: catalog.i18nc("@label", "Upload Dialog")
                                checked: manager.settingsUploadDialog
                                onClicked: { updateConfig() }
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: uploadDialogValue

                                id: uploadDialogBypass

                                text: catalog.i18nc("@label", "Fire & Forget")
                                checked: !manager.settingsUploadDialog
                                onClicked: { updateConfig() }
                            }
                        }
                        Cura.CheckBox {
                            id: uploadStartPrintJobBox

                            x: 25
                            height: UM.Theme.getSize("checkbox").height
                            font: UM.Theme.getFont("default")

                            text: catalog.i18nc("@label", "Automatic start of print job after upload")
                            checked: manager.settingsUploadStartPrintJob
                            visible: uploadDialogOverride.checked
                            onClicked: { updateConfig() }
                        }
                        Cura.CheckBox {
                            id: uploadRememberStateBox

                            x: 25
                            height: UM.Theme.getSize("checkbox").height
                            font: UM.Theme.getFont("default")

                            text: catalog.i18nc("@label", "Remember state of \"Start print job\"")
                            checked: manager.settingsUploadRememberState
                            visible: uploadDialogVisible.checked
                            onClicked: { updateConfig() }
                        }
                        Cura.CheckBox {
                            id: uploadAutohideMessageboxBox

                            x: 25
                            height: UM.Theme.getSize("checkbox").height
                            font: UM.Theme.getFont("default")
                            text: catalog.i18nc("@label", "Auto hide messagebox for successful upload (30 seconds)")
                            checked: manager.settingsUploadAutohideMessagebox
                        onClicked: { updateConfig() }
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            x: 15

                            Label {
                                color: UM.Theme.getColor("text")
                                font: UM.Theme.getFont("default")       
                                text: catalog.i18nc("@label", "Filename Translation ")
                                renderType: Text.NativeRendering
                            }
                            Label {
                                leftPadding: 25
                                color: "gray"
                                font: UM.Theme.getFont("default_italic")
                                text: catalog.i18nc("@label", "filename.translate(filename.maketrans(input[], output[], remove[])")
                                renderType: Text.NativeRendering
                            }
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            x: 25

                            Label {
                                color: UM.Theme.getColor("text")
                                font: UM.Theme.getFont("default")       
                                text: catalog.i18nc("@label", "Input")
                                renderType: Text.NativeRendering
                            }
                            Rectangle {
                                width: 120
                                implicitHeight: translateInputField.implicitHeight

                                Cura.TextField {
                                    id: translateInputField

                                    width: parent.width
                                    text: manager.settingsTranslateInput
                                    maximumLength: 128
                                    onTextChanged: base.validTranslation = manager.validTranslation(translateInputField.text, translateOutputField.text)
                                    onEditingFinished: { updateConfig() }
                                }
                            }
                        
                            Label {
                                leftPadding: 15
                                color: UM.Theme.getColor("text")
                                font: UM.Theme.getFont("default")       
                                text: catalog.i18nc("@label", "Output")
                                renderType: Text.NativeRendering
                            }                        
                            Rectangle { 
                                width: 120
                                implicitHeight: translateOutputField.implicitHeight

                                Cura.TextField {
                                    id: translateOutputField
                                
                                    width: parent.width
                                    text: manager.settingsTranslateOutput
                                    maximumLength: 128
                                    onTextChanged: base.validTranslation = manager.validTranslation(translateInputField.text, translateOutputField.text)
                                    onEditingFinished: { updateConfig() }
                                }
                            }
                        
                            Label {
                                leftPadding: 15
                                color: UM.Theme.getColor("text")
                                font: UM.Theme.getFont("default")       
                                text: catalog.i18nc("@label", "Remove")
                                renderType: Text.NativeRendering
                            }                        
                            Rectangle {
                                width: 120
                                implicitHeight: translateRemoveField.implicitHeight

                                Cura.TextField {
                                    id: translateRemoveField

                                    width: parent.width
                                    text: manager.settingsTranslateRemove
                                    maximumLength: 128
                                    onEditingFinished: { updateConfig() }
                                }
                            }
                        }

                        Item {
                            width: parent.width
                        }
                        Label {
                            visible: !base.validTranslation
                            x: 25
                            color: UM.Theme.getColor("error")
                            font: UM.Theme.getFont("default_italic")
                            text: catalog.i18nc("@error", "Number of mapping characters in the input must be equal to the output!")
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }

            Item {
                id: monitorPane

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

                        spacing: UM.Theme.getSize("default_margin").height

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            width: parent.width
                            x: 15

                            Label {
                                text: catalog.i18nc("@label", "Camera (URL - absolute or path relative to Connection-URL)")
                                font: UM.Theme.getFont("default")
                                color: UM.Theme.getColor("text")
                                renderType: Text.NativeRendering
                            }
                        }
                        Cura.TextField {
                            id: cameraUrlField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsCameraUrl                 
                            maximumLength: 1024
                            onEditingFinished: { updateConfig() }
                        }

                    }
                }
 
            }
        }
    }

}
