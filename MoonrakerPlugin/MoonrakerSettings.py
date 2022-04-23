import json
from enum import Enum

from cura.CuraApplication import CuraApplication

from UM.Logger import Logger

MOONRAKER_SETTINGS = "moonraker/instances"

def _loadConfig():
    application = CuraApplication.getInstance()
    globalContainerStack = application.getGlobalContainerStack()
    if not globalContainerStack:
        return {}, None
    printerId = globalContainerStack.getId()
    preferences = application.getPreferences()
    configs = preferences.getValue(MOONRAKER_SETTINGS)
    if not configs:
        return {}, None
    settings = json.loads(configs)
    return settings, printerId

def initConfig():
    application = CuraApplication.getInstance()
    preferences = application.getPreferences()
    preferences.addPreference(MOONRAKER_SETTINGS, json.dumps({}))

def getConfig():
    settings, printerId = _loadConfig()
    if printerId in settings:
        return settings[printerId]
    return {}

def saveConfig(config):
    settings, printerId = _loadConfig()
    Logger.log("d", "MoonrakerSettings save config for printer... id:{}".format(printerId))

    settings[printerId] = config
    application = CuraApplication.getInstance()
    preferences = application.getPreferences()
    preferences.setValue(MOONRAKER_SETTINGS, json.dumps(settings))
    return settings

def deleteConfig(printerId = None):
    settings, activePrinterId = _loadConfig()
    if not printerId:
        printerId = activePrinterId

    Logger.log("d", "MoonrakerSettings delete config for printer... id:{}".format(printerId))
    if printerId in settings:
        del settings[printerId]
        application = CuraApplication.getInstance()
        preferences = application.getPreferences()
        preferences.setValue(MOONRAKER_SETTINGS, json.dumps(settings))
        return True
    return False
