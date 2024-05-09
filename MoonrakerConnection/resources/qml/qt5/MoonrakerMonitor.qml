import QtQuick 2.10
import QtQuick.Controls 2.3

import UM 1.5 as UM
import Cura 1.1 as Cura

Component {
    id: monitorItem

    Item {

        Cura.RoundedRectangle {
            id: mainPanel

            anchors {
                top: parent.top
                topMargin: UM.Theme.getSize("default_margin").height
                bottom: parent.bottom
                bottomMargin: UM.Theme.getSize("default_margin").height
                left: parent.left
                right: sidebarPanel.left
                rightMargin: UM.Theme.getSize("default_margin").width
            }
            border{
                width: UM.Theme.getSize("default_lining").width
                color: UM.Theme.getColor("lining")
            }
            color: UM.Theme.getColor("main_background")
            radius: UM.Theme.getSize("default_radius").width
            cornerSide: Cura.RoundedRectangle.Direction.Left

            property bool cameraConfigured: OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null && OutputDevice.activePrinter.cameraUrl != ""

            Label {
                id: cameraLabel

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                color: UM.Theme.getColor(parent.cameraConfigured ? "text" : "text_inactive")
                font: UM.Theme.getFont("large_bold")
                text: parent.cameraConfigured ? "Camera" : "Camera not configured"
            }
            Label {                
                id: cameraLabelUrl

                visible: parent.cameraConfigured
                anchors {
                    horizontalCenter: cameraLabel.horizontalCenter
                    top: cameraLabel.bottom
                }
                color: UM.Theme.getColor("text_inactive")
                font: UM.Theme.getFont("small")
                text: "Url: " + (parent.cameraConfigured ? OutputDevice.activePrinter.cameraUrl : "None")
            }

            Cura.NetworkMJPGImage {
                property bool imageRotated: OutputDevice.activePrinter.cameraImageRotation == "90" || OutputDevice.activePrinter.cameraImageRotation == "270"
                property real maxViewWidth: parent.width - 2 * UM.Theme.getSize("default_margin").width
                property real maxViewHeight: parent.height - 2 * UM.Theme.getSize("default_margin").height
                property real scaleFactor: {
                    if (imageRotated) {
                        Math.min(Math.min(maxViewWidth / imageHeight, maxViewHeight / imageWidth), 2)
                    } else {
                        Math.min(Math.min(maxViewWidth / imageWidth, maxViewHeight / imageHeight), 2)
                    }
                }

                id: cameraImage
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                width: Math.floor(imageWidth * scaleFactor)
                height: Math.floor(imageHeight * scaleFactor)
                source: parent.cameraConfigured ? OutputDevice.activePrinter.cameraUrl : ""
                rotation:  OutputDevice.activePrinter.cameraImageRotation
                mirror: OutputDevice.activePrinter.cameraImageMirror
                onVisibleChanged: {
                    if (source != "") {
                        if (visible) {
                            start()
                        } else {
                            stop()
                        }
                    }
                }
                Component.onCompleted: {
                    if (source != "") {
                        start()
                    }
                }
            }
        }

        Cura.RoundedRectangle {
            id: sidebarPanel

            anchors {
                right: parent.right
                top: parent.top
                topMargin: UM.Theme.getSize("default_margin").height
                bottom: actionsPanel.top
                bottomMargin: UM.Theme.getSize("default_margin").height
            }
            border {
                width: UM.Theme.getSize("default_lining").width
                color: UM.Theme.getColor("lining")
            }
            width: UM.Theme.getSize("print_setup_widget").width
            color: UM.Theme.getColor("main_background")
            radius: UM.Theme.getSize("default_radius").width
            cornerSide: Cura.RoundedRectangle.Direction.Left

            Label {
                id: outputDeviceNameLabel
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: UM.Theme.getSize("default_margin").width
                }
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("large_bold")
                text: OutputDevice != null ? OutputDevice.activePrinter.name : ""
            }

            /*Cura.PrintMonitor {
                id: printMonitor

                anchors {
                    top: parent.top
                    topMargin: UM.Theme.getSize("default_margin").height
                    bottom: parent.bottom
                    leftMargin: UM.Theme.getSize("default_margin").width
                    right: parent.right
                    rightMargin: UM.Theme.getSize("default_margin").width
                }
                width: UM.Theme.getSize("print_setup_widget").width - UM.Theme.getSize("default_margin").width * 2
            }*/


        }

        Cura.RoundedRectangle {
            id: actionsPanel

            anchors {
                topMargin: UM.Theme.getSize("default_margin").height
                bottom: parent.bottom
                bottomMargin: UM.Theme.getSize("default_margin").width
                right: parent.right
            }
            border {
                width: UM.Theme.getSize("default_lining").width
                color: UM.Theme.getColor("lining")
            }
            width: UM.Theme.getSize("print_setup_widget").width
            height: 100 * screenScaleFactor /* monitorButton.height */
            color: UM.Theme.getColor("main_background")
            radius: UM.Theme.getSize("default_radius").width
            cornerSide: Cura.RoundedRectangle.Direction.Left            

            /*Cura.MonitorButton {
                id: monitorButton

                anchors {
                    top: parent.top
                    topMargin: UM.Theme.getSize("default_margin").height
                    bottomMargin: UM.Theme.getSize("default_margin").height
                }
                width: parent.width
            }*/
        }
    }
}