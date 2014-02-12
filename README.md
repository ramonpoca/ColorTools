ase2clr
=======

Adobe Swatch Exchange file to Mac OS X CLR

This is a simple tool that reads a Adobe Swatch Excahnge (ASE) file and outputs a .clr file that you can 
copy to your ~/Library/Colors directory and use from the standard color picker.

* Supports RGB/CMYK and Gray colorspaces (Lab values will show black).
* Right now it ignores groups in the ASE file.

Info about Adobe Swatch Exchange files from: 
http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase

Usage:

    Ase2Clr Filename.ase

reads the palette from the ase file and outputs Filename.clr

    Ase2Clr Filename.ase -i

reads the palette from the ase file and imports it into ~/Library/Colors/Filename.clr

The resulting palette will be visible in the system color picker in (almost) any Mac app.

(c) Ramon Poca 2014 

