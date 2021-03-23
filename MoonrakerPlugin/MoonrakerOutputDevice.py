import base64
import json
import os.path
import urllib
from enum import Enum
from io import BytesIO, StringIO
from typing import cast

from cura.CuraApplication import CuraApplication

from PyQt5.QtCore import QByteArray, QObject, QUrl, QVariant
from PyQt5.QtGui import QDesktopServices
from PyQt5.QtNetwork import QHttpMultiPart, QHttpPart, QNetworkReply, QNetworkRequest

from UM.Application import Application
from UM.i18n import i18nCatalog
from UM.Logger import Logger
from UM.Mesh.MeshWriter import MeshWriter
from UM.Message import Message
from UM.OutputDevice import OutputDeviceError
from UM.OutputDevice.OutputDevice import OutputDevice
from UM.PluginRegistry import PluginRegistry

catalog = i18nCatalog("cura")

class OutputStage(Enum):
    ready = 0
    writing = 1

class MoonrakerConfigureOutputDevice(OutputDevice):
    def __init__(self) -> None:
        super().__init__("moonraker-configure")
        self.setShortDescription("Moonraker Plugin")
        self.setDescription("Configure Moonraker...")
        self.setPriority(0)

    def requestWrite(self, node, fileName = None, *args, **kwargs):
        message = Message("To configure your Moonraker printer go to:\n→ Settings\n  → Printer\n    → Manage Printers\n     → select your printer\n    → click on 'Connect Moonraker'", lifetime = 0, title = "Configure Moonraker in Preferences!")
        message.show()
        self.writeSuccess.emit(self)

