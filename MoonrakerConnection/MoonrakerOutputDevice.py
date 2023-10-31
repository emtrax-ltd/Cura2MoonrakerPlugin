import json
import os.path
import urllib.parse
from enum import Enum
from io import BytesIO, StringIO
from typing import cast
from time import sleep

USE_QT5 = False
try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6   
    CuraSDKVersion = "6.0.0"
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import QByteArray, QObject, QUrl, QVariant, pyqtSlot, pyqtProperty
    from PyQt6.QtGui import QDesktopServices
    from PyQt6.QtNetwork import QNetworkRequest, QNetworkReply, QHttpMultiPart, QHttpPart
else:
    from PyQt5.QtCore import QByteArray, QObject, QUrl, QVariant, pyqtSlot, pyqtProperty
    from PyQt5.QtGui import QDesktopServices
    from PyQt5.QtNetwork import QNetworkRequest, QNetworkReply, QHttpMultiPart, QHttpPart
    USE_QT5 = True

from cura.CuraApplication import CuraApplication
from cura.PrinterOutput.PrinterOutputDevice import PrinterOutputDevice, ConnectionType

from UM.i18n import i18nCatalog
from UM.Logger import Logger
from UM.Mesh.MeshWriter import MeshWriter
from UM.Message import Message
from UM.OutputDevice import OutputDeviceError

from .MoonrakerOutputController import MoonrakerOutputController
from .MoonrakerOutputModel import MoonrakerOutputModel
from .MoonrakerSettings import getConfig, saveConfig, validateUrl

try:
	NoError = QNetworkReply.NetworkError.NoError
	FormDataType = QHttpMultiPart.ContentType.FormDataType
	ContentDispositionHeader = QNetworkRequest.KnownHeaders.ContentDispositionHeader
	ContentTypeHeader = QNetworkRequest.KnownHeaders.ContentTypeHeader
except AttributeError:
	NoError = 0
	FormDataType = QHttpMultiPart.FormDataType
	ContentDispositionHeader = QNetworkRequest.ContentDispositionHeader
	ContentTypeHeader = QNetworkRequest.ContentTypeHeader

catalog = i18nCatalog("cura")
spinner = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']

class OutputStage(Enum):
    Ready = 0
    Writing = 1

