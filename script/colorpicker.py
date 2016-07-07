#!/usr/bin/python

import sys
from gi.repository import Gtk
from gi.repository import Gdk

picker = Gtk.ColorSelectionDialog("Color Picker")

rgb = True

if len(sys.argv) >= 2:
    color = Gdk.color_parse(sys.argv[1])
    
    if color:
        rgb = False
        picker.get_color_selection().set_current_color(color)
        
    if len(sys.argv) > 3:
        picker.get_color_selection().set_current_color(Gdk.Color(red=int(sys.argv[1]) * 257, green=int(sys.argv[2]) * 257, blue=int(sys.argv[3]) * 257))
        
if picker.run() == getattr(Gtk, 'RESPONSE_OK', Gtk.ResponseType.OK):
    
    color = picker.get_color_selection().get_current_color()
    r, g, b = [int(c / 256) for c in [color.red, color.green, color.blue]]
    if rgb:
        print(str(r) + "," + str(g) + "," +  str(b))
    else:
        print("#{:02x}{:02x}{:02x}".format(r, g, b).upper())

picker.destroy()
