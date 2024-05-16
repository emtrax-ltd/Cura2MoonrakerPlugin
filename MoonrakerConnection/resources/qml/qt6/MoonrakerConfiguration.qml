import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import UM 1.5 as UM
import Cura 1.1 as Cura

Cura.MachineAction {
    property variant catalog: UM.I18nCatalog { id: catalog; name: "cura" }

    id: base
    anchors.fill: parent
    
    property bool validUrl: true
    property bool validRetryInterval: true
    property bool validFrontendUrl: true
    property bool validTranslation: true

    function outputFormat() {
        return outputFormatUfp.checked ? "ufp" : "gcode"
    }

    function cameraImageRotation() {
        return cameraImageRotation90.checked ? "90" : cameraImageRotation180.checked ? "180" : cameraImageRotation270.checked ? "270" : "0"
    }

    function save(closeDialog) {
        if (removeOnSave.checked) {
            manager.deleteConfig()
        } else {
            manager.saveConfig({
                url: urlField.text,
                api_key: apiKeyField.text,
                power_device: powerDeviceField.text,
                retry_interval: retryIntervalField.text,
                frontend_url: frontendUrlField.text,
                output_format: outputFormat(),
                upload_dialog: uploadDialogVisible.checked,
                upload_start_print_job: uploadStartPrintJobBox.checked,
                upload_remember_state: uploadRememberStateBox.checked,
                upload_autohide_messagebox: uploadAutohideMessageboxBox.checked,
                trans_input: translateInputField.text,
                trans_output: translateOutputField.text,
                trans_remove: translateRemoveField.text,
                camera_url: cameraUrlField.text,
                camera_image_rotation: cameraImageRotation(),
                camera_image_mirror: cameraImageMirror.checked
            })
        }
        removeOnSave.checked = false
        if (closeDialog) {
            actionDialog.close()
        }
    }

    function cancel(closeDialog) {
        removeOnSave.checked = false
        if (closeDialog) {
            actionDialog.close()
        }
    }

    Connections {
        target: actionDialog
        onAccepted: save(false)
        onRejected: cancel(false)
        onClosing: cancel(false)
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

    UM.Label {
        id: machineLabel

        anchors{
            top: parent.top
            left: parent.left        
            leftMargin: UM.Theme.getSize("default_margin").width
        }
        font: UM.Theme.getFont("large_bold")
        text: Cura.MachineManager.activeMachine.name
        horizontalAlignment: Text.AlignHCenter
    }

    UM.TabRow  {
        id: tabBar

        z: 5

        anchors {
            top: machineLabel.bottom
            topMargin: UM.Theme.getSize("default_margin").height
            bottomMargin: UM.Theme.getSize("default_margin").height
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
            bottom: actionButtons.top
            bottomMargin: UM.Theme.getSize("default_margin").height
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

                        RowLayout {
                            width: parent.width
                            x: 15

                            UM.Label {
                                text: catalog.i18nc("@label", "Address (URL)")
                            }
                            UM.Label {
                                visible: !base.validUrl
                                leftPadding: 15
                                font: UM.Theme.getFont("default_italic")
                                color: UM.Theme.getColor("error")
                                text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                            }
                        }
                        Cura.TextField {
                            id: urlField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsUrl
                            maximumLength: 1024
                            onTextChanged: base.validUrl = manager.validUrl(urlField.text)
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "API-Key (Optional - if the network is untrusted)")
                        }
                        Cura.TextField {
                            id: apiKeyField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsApiKey
                            maximumLength: 1024
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "Power Device(s) (Name configured in moonraker.conf)")
                        }
                        Cura.TextField {
                            id: powerDeviceField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsPowerDevice
                            maximumLength: 1024
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            width: parent.width
                            x: 15

                            UM.Label {
                                text: catalog.i18nc("@label", "Retry interval in seconds (Optional - default: 0.5 [20 iterations])")
                            }
                            UM.Label {
                                visible: !base.validRetryInterval
                                leftPadding: 15
                                font: UM.Theme.getFont("default_italic")
                                color: UM.Theme.getColor("error")
                                text: catalog.i18nc("@error", "Value not valid. Example: 0.5 or 2")
                            }
                        }
                        Cura.TextField {
                            id: retryIntervalField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsRetryInterval
                            maximumLength: 1024
                            onTextChanged: base.validRetryInterval = manager.validRetryInterval(retryIntervalField.text)
                        }

                        Item {
                            width: parent.width
                            height: 10
                        }
                        RowLayout {
                            width: parent.width
                            x: 15

                            UM.Label {
                                text: catalog.i18nc("@label", "Frontend (alternative URL instead of Moonraker's address for \"Open Browser\")")
                            }
                            UM.Label {
                                visible: !base.validFrontendUrl
                                leftPadding: 15
                                font: UM.Theme.getFont("default_italic")
                                color: UM.Theme.getColor("error")
                                text: catalog.i18nc("@error", "URL not valid. Example: http://192.168.1.2/")
                            }
                        }
                        Cura.TextField {
                            id: frontendUrlField

                            width: parent.width - 40
                            x: 25
                            text: manager.settingsFrontendUrl
                            maximumLength: 1024
                            onTextChanged: base.validFrontendUrl = manager.validUrl(frontendUrlField.text)
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

                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "Format")
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
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: outputFormatValue

                                id: outputFormatUfp

                                text: catalog.i18nc("@label", "UFP with Thumbnail")
                                checked: manager.settingsOutputFormat == "ufp"
                            }
                        }

        		        Item {
                            width: parent.width
                            height: 10
                        }
                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "Process")
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
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: uploadDialogValue

                                id: uploadDialogBypass

                                text: catalog.i18nc("@label", "Fire & Forget")
                                checked: !manager.settingsUploadDialog
                            }
                        }
                        UM.CheckBox {
                            id: uploadStartPrintJobBox

                            x: 25
                            text: catalog.i18nc("@label", "Automatic start of print job after upload")
                            checked: manager.settingsUploadStartPrintJob
                            visible: uploadDialogBypass.checked
                        }
                        UM.CheckBox {
                            id: uploadRememberStateBox

                            x: 25
                            text: catalog.i18nc("@label", "Remember state of \"Path\" and \"Start print job\"")
                            checked: manager.settingsUploadRememberState
                            visible: uploadDialogVisible.checked
                        }
                        UM.CheckBox {
                            id: uploadAutohideMessageboxBox

                            x: 25
                            text: catalog.i18nc("@label", "Auto hide messagebox for successful upload (30 seconds)")
                            checked: manager.settingsUploadAutohideMessagebox
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
                                leftPadding: 25
                                font: UM.Theme.getFont("default_italic")
                                color: "gray"
                                text: catalog.i18nc("@label", "filename.translate(filename.maketrans(input[], output[], remove[])")
                            }
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            x: 25

                            UM.Label {
                                text: catalog.i18nc("@label", "Input")
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
                                }
                            }
                        
                            UM.Label {
                                leftPadding: 15
                                text: catalog.i18nc("@label", "Output")
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
                                }
                            }
                        
                            UM.Label {
                                leftPadding: 15
                                text: catalog.i18nc("@label", "Remove")
                            }                        
                            Rectangle {
                                width: 120
                                implicitHeight: translateRemoveField.implicitHeight

                                Cura.TextField {
                                    id: translateRemoveField

                                    width: parent.width
                                    text: manager.settingsTranslateRemove
                                    maximumLength: 128
                                }
                            }
                        }

                        Item {
                            width: parent.width
                        }
                        UM.Label {
                            visible: !base.validTranslation
                            x: 25
                            font: UM.Theme.getFont("default_italic")
                            color: UM.Theme.getColor("error")
                            text: catalog.i18nc("@error", "Number of mapping characters in the input must be equal to the output!")
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

                        UM.Label {
                            x: 15
                            text: catalog.i18nc("@label", "Camera")
                        }

                        UM.Label {
                            x: 25
                            text: catalog.i18nc("@label", "URL (absolute or path relative to Connection-URL)")
                        }
                        Cura.TextField {
                            id: cameraUrlField

                            width: parent.width - 40
                            x: 35
                            text: manager.settingsCameraUrl                 
                            maximumLength: 1024
                        }

                        ButtonGroup {
                            id: cameraImageRotationValue
                        }
                        RowLayout {
                            x: 25

                            Cura.RadioButton {
                                ButtonGroup.group: cameraImageRotationValue

                                id: cameraImageRotation0

                                text: catalog.i18nc("@label", "0°")
                                checked: !(manager.settingsCameraImageRotation == "90" || manager.settingsCameraImageRotation == "180" || manager.settingsCameraImageRotation == "270")
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: cameraImageRotationValue

                                id: cameraImageRotation90

                                text: catalog.i18nc("@label", "90°")
                                checked: manager.settingsCameraImageRotation == "90"
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: cameraImageRotationValue

                                id: cameraImageRotation180

                                text: catalog.i18nc("@label", "180°")
                                checked: manager.settingsCameraImageRotation == "180"
                            }
                            Cura.RadioButton {
                                ButtonGroup.group: cameraImageRotationValue

                                id: cameraImageRotation270

                                text: catalog.i18nc("@label", "270°")
                                checked: manager.settingsCameraImageRotation == "270"
                            }
                            UM.Label {
                                text: catalog.i18nc("@label", " Rotation")
                            }
                        }
                        UM.CheckBox {
                            id: cameraImageMirror

                            x: 25
                            text: catalog.i18nc("@label", "Mirror")
                            checked: manager.settingsCameraImageMirror
                        }
                    }
                }
 
            }
        }
    }

    Item {
        id: actionButtons
        
        anchors{
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: UM.Theme.getSize("default_margin").height
            bottomMargin: UM.Theme.getSize("default_margin").height
        }

        Flow  {
            Layout.fillWidth: true
            layoutDirection: Qt.RightToLeft 
            anchors.fill: parent
            spacing: UM.Theme.getSize("default_margin").width

            Cura.SecondaryButton {
                id: cancelButton
                text: catalog.i18nc("@action:button", "Cancel")
                onClicked: { cancel(true) }
            }

            Cura.PrimaryButton {
                id: saveButton
                text: catalog.i18nc("@action:button", "Save")
                visible: manager.settingsExists
                onClicked: { save(true) }
            }

            Cura.PrimaryButton {
                id: createButton
                text: catalog.i18nc("@action:button", "Create")
                visible: !manager.settingsExists
                onClicked: { save(true) }
            }

            UM.CheckBox {
                id: removeOnSave
                text: catalog.i18nc("@label", "Remove connection")
                checked: false
                visible: manager.settingsExists
            }
        }
    }
}
