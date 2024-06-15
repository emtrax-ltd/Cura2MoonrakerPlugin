# Cura & Klipper - MoonrakerConnection Plugin
- Allows you to upload Gcode directly from Cura to your Klipper-based 3D printer (Fluidd, Mainsail etc.) using the Moonraker API.
- Uploading thumbnails via UFP (Ultimaker Format Package) is supported
- You can also start a print job using the upload process

## How to Install
The installation of this plugin is straightforward, no compiling, etc.

1. Download this repository as zip file (https://github.com/emtrax-ltd/Cura2MoonrakerPlugin/archive/main.zip) and unzip it.
2. Find your Cura plugins directory:
   * In Cura menu click "Help" -> "Show Configuration Folder" and then open the "plugins" subdirectory
     * Windows: `%APPDATA%\Roaming\cura\[version number]\plugins`
     * macOS: `$HOME/Library/Application Support/cura/[version number]/plugins`
     * Linux: `$HOME/.local/share/cura/[version number]/plugins`.
3. Copy the extracted folder `MoonrakerConnection` into the Cura plugins folder you located in step 2. Attention: In the user based windows installation you have to copy the unzipped plugin directory into a parent directory with the same name. It looks like `...\cura\[version number]\plugins\MoonrakerConnection\MoonrakerConnection`.
4. If Cura is already running: quit, and restart it.

## How to Configure
To configure your Moonraker 3D printer:
1. Go to `Settings` -> `Printer` -> `Manage Printers`.
2. Select <Your Printername> and click on `Connect Moonraker`.
3. Fill in the URL and select your preferred output format. Sometimes it is necessary to specify the port within the URL - the value for this can be found in `moonraker.conf`.
4. Optionally, configure one or more power devices to turn on before starting print.
5. Finally click `Create` or `Save`.

## How to Upload
1. Open your STL model in Cura and click `Slice`.
2. Click the small up arrow on the right and select `Upload to <Printername>`.
3. Now you can modify the filename, select the option to create a print job and finally... click `Upload` :)
  
## How to "Filename Translation"
This is a requested feature to replace/remove special characters within the suggested filename (by Cura) before uploading it to Moonraker. The working principle is relatively simple: replacement by mapping characters 1:1 from "input" into "output" and deleting by putting the unwanted characters into "remove".

Example:
  - input: " ."  <- first character is a whitespace
  - output: "_-"
  - remove: "()"

  "Simple Test v1.0 (ABS)" results into "Simple_Test_v1-0_ABS"

## Power Devices
If you have devices configured for power control in Moonraker, you can configure them in 
the plug-in. For a single device, just enter that device's name from Moonraker config.

If you have more than one power device you wish to turn on, enter a comma-separated list,
with the first device being the device that will be queried before attempting to turn anything on.

Example:
 - Target: One config device with an entry name of [power printer]
 - Setting value: "printer" (no quotes)
 - Action: Query "printer" device state, turn everything on if "printer" is off.
 
 - Target: Two devices, one with an entry name of "[power printer]", and another called "[power lights]"
 - Setting value: "printer, lights" (no quotes, whitespace will be ignored)
 - Action: Query "printer" device state, turn everything on if "printer" is off. "lights" device
   state will be ignored.

----

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/emtrax)
    or
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/emtrax)

