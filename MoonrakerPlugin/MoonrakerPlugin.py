from cura.CuraApplication import CuraApplication

from UM.Logger import Logger
from UM.Extension import Extension
from UM.OutputDevice.OutputDevicePlugin import OutputDevicePlugin

from .MoonrakerOutputDevice import MoonrakerConfigureOutputDevice, MoonrakerOutputDevice
from .MoonrakerSettings import getConfig

class MoonrakerPlugin(Extension, OutputDevicePlugin):
    def __init__(self) -> None:
        super().__init__()
        Logger.log("d", "MoonrakerPlugin init")
        self._application = CuraApplication.getInstance()
        self._application.globalContainerStackChanged.connect(self._checkMoonrakerOutputDevice)

    def start(self) -> None:
        Logger.log("d", "MoonrakerPlugin start")

    def _checkMoonrakerOutputDevice(self) -> None:
        Logger.log("d", "MoonrakerPlugin check for current OutputDevice...")
        globalContainerStack = self._application.getGlobalContainerStack()
        if not globalContainerStack:
            return

        outputDeviceManager = self.getOutputDeviceManager()
        # remove all Moonraker output devices - the new stack might not need them or have a different config
        outputDeviceManager.removeOutputDevice("MoonrakerConfigureOutputDevice")
        outputDeviceManager.removeOutputDevice("MoonrakerOutputDevice")

        # check and load new output devices
        config = getConfig()
        if config:
            Logger.log("d", "MoonrakerPlugin is active for printer... id:{}, name:{}".format(globalContainerStack.getId(), globalContainerStack.getName()))
            outputDeviceManager.addOutputDevice(MoonrakerOutputDevice(config))
        else:
            Logger.log("d", "MoonrakerPlugin is not configured for printer... id:{}, name:{}".format(globalContainerStack.getId(), globalContainerStack.getName()))
            outputDeviceManager.addOutputDevice(MoonrakerConfigureOutputDevice())
