# Ase2clr & SwatchInstall

Adobe Swatch Exchange import to Mac OS X CLR (ColorPicker Palette)

## SwatchInstall.app

This is a desktop app that allows you to drop an ASE file on it and imports it into ColorPicker.

## Ase2Clr

This is a command line tool that reads a Adobe Swatch Excahnge (ASE) file and outputs a .clr file that you can 
copy to your ~/Library/Colors directory and use from the standard ColorPicker (third tab, palette). It can also install it for you with ```-i```.

* Supports RGB/CMYK and Gray colorspaces (Lab values will show black).
* Right now it ignores groups in the ASE file.

Usage:

```
    Ase2Clr FileName.ase
```

Will produce ```Filename.clr``` in the same path.

```
   Ase2Clr FileName.ase -i
```

Will install the generated file in ~/Library/Colors. You might need to re-open the colorpicker for it to refresh the color lists.


## Html2Clr

This tool reads a file containing a list of hex-coded colors and outputs a .clr file for ColorPicker or installs the list in the system color picker as a new palette.

The input format is #RRGGBB colors in separate lines:
```
#fa3ada
#cada32
...
```
The usage is analog to Ase2Clr:

```
   Html2Clr File.txt [-i]
```


(c) Ramon Poca 2014. MIT Licensed.
