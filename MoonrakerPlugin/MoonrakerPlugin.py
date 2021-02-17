from cura.CuraApplication import CuraApplication

from UM.Logger import Logger
from UM.Extension import Extension
from UM.OutputDevice.OutputDevicePlugin import OutputDevicePlugin

from .MoonrakerOutputDevice import MoonrakerConfigureOutputDevice, MoonrakerOutputDevice
from .MoonrakerSettings import get_config, init_config, MOONRAKER_SETTINGS

class MoonrakerPlugin(Extension, OutputDevicePlugin):
    def __init__(self):
        super().__init__()
        self._application = CuraApplication.getInstance()
        self._application.globalContainerStackChanged.connect(self._checkMoonrakerOutputDevices)
        init_config()
    
    def _checkMoonrakerOutputDevices(self):
        global_container_stack = self._application.getGlobalContainerStack()
        if not global_container_stack:
            return

        manager = self.getOutputDeviceManager()
        # remove all Moonraker output devices - the new stack might not need them or have a different config
        manager.removeOutputDevice("moonraker-configure")
        manager.removeOutputDevice("moonraker-upload")

        # check and load new output devices
        config = get_config()
        if config:
            Logger.log("d", "Moonraker is active for printer: id:{}, name:{}".format(global_container_stack.getId(), global_container_stack.getName()))
            manager.addOutputDevice(MoonrakerOutputDevice(config))
        else:
            manager.addOutputDevice(MoonrakerConfigureOutputDevice())
            Logger.log("d", "Moonraker is not available for printer: id:{}, name:{}".format(global_container_stack.getId(), global_container_stack.getName()))
