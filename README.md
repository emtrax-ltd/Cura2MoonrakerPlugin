# Cura2MoonrakerPlugin
- Allows you to upload Gcode directly from Cura to your Klipper-based 3D printer (Fluidd, Mainsailos etc.) using the Moonraker API.
- Uploading thumbnails via UFP (Ultimaker Format Package) is supported
- You can also start a print job using the upload process

## How to Install
The installation of this plugin is straightforward ... no compiling etc.

1. Download this repository as zip file (https://github.com/emtrax-ltd/Cura2MoonrakerPlugin/archive/main.zip) and unzip it
2. Find your Cura plugins directory:
   * Windows:
      * The default installation path is `C:\Program Files\Ultimaker Cura [version number]\plugins`.
      * The user based installation path is `C:\Users\<Your Username>\AppData\Roaming\cura\[version number]\plugins` (no admin privileges needed)
   * macOS:
      * Right-click on `Ultimaker Cura.app` in your `Applications` folder then click on `Show Package Contents`. The default installation path is `Ultimaker Cura.app -> Contents -> Resources -> Plugins -> Plugins`.
3. Copy the extracted `Cura2MoonrakerPlugin`folder into the Cura plugins folder you located in step 2. Attention: In the user based windows installation you have to copy the unzipped plugin directory into a parent directory with the same name. Looks like `...\cura\[version number]\plugins\Cura2MoonrakerPlugin\Cura2MoonrakerPlugin`.

## How to Configure
To configure your Moonraker 3D printer...
1. Go to Settings -> Printer -> Manage Printers
2. Select <Your Printername> and click on 'Connect Moonraker'
3. Fill in the URL and select your preferred output format
4. Click 'Save Config'

## How to Upload
1. Open your STL model in Cura and click `Slice`.
2. Click the small up arrow on the right and select `Upload to <Your Printername>`:
3. Now you can modify the filename, select the option to create a print job and finally... click `Upload` :)