class MoonrakerOutputDevice(OutputDevice):
    def __init__(self, config):
        self._name_id = "moonraker-upload"
        super().__init__(self._name_id)

        self._url = config.get("url", "")
        self._api_key = config.get("api_key", "")
        self._http_user = config.get("http_user", "")
        self._http_password = config.get("http_password", "")
        self._output_format = config.get("output_format", "gcode")
        if self._output_format and self._output_format != "ufp":
            self._output_format = "gcode"

        self.application = CuraApplication.getInstance()
        global_container_stack = self.application.getGlobalContainerStack()
        self._name = global_container_stack.getName()


        description = catalog.i18nc("@action:button", "Upload to {0}").format(self._name)
        self.setShortDescription(description)
        self.setDescription(description)

        self._stage = OutputStage.ready
        self._stream = None
        self._message = None

        Logger.log("d","New MoonrakerOutputDevice '{}' created | URL: {} | API-Key: {} | HTTP Basic Auth: user:{}, password:{}".format(self._name_id, self._url, self._api_key, self._http_user if self._http_user else "<empty>", "set" if self._http_password else "<empty>",))
        self._resetState()

    def requestWrite(self, node, fileName = None, *args, **kwargs):
        if self._stage != OutputStage.ready:
            raise OutputDeviceError.DeviceBusyError()

        # Make sure post-processing plugin are run on the gcode
        self.writeStarted.emit(self)

        # The presliced print should always be send using `GCodeWriter`
        print_info = CuraApplication.getInstance().getPrintInformation()
        if self._output_format != "ufp" or not print_info or print_info.preSliced:
            self._output_format = "gcode"
            code_writer = cast(MeshWriter, PluginRegistry.getInstance().getPluginObject("GCodeWriter"))
            self._stream = StringIO()
        else:
            code_writer = cast(MeshWriter, PluginRegistry.getInstance().getPluginObject("UFPWriter"))
            self._stream = BytesIO()

        if not code_writer.write(self._stream, None):
            Logger.log("e", "MeshWriter failed: %s" % code_writer.getInformation())
            return

        # Prepare filename for upload
        if fileName:
            # check if fileName has a path or just contains a filename
            if "/" in fileName or "\\" in fileName: 
                fileName = os.path.splitext(fileName)[0].replace(" ", "_").replace(".", "-") + '.' + self._output_format
            else:
                fileName = fileName.replace(" ", "_").replace(".", "-") + '.' + self._output_format
        else:
            fileName = "%s." + self._output_format % Application.getInstance().getPrintInformation().jobName
        self._fileName = fileName

        # Display upload dialog
        path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'resources', 'qml', 'MoonrakerUpload.qml')
        self._dialog = CuraApplication.getInstance().createQmlComponent(path, {"manager": self})
        self._dialog.textChanged.connect(self.onFilenameChanged)
        self._dialog.accepted.connect(self.onFilenameAccepted)
        self._dialog.show()
        self._dialog.findChild(QObject, "nameField").setProperty('text', self._fileName)
        self._dialog.findChild(QObject, "nameField").select(0, len(self._fileName) - len(self._output_format) - 1)
        self._dialog.findChild(QObject, "nameField").setProperty('focus', True)

    def onFilenameChanged(self):
        fileName = self._dialog.findChild(QObject, "nameField").property('text').strip()
        fileName = self._dialog.findChild(QObject, "nameField").property('text').strip()

        forbidden_characters = "\/:*?\"<>|"
        for forbidden_character in forbidden_characters:
            if forbidden_character in fileName:
                self._dialog.setProperty('validName', False)
                self._dialog.setProperty('validationError', '*cannot contain {}'.format(forbidden_characters))
                return

        if fileName == '.' or fileName == '..':
            self._dialog.setProperty('validName', False)
            self._dialog.setProperty('validationError', '*cannot be "." or ".."')
            return

        self._dialog.setProperty('validName', len(fileName) > 0)
        self._dialog.setProperty('validationError', 'Filename too short')

    def onFilenameAccepted(self):
        self._fileName = self._dialog.findChild(QObject, "nameField").property('text').strip()
        if not self._fileName.endswith('.' + self._output_format) and '.' not in self._fileName:
            self._fileName += '.' + self._output_format
        Logger.log("d", "Filename set to: " + self._fileName)

        self._startPrint = self._dialog.findChild(QObject, "printField").property('checked')
        Logger.log("d", "Print set to: " + str(self._startPrint))

        self._dialog.deleteLater()
        self._stage = OutputStage.writing

        # show a progress message
        self._message = Message(catalog.i18nc("@info:progress", "Uploading to {}...").format(self._name), 0, False, -1)
        self._message.show()
        Logger.log("d", "Connecting to Moonraker...")
        self._sendRequest('printer/info', on_success = self.onInstanceOnline)

    def onInstanceOnline(self, reply):
        if self._stage != OutputStage.writing:
            return
        if reply.error() != QNetworkReply.NoError:
            Logger.log("d", "Stopping due to reply error: " + reply.error())
            return

        Logger.log("d", "Uploading " + self._output_format + "...")
        self._stream.seek(0)
        self._postData = QByteArray()
        if isinstance(self._stream, BytesIO):
            self._postData.append(self._stream.getvalue())
        else:
            self._postData.append(self._stream.getvalue().encode())
        self._sendRequest('server/files/upload', name = self._fileName, data = self._postData, on_success = self.onCodeUploaded)

    def onCodeUploaded(self, reply):
        if self._stage != OutputStage.writing:
            return
        if reply.error() != QNetworkReply.NoError:
            Logger.log("d", "Stopping due to reply error: " + reply.error())
            return

        Logger.log("d", "Upload completed")
        self._stream.close()
        self._stream = None

        if self._message:
            self._message.hide()
            self._message = None

        messageText = "Upload of '{}' to {} successfully completed"
        if self._startPrint and self._startPrint == True:
           messageText += " and print job initialized."
        else:
           messageText += "."
        self._message = Message(catalog.i18nc("@info:status", messageText.format(os.path.basename(self._fileName), self._name)), 0, False)
        self._message.addAction("open_browser", catalog.i18nc("@action:button", "Open Browser"), "globe", catalog.i18nc("@info:tooltip", "Open browser to Moonraker."))
        self._message.actionTriggered.connect(self._onMessageActionTriggered)
        self._message.show()

        self.writeSuccess.emit(self)
        self._resetState()

    def _onProgress(self, progress):
        if self._message:
            self._message.setProgress(progress)
        self.writeProgress.emit(self, progress)

    def _resetState(self):
        Logger.log("d", "Reset state")
        if self._stream:
            self._stream.close()
        self._stream = None
        self._stage = OutputStage.ready
        self._fileName = None
        self._startPrint = None
        self._postData = None

    def _onMessageActionTriggered(self, message, action):
        if action == "open_browser":
            QDesktopServices.openUrl(QUrl(self._url))
            if self._message:
                self._message.hide()
                self._message = None

    def _onUploadProgress(self, bytesSent, bytesTotal):
        if bytesTotal > 0:
            self._onProgress(int(bytesSent * 100 / bytesTotal))

    def _onNetworkError(self, reply, error):
        Logger.log("e", repr(error))
        if self._message:
            self._message.hide()
            self._message = None

        errorString = ''
        if reply:
            errorString = reply.errorString()

        message = Message(catalog.i18nc("@info:status", "There was a network error: {} {}").format(error, errorString), 0, False)
        message.show()

        self.writeError.emit(self)
        self._resetState()

    def _sendRequest(self, path, name = None, data = None, on_success = None, on_error = None):
        url = self._url + path

        headers = {'User-Agent': 'Cura Plugin Moonraker', 'Accept': 'application/json, text/plain', 'Connection': 'keep-alive'}

        if self._api_key:
            headers['X-API-Key'] = self._api_key;

        if self._http_user and self._http_password:
            auth = "{}:{}".format(self._http_user, self._http_password).encode()
            headers['Authorization'] = 'Basic ' + base64.b64encode(auth).decode("utf-8");

        if data:
            # Create multi_part request           
            parts = QHttpMultiPart(QHttpMultiPart.FormDataType)

            part_file = QHttpPart()
            part_file.setHeader(QNetworkRequest.ContentDispositionHeader, QVariant('form-data; name="file"; filename="/' + name + '"'))
            part_file.setHeader(QNetworkRequest.ContentTypeHeader, QVariant('application/octet-stream'))
            part_file.setBody(data)
            parts.append(part_file)

            part_root = QHttpPart()
            part_root.setHeader(QNetworkRequest.ContentDispositionHeader, QVariant('form-data; name="root"'))
            part_root.setBody(b"gcodes")
            parts.append(part_root)

            if self._startPrint and self._startPrint == True:
                part_print = QHttpPart()
                part_print.setHeader(QNetworkRequest.ContentDispositionHeader, QVariant('form-data; name="print"'))
                part_print.setBody(b"true")
                parts.append(part_print)

            headers['Content-Type'] = 'multipart/form-data; boundary='+ str(parts.boundary().data(), encoding = 'utf-8');

            self.application.getHttpRequestManager().post(url, headers, parts, callback = on_success, error_callback = on_error if on_error else self._onNetworkError, upload_progress_callback = self._onUploadProgress)
        else:
            self.application.getHttpRequestManager().get(url, headers, callback = on_success, error_callback = on_error if on_error else self._onNetworkError)
