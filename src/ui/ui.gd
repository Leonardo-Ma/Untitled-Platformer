## View controller UI scene root. Implements View of MVC
## Registers itself to UIManager
class_name UIView
extends CanvasLayer

@onready var _menus: MenusView = %Menus
@onready var _hud: Control = %HUD
@onready var _overlays: Control = %Overlays


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	UIManager.register_ui(self)


# BUG Web version: ESC releases mouse and ignores this on first press.
# Works on second ESC press.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_hud"):
		UIManager.set_hud_visible(not UIManager.hud_visible)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("quick_save") and UIManager.is_playing():
		SaveManager.save_to_quick_slot()
		get_viewport().set_input_as_handled()
		return

	if not event.is_action_pressed("ui_cancel"):
		return
	if UIManager.is_in_main_menu():
		return
	if UIManager.is_in_settings():
		UIManager.close_menu()
		get_viewport().set_input_as_handled()
		return
	if not PauseManager.is_paused():
		UIManager.on_game_paused()
	else:
		UIManager.on_game_started()
	get_viewport().set_input_as_handled()


func show_main_menu() -> void:
	_menus.visible = true
	_menus.show_main_menu()
	_hud.visible = false
	_overlays.visible = false


func show_save_menu() -> void:
	_menus.visible = true
	_menus.show_save_menu()
	_hud.visible = false
	_overlays.visible = false


func show_game() -> void:
	_menus.visible = false
	_hud.visible = UIManager.hud_visible
	_overlays.visible = true


func show_pause_menu() -> void:
	_menus.visible = true
	_menus.show_pause_menu()
	_hud.visible = false
	_overlays.visible = false


func show_settings() -> void:
	_menus.visible = true
	_menus.show_settings()


func show_achievements() -> void:
	_menus.visible = true
	_menus.show_achievements()
	_hud.visible = false
	_overlays.visible = false


func set_hud_visible(is_visible: bool) -> void:
	_hud.visible = is_visible
