from typing import cast

from cura.CuraApplication import CuraApplication

from UM.Logger import Logger
from UM.Extension import Extension
from UM.OutputDevice.OutputDevicePlugin import OutputDevicePlugin

from .MoonrakerOutputDevice import MoonrakerOutputDevice
from .MoonrakerSettings import getConfig, initConfig

class MoonrakerPlugin(Extension, OutputDevicePlugin):
    def __init__(self) -> None:
        super().__init__()
        Logger.log("d", "MoonrakerPlugin init")
        initConfig();
        self._application = CuraApplication.getInstance()
        self._application.globalContainerStackChanged.connect(self._checkMoonrakerOutputDevice)

    def start(self) -> None:
        Logger.log("d", "MoonrakerPlugin start")

    def _checkMoonrakerOutputDevice(self) -> None:
        Logger.log("d", "MoonrakerPlugin check for current OutputDevice...")
        globalContainerStack = self._application.getGlobalContainerStack()
        if not globalContainerStack:
            return

        # check and update moonrakerOutputDevices
        outputDeviceManager = self.getOutputDeviceManager()
        moonrakerOutputDevice = cast(MoonrakerOutputDevice, outputDeviceManager.getOutputDevice("MoonrakerOutputDevice"))
        if  not moonrakerOutputDevice:
            Logger.log("i", "MoonrakerPlugin is now adding MoonrakerOutputDevice")
            moonrakerOutputDevice = MoonrakerOutputDevice()
            outputDeviceManager.addOutputDevice(moonrakerOutputDevice)
        if moonrakerOutputDevice.getPrinterId() != globalContainerStack.getId() or moonrakerOutputDevice.getConfig() != getConfig():
            Logger.log("d", "MoonrakerPlugin update config of MoonrakerOutputDevice")
            moonrakerOutputDevice.initConfig()
