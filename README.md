# Klipper & Cura - Cura2MoonrakerPlugin
- Allows you to upload Gcode directly from Cura to your Klipper-based 3D printer (Fluidd, Mainsailos etc.) using the Moonraker API.
- Uploading thumbnails via UFP (Ultimaker Format Package) is supported
- You can also start a print job using the upload process

## How to Install
The installation of this plugin is straightforward ... no compiling etc.

1. Download this repository as zip file (https://github.com/emtrax-ltd/Cura2MoonrakerPlugin/archive/main.zip) and unzip it.
2. Find your Cura plugins directory:
   * Windows:
      * The default installation path is `C:\Program Files\Ultimaker Cura [version number]\plugins`.
      * The user based installation path is `C:\Users\<Your Username>\AppData\Roaming\cura\[version number]\plugins` (no admin privileges needed)
   * macOS:
      * Right-click on `Ultimaker Cura.app` in your `Applications` folder then click on `Show Package Contents`. The default installation path is `Ultimaker Cura.app -> Contents -> Resources -> Plugins -> Plugins`.
   * linux:
      * The user based installation path is at `~/.local/share/cura/[version number]/plugins`.
3. Copy the extracted `Cura2MoonrakerPlugin`folder into the Cura plugins folder you located in step 2. Attention: In the user based windows installation you have to copy the unzipped plugin directory into a parent directory with the same name. Looks like `...\cura\[version number]\plugins\Cura2MoonrakerPlugin\Cura2MoonrakerPlugin`.
4. If Cura is allready running: quit and restart it.

## How to Configure
To configure your Moonraker 3D printer...
1. Go to `Settings` -> `Printer` -> `Manage Printers`.
2. Select <Your Printername> and click on `Connect Moonraker`.
3. Fill in the URL and select your preferred output format.
4. Optionally, configure one or more power devices to turn on before starting print.
5. Click `Close` - changes will be automatically be saved.

## How to Upload
1. Open your STL model in Cura and click `Slice`.
2. Click the small up arrow on the right and select `Upload to <Printername>`.
3. Now you can modify the filename, select the option to create a print job and finally... click `Upload` :)
  
## How to "Filename Translation"
This is a requested feature to replace/remove special chracters within the suggested filename (by Cura) before uploading it to moonraker. The working principle is relativly simple: replacement by mapping characters 1:1 from "input" into "output" and removement by putting the unwanted characters into "remove".

Example:
  - input: " ."  <- first character is a whitespace
  - output: "_-"
  - remove: "()"

  "Simple Test v1.0 (ABS)" results into "Simple_Test_v1-0_ABS"

## Power Devices
If you have devices configured for power control in Moonraker, you can configure them in 
the plug-in. For a single device, just enter that device's name from Moonraker config.

If you have more than one power device you wish to turn on, enter a comma-separated list,
with the first device being the device that will be queried before attempting to turn anything
on.

Example:
 - Target: One config device with an entry name of [power printer]
 - Setting value: "printer" (no quotes)
 - Action: Query "printer" device state, turn everything on if "printer" is off.
 
 - Target: Two devices, one with an entry name of "[power printer]", and another called "[power lights]"
 - Setting value: "printer, lights" (no quotes, whitespace will be ignored)
 - Action: Query "printer" device state, turn everything on if "printer" is off. "lights" device
   state will be ignored.

----

<a href="https://www.buymeacoffee.com/emtrax" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
