# BUG Need to apply this for all UI nodes in a single script
## Dynamic UI font size scaling for menus resizing
class_name ScaleFontSize
extends Control


func _ready() -> void:
	get_viewport().size_changed.connect(_on_window_resized)
	_on_window_resized()


func _on_window_resized() -> void:
	var window_size: Vector2 = get_viewport_rect().size
	var base_font_size: int = int(max(12.0, window_size.y * 0.035))

	for child: Control in get_children():
		print(child)
		if child is Button:
			child.add_theme_font_size_override("font_size", base_font_size)
		elif child is Label:
			child.add_theme_font_size_override("font_size", int(base_font_size * 1.5))
