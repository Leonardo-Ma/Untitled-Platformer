# Graphical User Interface (GUI) guide

- GUIs need to be usable with the mouse and a controller.

- Do not use Control offsets to try to position elements, that's not good
  Godot usage. Use proper parent container and min size instead.

- For spacing elements use either a spacer (that has a visual
  appearance) or for invisible space use an empty Control with rect
  `minsize` set to the amount of blank you want.

- Don't use text in the GUI with leading or trailing spaces to add
  padding, see previous bullet instead.

- When using fonts, don't directly load the .ttf file with an embedded
  font in a scene file. Instead create a label settings in
  `src/gui_common/fonts` folder and use that. This is needed because
  fonts need to have settings like fallback fonts set, for example
  Chinese. All fonts should be TrueType (`.ttf`) and stored in
  `assets/fonts`. For variable weight fonts the variants created from
  the font should be placed in `assets/fonts/variants`. For buttons
  that cannot use label settings, it is preferably to just set a
  theme font size override, but when really needed the override font
  can be set, but care needs to be taken that this points to a proper
  font. For variable weight fonts only the variants should be used and
  not the base font directly.

- All images used in the GUI should have mipmaps on in the import
  options.
