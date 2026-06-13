# TODO Check if force same order is best approach
## Manages tab switching for the settings menu
## Tabs and options should be in same order
extends VBoxContainer

@export var tabs: Array[Button] = []
@export var panels: Array[VBoxContainer] = []


func _ready() -> void:
	assert(tabs.size() == panels.size(), "Tab/panel count mismatch in " + name)
	var group: ButtonGroup = ButtonGroup.new()
	for i: int in tabs.size():
		tabs[i].toggle_mode = true
		tabs[i].button_group = group
		tabs[i].pressed.connect(_show_panel.bind(i))
	tabs[0].button_pressed = true
	_show_panel(0)


func _show_panel(index: int) -> void:
	for i: int in panels.size():
		panels[i].visible = i == index
