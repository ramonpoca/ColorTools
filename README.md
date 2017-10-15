# Mac OS X developer color tools

Small tools to import and export colors from the Mac OS X ColorPicker palettes (.CLR).

* Adobe Swatch Exchange (.ASE) import and export.
* Hex color list to system palette.
* Simple UIColor category generation from color lists.
* Color search&replace from .xib/.storyboard

You can find binaries of those tools in the [Releases](https://github.com/ramonpoca/ColorTools/releases) tab up there.

## SwatchInstall.app

This is a desktop app that allows you to drop an ASE file on it and imports it into ColorPicker.

## Ase2Clr

This is a command line tool that reads a Adobe Swatch Excahnge (ASE) file and outputs a .clr file that you can 
copy to your ~/Library/Colors directory and use from the standard ColorPicker (third tab, palette). It can also install it for you with ```-i```.

* Supports RGB/CMYK and Gray colorspaces (Lab values will show black).
* Right now it ignores groups in the ASE file.

Usage:

    Ase2Clr FileName.ase

Will produce ```Filename.clr``` in the same path.

    Ase2Clr FileName.ase -i

Will install the generated file in ~/Library/Colors. You might need to re-open the colorpicker for it to refresh the color lists.

## Clr2Ase

This tool allows you to read a Clr file or a named ColorPicker palette and export an ASE file that you can load in Adobe Suite.

	 Clr2Ase "Name of color list"

Will produce ``Name of color list.ase``.

## Html2Clr

This tool reads a file containing a list of hex-coded colors and outputs a .clr file for ColorPicker or installs the list in the system color picker as a new palette.

The input format is #RRGGBB colors followed by their names, separated by a space, in separate lines:

    #fa3ada Almost-Magenta
    #cada32 Green-Mustard
    #ff6347 Tomato
    ...

The usage is analog to Ase2Clr:

    Html2Clr File.txt [-i]

## Clr2Obj

This tool creates UIColor (iOS) categories from system colorlists (either installed or from a .clr file).
Note that this tool is very basic. Duplication of methods is not checked, and only RGBA colors are generated.

Usage:

    Clr2Obj "Color List"|File.clr [CategoryName]

## xibcolor

This is a python script to search and replace colors inside xib/storyboard files (only xml format).

*BEWARE*: This will overwrite the file! Back up your file first (or have it commited in version control).


Usage:

    xibcolor file [-l|replacements|["#fromcolor" "#tocolor"]]
      file          a .storyboard or xib in new XML format
      -l            list colors present in the file
      replacements  a file consisting of pairs of hex-coded from->to colors
      #color        a pair of colors to replace



(c) Ramon Poca 2014. MIT Licensed.
