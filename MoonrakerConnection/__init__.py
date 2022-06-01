import os
import json

from UM.Logger import Logger

from . import MoonrakerMachineAction, MoonrakerOutputDevicePlugin

def getMetaData():
    return {}

def register(app):
    plugin_file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "plugin.json")
    try:
        with open(plugin_file_path) as plugin_file:
            plugin_info = json.load(plugin_file)
            Logger.log("d", "MoonrakerOutputDevicePlugin version: {}".format(plugin_info["version"]))
    except:
        Logger.log("w", "MoonrakerOutputDevicePlugin failed to get version information!")

    return {
        "output_device": MoonrakerOutputDevicePlugin.MoonrakerOutputDevicePlugin(),
        "machine_action": MoonrakerMachineAction.MoonrakerMachineAction()
    }
