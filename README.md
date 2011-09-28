
MNColorPicker
=============
https://github.com/tweetings/MNColorPicker

Based on the original MNColorPicker by Markus Müller
http://bitbucket.org/aquarius/mncolorpicker/

Development
-----------
Tweetings
http://www.tweetings.net/
Markus Müller
http://www.mindnode.com/

Images
------
Johan H. W. Basberg

Other Sources
-------------

RGB component extraction is based on code from Erica Sadun release at
http://arstechnica.com/apple/guides/2009/02/iphone-development-accessing-uicolor-components.ars

This project started as a merge of:
http://www.v-vent.com/blog/?p=27
and
http://www.markj.net/iphone-uiimage-pixel-color/
It may still contain code bits from any of those projects. 

Usage
-----
1) Add the following classes and resources to your project:
MNColorPicker
MNColorWheelView
MNBrightnessView
MNMagnifyingView
UIColor+ColorSpaces
MNColorView
BrightnessWheel.png
ColorWheel.png
DoneDown.png
DoneDown3.png
DoneUp.png
DoneUp3.png

2) See RootViewController.m for instructions on how to create a MNColorPicker

3) Implement the MNColorPickerDelegate protocol. RootViewController contains an example implementation.


License
-------
BSD License