USE_QT5 = False
try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6   
    CuraSDKVersion = "6.0.0"
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import pyqtProperty, pyqtSignal
else:
    from PyQt5.QtCore import pyqtProperty, pyqtSignal
    USE_QT5 = True
    
from cura.PrinterOutput.Models.PrinterOutputModel import PrinterOutputModel

from UM.Logger import Logger

from .MoonrakerOutputController import MoonrakerOutputController

class MoonrakerOutputModel(PrinterOutputModel):

    cameraImageRotationChanged = pyqtSignal()
    cameraImageMirrorChanged = pyqtSignal()
    
    def __init__(self, output_controller: MoonrakerOutputController, number_of_extruders: int = 1) -> None:
        super().__init__(output_controller, number_of_extruders)
        self._camera_image_rotation = "0"
        self._camera_image_mirror = False
        Logger.log("d", "MoonrakerOutputModel [number_of_extruders: {}] created.".format(number_of_extruders))

    def setCameraImageRotation(self, camera_image_rotation: str) -> None:
        if self._camera_image_rotation != camera_image_rotation:
            self._camera_image_rotation = camera_image_rotation
            self.cameraImageRotationChanged.emit()

    @pyqtProperty(str, fset = setCameraImageRotation, notify = cameraImageRotationChanged)
    def cameraImageRotation(self) -> str:
        return self._camera_image_rotation

    def setCameraImageMirror(self, camera_image_mirror: bool) -> None:
        if self._camera_image_mirror != camera_image_mirror:
            self._camera_image_mirror = camera_image_mirror
            self.cameraImageMirrorChanged.emit()

    @pyqtProperty(bool, fset = setCameraImageMirror, notify = cameraImageMirrorChanged)
    def cameraImageMirror(self) -> str:
        return self._camera_image_mirror