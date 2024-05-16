from cura.CuraApplication import CuraApplication

from UM.Logger import Logger
from UM.OutputDevice.OutputDevicePlugin import OutputDevicePlugin

from .MoonrakerOutputDevice import MoonrakerOutputDevice
from .MoonrakerSettings import initConfig, getConfig, validateUrl

class MoonrakerOutputDevicePlugin(OutputDevicePlugin):
    def __init__(self) -> None:
        super().__init__()
        Logger.log("d", "Initialising plugin.")
        initConfig()
        self._moonrakerOutputDevices = {}
        self._currentMoonrakerOutputDevice = None
        CuraApplication.getInstance().globalContainerStackChanged.connect(self._checkMoonrakerOutputDevice)

    def start(self) -> None:
        Logger.log("d", "Starting plugin.")

    def stop(self) -> None:
        Logger.log("d", "Stopping plugin.")

    def _checkMoonrakerOutputDevice(self) -> None:
        Logger.log("d", "Check current MoonrakerOutputDevice.")
        globalContainerStack = CuraApplication.getInstance().getGlobalContainerStack()
        if not globalContainerStack:
            return
        
        # resolve current device and config
        config = getConfig()
        deviceId = globalContainerStack.getId()
        canConnect = validateUrl(config.get("url", ""))

        # remove inactive device
        if self._currentMoonrakerOutputDevice and (self._currentMoonrakerOutputDevice.getId() != "MoonrakerOutputDevice@" + deviceId or canConnect != self._currentMoonrakerOutputDevice._canConnect):
            self.getOutputDeviceManager().removeOutputDevice(self._currentMoonrakerOutputDevice.getId())
            self._currentMoonrakerOutputDevice = None

        # add active device
        if not self._currentMoonrakerOutputDevice:
            if deviceId in self._moonrakerOutputDevices:
                self._currentMoonrakerOutputDevice = self._moonrakerOutputDevices.get(deviceId)
                if canConnect != self._currentMoonrakerOutputDevice._canConnect:
                    self._currentMoonrakerOutputDevice = None
                    self._moonrakerOutputDevices.pop(deviceId)
            if config:
                if not self._currentMoonrakerOutputDevice:
                    self._currentMoonrakerOutputDevice = MoonrakerOutputDevice(deviceId, canConnect)
                    self._moonrakerOutputDevices[deviceId] = self._currentMoonrakerOutputDevice
                self.getOutputDeviceManager().addOutputDevice(self._currentMoonrakerOutputDevice)

        # update config of device
        if self._currentMoonrakerOutputDevice:
            self._currentMoonrakerOutputDevice.updateConfig(config)