class MoonrakerOutputDevice(PrinterOutputDevice):
    def __init__(self, deviceId: str, canConnect: bool = True) -> None:
        super().__init__(device_id = "MoonrakerOutputDevice@" + deviceId, connection_type = ConnectionType.NetworkConnection if canConnect else ConnectionType.NotConnected)
        # init controller and model for output
        globalContainerStack = CuraApplication.getInstance().getGlobalContainerStack()
        self._printers = [MoonrakerOutputModel(output_controller = MoonrakerOutputController(self), number_of_extruders = globalContainerStack.getProperty("machine_extruder_count", "value"))];
        Logger.log("d", "number_of_extruders: {}".format(globalContainerStack.getProperty("machine_extruder_count", "value")))
        self._printers[0].updateName(globalContainerStack.getName());
        self._printers[0].updateUniqueName(globalContainerStack.getId())
        self._printers[0].updateBuildplate(globalContainerStack.getProperty("machine_buildplate_type", "value"))
        # configure ui components
        if canConnect:
            self._monitor_view_qml_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'resources', "qml", 'qt5' if USE_QT5 else 'qt6', "MoonrakerMonitor.qml")
            #self._control_view_qml_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'resources', "qml", 'qt5' if USE_QT5 else 'qt6', "MoonrakerControl.qml")
            globalContainerStack.setMetaDataEntry("group_name", globalContainerStack.getName())
        self._config = None
        self._stage = OutputStage.Ready
        Logger.log("d", "MoonrakerOutputDevice [canConnect: {}] for printer '{}' created.".format(canConnect, deviceId))

    def requestWrite(self, node, fileName: str = None, *args, **kwargs) -> None:
        if not self._canConnect:
            message = Message("To configure your Moonraker printer go to:\n→ Settings\n→ Printer\n→ Manage Printers\n→ select your printer\n→ click on 'Connect Moonraker'", lifetime = 30, title = "Configure Moonraker in Preferences!")
            message.show()
            self.writeSuccess.emit(self)
            return
        
        if self._stage != OutputStage.Ready:
            raise OutputDeviceError.DeviceBusyError()

        # Make sure post-processing plugin are run on the gcode
        self.writeStarted.emit(self)

        # The presliced print should always be send using `GCodeWriter`
        printInformation = CuraApplication.getInstance().getPrintInformation()
        pluginRegistry = CuraApplication.getInstance().getPluginRegistry()
        if self._outputFormat != "ufp" or not printInformation or printInformation.preSliced:
            self._outputFormat = "gcode"
            meshWriter = cast(MeshWriter, pluginRegistry.getPluginObject("GCodeWriter"))
            self._stream = StringIO()
        else:
            meshWriter = cast(MeshWriter, pluginRegistry.getPluginObject("UFPWriter"))
            self._stream = BytesIO()

        if not meshWriter.write(self._stream, None):
            Logger.log("e", "MeshWriter failed: %s" % meshWriter.getInformation())
            return

        # Prepare filename for upload
        if fileName:
            fileName = os.path.basename(fileName)
        else:
            fileName = "%s." % printInformation.jobName
        
        # Translate filename
        if self._translateInput and self._translateOutput:
            translatedFileName = fileName.translate(fileName.maketrans(self._translateInput, self._translateOutput, self._translateRemove if self._translateRemove else ""))
            fileName = translatedFileName

        self._fileName = fileName  + "." + self._outputFormat

        if self._uploadDialog:
            # Display upload dialog
            qmlUrl = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'resources', 'qml', 'qt5' if USE_QT5 else 'qt6', 'MoonrakerUpload.qml')        
            self._dialog = CuraApplication.getInstance().createQmlComponent(qmlUrl, {"manager": self})
            self._dialog.textChanged.connect(self._onUploadFilenameChanged)
            self._dialog.accepted.connect(self._onUploadFilenameAccepted)
            self._dialog.show()
            self._dialog.findChild(QObject, "nameField").setProperty('text', self._fileName)
            self._dialog.findChild(QObject, "nameField").select(0, len(self._fileName) - len(self._outputFormat) - 1)
            self._dialog.findChild(QObject, "nameField").setProperty('focus', True)
            self._dialog.findChild(QObject, "printField").setProperty('checked', self._uploadStartPrintJob)
        else:
            # Bypass upload dialog
            self._onUploadFilenameAccepted()

    def updateConfig(self, config: dict = None) -> None:
        if self._stage != OutputStage.Ready:
            raise OutputDeviceError.DeviceBusyError();

        if not config:
            config = getConfig()

        if self._config != config:
            self._config = config
            # Resolve config items
            self._url = self._config.get("url", "").strip()
            self._apiKey = self._config.get("api_key", "").strip()
            self._powerDevice = self._config.get("power_device", "").strip()
            self._retryInterval = self._config.get("retry_interval", "").strip()
            self._frontendUrl = self._config.get("frontend_url", self._url).strip()
            self._outputFormat = self._config.get("output_format", "gcode")
            if self._outputFormat and self._outputFormat != "ufp":
                self._outputFormat = "gcode"
            self._uploadDialog = self._config.get("upload_dialog", True)
            self._uploadStartPrintJob = self._config.get("upload_start_print_job", False)
            self._uploadRememberState = self._config.get("upload_remember_state", False)
            self._uploadAutohideMessagebox = self._config.get("upload_autohide_messagebox", False)
            self._translateInput = self._config.get("trans_input", "")
            self._translateOutput = self._config.get("trans_output", "")
            self._translateRemove = self._config.get("trans_remove", "")
            self._cameraUrl = self._config.get("camera_url", "").strip()
            self._cameraImageRotation = self._config.get("camera_image_rotation", "0")
            self._cameraImageMirror = self._config.get("camera_image_mirror", False)

            # Configure address and webcam
            self._address = self._url            
            if self._cameraUrl != "":
                cameraUrl = QUrl(self._cameraUrl)
                if cameraUrl.isRelative():
                    _cameraUrl = QUrl(self._address)
                    _cameraUrl.setQuery(cameraUrl.query())
                    if cameraUrl.path().startswith("/"):
                        _cameraUrl.setPath(cameraUrl.path())
                    else:
                        _cameraUrl.setPath(_cameraUrl.path() + cameraUrl.path())
                    cameraUrl = _cameraUrl
                self.activePrinter.setCameraUrl(cameraUrl)
            else:
                self.activePrinter.setCameraUrl(QUrl())
            self.activePrinter.setCameraImageRotation(self._cameraImageRotation)
            self.activePrinter.setCameraImageMirror(self._cameraImageMirror)

            # Configure ui components
            globalContainerStack = CuraApplication.getInstance().getGlobalContainerStack()
            self.setName(globalContainerStack.getName())
            self._canConnect = True if self._connection_type == ConnectionType.NetworkConnection and validateUrl(self._url) else False
            if self._canConnect:
                description = catalog.i18nc("@action:button", "Upload to {0}").format(globalContainerStack.getName())
                self.setDescription(description)               
                self.setShortDescription(description)
                self.setIconName("print")
                self.setConnectionText(catalog.i18nc("@info:status", "Connected via Moonraker"))
                self.setPriority(5)
                Logger.log("i", "Configuration for printer '{}' updated [url: {}, api-key: {}].".format(globalContainerStack.getId(), self._url, self._apiKey))
            else:
                self.setDescription("Configure Moonraker Connection...")
                self.setShortDescription("Moonraker Connection")
                self.setConnectionText(catalog.i18nc("@info:status", "Not connected"))
                self.setPriority(0)
                Logger.log("i", "No valid configuration for printer '{}' found.".format(globalContainerStack.getId()))

            self._message = None
            self._stream = None
            self._resetState()

    def _resetState(self) -> None:
        Logger.log("d", "Reset state of device.")
        if self._stream:
            self._stream.close()
        self._stream = None
        self._fileName = None
        self._startPrint = None
        self._postData = None
        self._timeoutCounter = 0
        self._stage = OutputStage.Ready

    def _onUploadFilenameChanged(self) -> None:
        fileName = self._dialog.findChild(QObject, "nameField").property('text').strip()

        # Check forbidden characters
        forbidden_characters = ":*?\"<>|"
        for forbidden_character in forbidden_characters:
            if forbidden_character in fileName:
                self._dialog.setProperty('validName', False)
                self._dialog.setProperty('validationError', '*cannot contain {}'.format(forbidden_characters))
                return

        # Check forbidden filenames
        if fileName == '.' or fileName == '..':
            self._dialog.setProperty('validName', False)
            self._dialog.setProperty('validationError', '*cannot be "." or ".."')
            return

        # Check length of filename
        self._dialog.setProperty('validName', len(fileName) > 0)
        self._dialog.setProperty('validationError', 'Filename too short')

    def _onUploadFilenameAccepted(self) -> None:
        # Resolve filename
        if self._uploadDialog:
            self._fileName = self._dialog.findChild(QObject, "nameField").property('text').strip()          
        if not self._fileName.endswith('.' + self._outputFormat) and '.' not in self._fileName:
            self._fileName += '.' + self._outputFormat
        Logger.log("d", "FileName set to {}.".format(self._fileName))

        # Resolve start of print job
        if self._uploadDialog:
            self._startPrint = self._dialog.findChild(QObject, "printField").property('checked')
            if self._uploadRememberState:
                self._uploadStartPrintJob = self._startPrint
                config = getConfig()
                config["upload_start_print_job"] = self._startPrint
                saveConfig(config)
        else:
            self._startPrint = self._uploadStartPrintJob
        Logger.log("d", "StartPrint set to {}.".format(str(self._startPrint)))

        if self._uploadDialog:
            self._dialog.deleteLater()       
        Logger.log("i", "Connecting to Moonraker at {}.".format(self._url))

        # Show a message with status of connection
        messageText = self._getConnectMessage()
        self._message = Message(catalog.i18nc("@info:status", messageText), 0, False)
        self._message.setTitle("Moonraker - Connect")
        self._message.show()

        # Handle power device first
        if self._powerDevice:
            self._getPowerDeviceStatus()
        else:
            self._getPrinterStatus()
    
    def _getPowerDeviceStatus(self) -> None:
        powerDevice = self._powerDevice
        if "," in powerDevice:
            powerDevices = [x.strip() for x in powerDevice.split(',')]
            powerDevice = powerDevices[0]

        Logger.log("d", "Checking printer device [power {}] status.".format(powerDevice))
        self._sendRequest('machine/device_power/device?device={}'.format(powerDevice), on_success = self._checkPowerDeviceStatus)

    def _checkPowerDeviceStatus(self, reply: QNetworkReply) -> None:
        response = self._getResponse(reply)
        powerDevice = self._powerDevice
        if "," in powerDevice:
            powerDevices = [x.strip() for x in powerDevice.split(',')]
            powerDevice = powerDevices[0]

        powerDevicesStatus = response['result'][powerDevice]
        logMessage = "Power device [power {}] status == '{}'; startPrint is {} => ".format(powerDevice, powerDevicesStatus, self._startPrint)

        if powerDevicesStatus == 'on':               
            Logger.log("d", logMessage + "Calling _getPrinterStatus()")
            self._getPrinterStatus()
        elif powerDevicesStatus == 'off':
            if self._startPrint:                    
                Logger.log("d", logMessage + "Calling _turnPowerDeviceOn()")
                self._turnPowerDeviceOn()
            else:
                Logger.log("d", logMessage + "Sending FIRMWARE_RESTART before calling _getPrinterStatus().")
                self._sendRequest('printer/firmware_restart', data = json.dumps({}).encode(), dataIsJSON = True, on_success = self._getPrinterStatus)

    def _turnPowerDeviceOn(self) -> None:
        powerDevice = self._powerDevice
        if "," in powerDevice:
            powerDevices = [x.strip() for x in powerDevice.split(',')]
            for powerDevice in powerDevices:
                Logger.log("i", "Turning on Moonraker power device [power {}].".format(powerDevice))
                self._sendRequest('machine/device_power/device?' + urllib.parse.urlencode({'device': powerDevice, 'action': 'on'}), data = '{}'.encode(), dataIsJSON = True, on_success = self._getPrinterStatus)
        else:
            Logger.log("i", "Turning on (single) Moonraker power device [power {}].".format(powerDevice))
            self._sendRequest('machine/device_power/device?' + urllib.parse.urlencode({'device': powerDevice, 'action': 'on'}), data = '{}'.encode(), dataIsJSON = True, on_success = self._getPrinterStatus)

    def _getPrinterStatus(self, reply: QNetworkReply = None) -> None:
        self._sendRequest('printer/info', on_success = self._checkPrinterStatus, on_error = self._onPrinterError)

    def _checkPrinterStatus(self, reply: QNetworkReply) -> None:
        response = self._getResponse(reply)
        status = response['result']['state']

        if self._startPrint:
            if status == 'ready':
                # printer is online
                self._onPrinterOnline(reply)
            else:
                # printer is not ready
                self._onPrinterError()
        elif status != 'error':
            # moonraker can queue job
            self._onPrinterOnline(reply)
        else:
            # set counter to max before call?
            self._onPrinterError()

    def _onPrinterOnline(self, reply: QNetworkReply) -> None:
        # remove connection timeout message
        self._message.hide()
        self._message = None

        self._stage = OutputStage.Writing
        # show a progress message
        self._message = Message(catalog.i18nc("@info:progress", "Uploading to {}...").format(self._name), 0, False, -1)
        self._message.setTitle("Moonraker - Upload")
        self._message.show()

        if self._stage != OutputStage.Writing:
            return # never gets here now?
        if reply.error() != NoError: # QNetworkReply.NetworkError.NoError // 0            
            Logger.log("e", "Stopping due to reply error: {}.".format(reply.error()))
            self._onRequestError(reply)
            return

        Logger.log("i", "Uploading file '{}' [format: {}].".format(self._fileName, self._outputFormat))
        self._stream.seek(0)
        self._postData = QByteArray()
        if isinstance(self._stream, BytesIO):
            self._postData.append(self._stream.getvalue())
        else:
            self._postData.append(self._stream.getvalue().encode())
        self._sendRequest('server/files/upload', name = self._fileName, data = self._postData, on_success = self._onFileUploaded)    
    
    def _onPrinterError(self, reply: QNetworkReply = None, error = None) -> None:
        self._timeoutCounter += 1
        maxTimeoutCounterValue = 20
        
        if self._timeoutCounter > maxTimeoutCounterValue:
            messageText = "Error: Connection to Moonraker at {} timed out.".format(self._url)
            self._message.setLifetimeTimer(0)
            self._message.setText(messageText)
            self._message.setTitle("Moonraker - Error")
            
            browseMessageText = "Check your Moonraker and Klipper settings."
            browseMessageText += "\nA FIRMWARE_RESTART may be necessary."
            if self._powerDevice:
                browseMessageText += "\nAlso check [power {}] in moonraker.conf".format(self._powerDevice)

            self._message = Message(catalog.i18nc("@info:status", browseMessageText), 0, False)
            self._message.addAction("open_browser", catalog.i18nc("@action:button", "Open Browser"), "globe", catalog.i18nc("@info:tooltip", "Open browser to Moonraker."))
            self._message.actionTriggered.connect(self._onMessageActionTriggered)
            self._message.show()
    
            self.writeError.emit(self)
            self._resetState()
        else:
            try:
                sleep(float(self._retryInterval))
            except ValueError:
                sleep(0.5)
            if (self._message):
                self._message.setText(self._getConnectMessage())
            self._getPrinterStatus()

    def _onFileUploaded(self, reply: QNetworkReply) -> None:
        if self._stage != OutputStage.Writing:
            return
        if reply.error() != NoError: # QNetworkReply.NetworkError.NoError // 0            
            Logger.log("e", "Stopping due to reply error: {}.".format(reply.error()))
            self._onRequestError(reply)
            return

        Logger.log("i", "Upload completed.")
        self._stream.close()
        self._stream = None

        if self._message:
            self._message.hide()
            self._message = None
        messageText = "Upload of '{}' to {} successfully completed"
        if self._startPrint:
           messageText += " and print job initialized."
        else:
           messageText += "."
        self._message = Message(catalog.i18nc("@info:status", messageText.format(os.path.basename(self._fileName), self._name)), 30 if self._uploadAutohideMessagebox else 0, True)
        self._message.setTitle("Moonraker")
        self._message.addAction("open_browser", catalog.i18nc("@action:button", "Open Browser"), "globe", catalog.i18nc("@info:tooltip", "Open browser to Moonraker."))
        self._message.actionTriggered.connect(self._onMessageActionTriggered)
        self._message.show()

        self.writeSuccess.emit(self)
        self._resetState()

    def _onMessageActionTriggered(self, message: Message, action: str) -> None:
        if action == "open_browser":
            QDesktopServices.openUrl(QUrl(self._frontendUrl))
            if self._message:
                self._message.hide()
                self._message = None

    def _getResponse(self, reply: QNetworkReply):
        byte_string = reply.readAll()
        response = ''
        try:
            response = json.loads(str(byte_string, 'utf-8'))
        except json.JSONDecodeError:
            Logger.log("e", "Reply is not a JSON: %s" % str(byte_string, 'utf-8'))
            self._onPrinterError()

        return response

    def _sendRequest(self, path: str, name: str = None, data: QByteArray = None, dataIsJSON: bool = False, on_success = None, on_error = None) -> None:
        url = self._url + path

        headers = {'User-Agent': 'Cura Plugin Moonraker', 'Accept': 'application/json, text/plain', 'Connection': 'keep-alive'}
        if self._apiKey:
            headers['X-API-Key'] = self._apiKey

        postData = data
        requestManager = CuraApplication.getInstance().getHttpRequestManager()
        if data is not None:
            if not dataIsJSON:
                # Create multi_part request           
                parts = QHttpMultiPart(FormDataType)

                part_file = QHttpPart()
                part_file.setHeader(ContentDispositionHeader, QVariant('form-data; name="file"; filename="/' + name + '"'))
                part_file.setHeader(ContentTypeHeader, QVariant('application/octet-stream'))
                part_file.setBody(data)
                parts.append(part_file)

                part_root = QHttpPart()
                part_root.setHeader(ContentDispositionHeader, QVariant('form-data; name="root"'))
                part_root.setBody(b"gcodes")
                parts.append(part_root)

                if self._startPrint:
                    part_print = QHttpPart()
                    part_print.setHeader(ContentDispositionHeader, QVariant('form-data; name="print"'))
                    part_print.setBody(b"true")
                    parts.append(part_print)

                headers['Content-Type'] = 'multipart/form-data; boundary="'+ str(parts.boundary().data(), encoding = 'utf-8') + '"'

                postData = parts
            else:
                # postData is JSON
                headers['Content-Type'] = 'application/json'

            requestManager.post(url, headers, postData, callback = on_success, error_callback = on_error if on_error else self._onRequestError, upload_progress_callback = self._onUploadProgress if not dataIsJSON else None)
        else:
            requestManager.get(url, headers, callback = on_success, error_callback = on_error if on_error else self._onRequestError)

    def _onUploadProgress(self, bytesSent, bytesTotal) -> None:
        if bytesTotal > 0:
            progress = int(bytesSent * 100 / bytesTotal)
            if self._message:
                self._message.setProgress(progress)
            self.writeProgress.emit(self, progress)

    def _onRequestError(self, reply: QNetworkReply, error) -> None:
        Logger.log("e", repr(error))
        if self._message:
            self._message.hide()
            self._message = None

        message = Message(catalog.i18nc("@info:status", "There was a network error: {} {}").format(error, reply.errorString() if reply else ""), 0, False)
        message.setTitle("Moonraker - Error")
        message.show()

        self.writeError.emit(self)
        self._resetState()
    
    def _getConnectMessage(self):
        return "Connecting to Moonraker at {}     {}".format(self._url, spinner[self._timeoutCounter % len(spinner)])
