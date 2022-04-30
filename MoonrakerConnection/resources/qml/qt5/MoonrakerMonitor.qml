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

            Label {
                id: cameraLabel

                anchors {
                    horizontalCenter: parent.horizontalCenter;
                    verticalCenter: parent.verticalCenter;
                }
                color: UM.Theme.getColor(OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null && OutputDevice.activePrinter.cameraUrl != "" ? "text" : "text_inactive")
                font: UM.Theme.getFont("large_bold")
                text: OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null && OutputDevice.activePrinter.cameraUrl != "" ? "Camera" : "Camera not configured"
            }
            Label {                
                id: cameraLabelUrl

                visible: OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null && OutputDevice.activePrinter.cameraUrl != ""
                anchors {
                    horizontalCenter: cameraLabel.horizontalCenter;
                    top: cameraLabel.bottom;
                }
                color: UM.Theme.getColor("text_inactive")
                font: UM.Theme.getFont("small")
                text: "Url: " + (OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null ? OutputDevice.activePrinter.cameraUrl : "Null")
            }

            Cura.NetworkMJPGImage { 
                property real scale: Math.min(Math.min((parent.width - 2 * UM.Theme.getSize("default_margin").width) / imageWidth, (parent.height - 2 * UM.Theme.getSize("default_margin").height) / imageHeight), 2);

                id: cameraImage;
                anchors {
                    horizontalCenter: parent.horizontalCenter;
                    verticalCenter: parent.verticalCenter;
                }
                width: Math.floor(imageWidth * scale)
                height: Math.floor(imageHeight * scale)
                source: OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null ? OutputDevice.activePrinter.cameraUrl : ""
                onVisibleChanged: {
                    if (visible) {
                        if (OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null) {
                            cameraImage.start();
                        }
                    } else {
                        if (OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null) {
                            cameraImage.stop();
                        }
                    }
                }
                Component.onCompleted: {
                    if (OutputDevice.activePrinter != null && OutputDevice.activePrinter.cameraUrl != null) {
                        cameraImage.start();
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