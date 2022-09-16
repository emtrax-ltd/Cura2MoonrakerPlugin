import re
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
    settings = json.loads(preferences.getValue(MOONRAKER_SETTINGS))
    return settings, printerId

def initConfig():
    preferences = CuraApplication.getInstance().getPreferences()
    preferences.addPreference(MOONRAKER_SETTINGS, json.dumps({}))

def getConfig() -> dict:
    settings, printerId = _loadConfig()
    
    if printerId in settings:
        return settings[printerId]
    return {}

def saveConfig(config: dict) -> dict:
    settings, printerId = _loadConfig()

    Logger.log("i", "MoonrakerSettings save config for printer... id:{}".format(printerId))
    settings[printerId] = config
    preferences = CuraApplication.getInstance().getPreferences()
    preferences.setValue(MOONRAKER_SETTINGS, json.dumps(settings))
    return settings

def deleteConfig(printerId: str = None) -> bool:
    settings, activePrinterId = _loadConfig()
    if not printerId:
        printerId = activePrinterId

    Logger.log("i", "MoonrakerSettings delete config for printer... id:{}".format(printerId))
    if printerId in settings:
        del settings[printerId]
        preferences = CuraApplication.getInstance().getPreferences()
        preferences.setValue(MOONRAKER_SETTINGS, json.dumps(settings))
        return True
    return False

def validateUrl(url: str = None) -> bool:
    if not url:
        return False
    if url.startswith('\\\\'):
        # no UNC paths
        return False
    if not re.match('^https?://.', url):
        # missing https?://
        return False
    if '@' in url:
        # @ is probably HTTP basic auth, which is a separate setting
        return False
    return True

def validateRetryInterval(retryInterval: str = None) -> bool:
    try:
        float(retryInterval)
        return True
    except ValueError:
        if not retryInterval:
            return True
        return False

def validateTranslation(translateInput: str = None, translateOutput: str = None) -> bool:
    if len(translateInput) != len(translateOutput):
        return False
    return True
