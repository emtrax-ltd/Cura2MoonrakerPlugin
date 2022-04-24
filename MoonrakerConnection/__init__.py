import os
import json

from UM.Logger import Logger

from . import MoonrakerPlugin, MoonrakerAction


def getMetaData():
    return {}


def register(app):
    plugin_file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "plugin.json")
    try:
        with open(plugin_file_path) as plugin_file:
            plugin_info = json.load(plugin_file)
            Logger.log("d", "MoonrakerPlugin version: {}".format(plugin_info["version"]))
    except:
        Logger.log("w", "MoonrakerPlugin failed to get version information!")

    plugin = MoonrakerPlugin.MoonrakerPlugin()
    return {
        "extension": plugin,
        "output_device": plugin,
        "machine_action": MoonrakerAction.MoonrakerAction()
    }
