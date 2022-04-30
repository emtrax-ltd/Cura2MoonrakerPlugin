USE_QT5 = False
try:
    from PyQt6.QtCore import QTimer
except ImportError:
    from PyQt5.QtCore import QTimer
    USE_QT5 = True

from cura.PrinterOutput.PrinterOutputDevice import PrinterOutputDevice
from cura.PrinterOutput.PrinterOutputController import PrinterOutputController

class MoonrakerOutputController(PrinterOutputController):
    def __init__(self, output_device: PrinterOutputDevice) -> None:
        super().__init__(output_device)
        self.can_pause = True
        self.can_abort = True
        self.can_pre_heat_bed = True
        self.can_pre_heat_hotends = True
        self.can_send_raw_gcode = False
        self.can_control_manually = True
        self.can_update_firmware = False


