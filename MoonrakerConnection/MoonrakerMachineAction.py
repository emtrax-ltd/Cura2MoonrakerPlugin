import os
import json
from typing import Dict, Type, TYPE_CHECKING, List, Optional, cast

USE_QT5 = False
try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6   
    CuraSDKVersion = "6.0.0"
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import QObject, QVariant, pyqtSlot, pyqtProperty, pyqtSignal
else:
    from PyQt5.QtCore import QObject, QVariant, pyqtSlot, pyqtProperty, pyqtSignal
    USE_QT5 = True

from cura.CuraApplication import CuraApplication
from cura.MachineAction import MachineAction

from UM.Logger import Logger
from UM.Settings.ContainerRegistry import ContainerRegistry
from UM.Settings.DefinitionContainer import DefinitionContainer
from UM.i18n import i18nCatalog

catalog = i18nCatalog("cura")

from .MoonrakerSettings import getConfig, saveConfig, deleteConfig, validateUrl, validateRetryInterval, validateTranslation

class MoonrakerMachineAction(MachineAction):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__("MoonrakerMachineAction", catalog.i18nc("@action", "Connect Moonraker"))
        self._qml_url = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'resources', 'qml', 'qt5' if USE_QT5 else 'qt6', 'MoonrakerConfiguration.qml')
        CuraApplication.getInstance().globalContainerStackChanged.connect(self._onGlobalContainerStackChanged)
        CuraApplication.getInstance().getContainerRegistry().containerAdded.connect(self._onContainerAdded)

    def _onGlobalContainerStackChanged(self) -> None:
        self.settingsExistsChanged.emit()
        self.settingsUrlChanged.emit()
        self.settingsApiKeyChanged.emit()
        self.settingsPowerDeviceChanged.emit()
        self.settingsRetryIntervalChanged.emit()
        self.settingsFrontendUrlChanged.emit()
        self.settingsOutputFormatChanged.emit()
        self.settingsUploadDialogChanged.emit()
        self.settingsUploadStartPrintJobChanged.emit()
        self.settingsUploadRememberStateChanged.emit()
        self.settingsUploadAutohideMessageboxChanged.emit()
        self.settingsTranslateInputChanged.emit()
        self.settingsTranslateOutputChanged.emit()
        self.settingsTranslateRemoveChanged.emit()
        self.settingsCameraUrlChanged.emit()
        self.settingsCameraImageRotationChanged.emit()
        self.settingsCameraImageMirrorChanged.emit()
 
    def _onContainerAdded(self, container) -> None:
        # Add this action as a supported action to all machine definitions
        if isinstance(container, DefinitionContainer) and container.getMetaDataEntry("type") == "machine":
            CuraApplication.getInstance().getMachineActionManager().addSupportedAction(container.getId(), self.getKey())

    def _reset(self) -> None:
        self.settingsExistsChanged.emit()
        self.settingsUrlChanged.emit()
        self.settingsApiKeyChanged.emit()
        self.settingsPowerDeviceChanged.emit()
        self.settingsRetryIntervalChanged.emit()
        self.settingsFrontendUrlChanged.emit()
        self.settingsOutputFormatChanged.emit()
        self.settingsUploadDialogChanged.emit()
        self.settingsUploadStartPrintJobChanged.emit()
        self.settingsUploadRememberStateChanged.emit()
        self.settingsUploadAutohideMessageboxChanged.emit()
        self.settingsTranslateInputChanged.emit()
        self.settingsTranslateOutputChanged.emit()
        self.settingsTranslateRemoveChanged.emit()
        self.settingsCameraUrlChanged.emit()
        self.settingsCameraImageRotationChanged.emit()
        self.settingsCameraImageMirrorChanged.emit()

    settingsExistsChanged = pyqtSignal()
    settingsUrlChanged = pyqtSignal()
    settingsApiKeyChanged = pyqtSignal()
    settingsPowerDeviceChanged = pyqtSignal()
    settingsRetryIntervalChanged = pyqtSignal()
    settingsFrontendUrlChanged = pyqtSignal()
    settingsOutputFormatChanged = pyqtSignal()
    settingsUploadDialogChanged = pyqtSignal()
    settingsUploadStartPrintJobChanged = pyqtSignal()
    settingsUploadRememberStateChanged = pyqtSignal()
    settingsUploadAutohideMessageboxChanged = pyqtSignal()
    settingsTranslateInputChanged = pyqtSignal()
    settingsTranslateOutputChanged = pyqtSignal()
    settingsTranslateRemoveChanged = pyqtSignal()
    settingsCameraUrlChanged = pyqtSignal()
    settingsCameraImageRotationChanged = pyqtSignal()
    settingsCameraImageMirrorChanged = pyqtSignal()

    @pyqtProperty(bool, notify = settingsExistsChanged)
    def settingsExists(self) -> Optional[bool]:
        config = getConfig()
        if config:
            return True
        return False

    @pyqtProperty(str, notify = settingsUrlChanged)
    def settingsUrl(self) -> Optional[str]:
        config = getConfig()
        return config.get("url", "") if config else ""

    @pyqtProperty(str, notify = settingsApiKeyChanged)
    def settingsApiKey(self) -> Optional[str]:
        config = getConfig()
        return config.get("api_key", "") if config else ""

    @pyqtProperty(str, notify = settingsPowerDeviceChanged)
    def settingsPowerDevice(self) -> Optional[str]:
        config = getConfig()
        return config.get("power_device", "") if config else ""

    @pyqtProperty(str, notify = settingsRetryIntervalChanged)
    def settingsRetryInterval(self) -> Optional[str]:
        config = getConfig()
        return config.get("retry_interval", "") if config else ""

    @pyqtProperty(str, notify = settingsFrontendUrlChanged)
    def settingsFrontendUrl(self) -> Optional[str]:
        config = getConfig()
        return config.get("frontend_url", "") if config else ""

    @pyqtProperty(str, notify = settingsOutputFormatChanged)
    def settingsOutputFormat(self) -> Optional[str]:
        config = getConfig()
        return config.get("output_format", "gcode") if config else "gcode"

    @pyqtProperty(bool, notify = settingsUploadDialogChanged)
    def settingsUploadDialog(self) -> Optional[bool]:
        config = getConfig()
        return config.get("upload_dialog", True) if config else True

    @pyqtProperty(bool, notify = settingsUploadStartPrintJobChanged)
    def settingsUploadStartPrintJob(self) -> Optional[bool]:
        config = getConfig()
        return config.get("upload_start_print_job", False) if config else False

    @pyqtProperty(bool, notify = settingsUploadRememberStateChanged)
    def settingsUploadRememberState(self) -> Optional[bool]:
        config = getConfig()
        return config.get("upload_remember_state", False) if config else False

    @pyqtProperty(bool, notify = settingsUploadAutohideMessageboxChanged)
    def settingsUploadAutohideMessagebox(self) -> Optional[bool]:
        config = getConfig()
        return config.get("upload_autohide_messagebox", False) if config else False

    @pyqtProperty(str, notify = settingsTranslateInputChanged)
    def settingsTranslateInput(self) -> Optional[str]:
        config = getConfig()
        return config.get("trans_input", "") if config else ""

    @pyqtProperty(str, notify = settingsTranslateOutputChanged)
    def settingsTranslateOutput(self) -> Optional[str]:
        config = getConfig()
        return config.get("trans_output", "") if config else ""

    @pyqtProperty(str, notify = settingsTranslateRemoveChanged)
    def settingsTranslateRemove(self) -> Optional[str]:
        config = getConfig()
        return config.get("trans_remove", "") if config else ""

    @pyqtProperty(str, notify = settingsCameraUrlChanged)
    def settingsCameraUrl(self) -> Optional[str]:
        config = getConfig()
        return config.get("camera_url", "") if config else ""

    @pyqtProperty(str, notify = settingsCameraImageRotationChanged)
    def settingsCameraImageRotation(self) -> Optional[str]:
        config = getConfig()
        rotation = config.get("camera_image_rotation", "0") if config else "0"
        return rotation if rotation == "90" or rotation == "180" or rotation == "270" else "0"

    @pyqtProperty(bool, notify = settingsCameraImageMirrorChanged)
    def settingsCameraImageMirror(self) -> Optional[bool]:
        config = getConfig()
        return config.get("camera_image_mirror", False) if config else False

    @pyqtSlot(QVariant)
    def saveConfig(self, paramsQJSValObj):
        oldConfig = getConfig()
        config = paramsQJSValObj.toVariant()
        if not config["url"].endswith('/'):
            config["url"] += '/'
        if not "upload_start_print_job" in config.keys():
            config["upload_start_print_job"] = oldConfig.get("upload_start_print_job", False) if oldConfig else False
        saveConfig(config)

        Logger.log("d", "config saved")
        # trigger a stack change to reload the output devices
        CuraApplication.getInstance().globalContainerStackChanged.emit()

    @pyqtSlot()
    def deleteConfig(self):
        if deleteConfig():
            Logger.log("d", "config deleted")
            # trigger a stack change to reload the output devices
            CuraApplication.getInstance().globalContainerStackChanged.emit()
        else:
            Logger.log("d", "no config to delete")

    @pyqtSlot(str, result = bool)
    def validUrl(self, url) -> bool:
        return validateUrl(url)

    @pyqtSlot(str, result = bool)
    def validRetryInterval(self, retryInterval) -> bool:
        return validateRetryInterval(retryInterval)

    @pyqtSlot(str, str, result = bool)
    def validTranslation(self, translateInput, translateOutput) -> bool:
        return validateTranslation(translateInput, translateOutput)
