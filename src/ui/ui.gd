## View controller UI scene root. Implements View of MVC
## Registers itself to UIManager
class_name UIView
extends CanvasLayer

@onready var _menus: Control = %Menus
@onready var _hud: Control = %HUD
@onready var _overlays: Control = %Overlays

@onready var _main_menu: Control = %MainMenu
@onready var _pause_menu: Control = %PauseMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameEvents.hud_visibility_toggled.connect(_on_hud_visibility_toggled)
	UIManager.register_ui(self)


# BUG TODO Web version esc releases mouse and ignores this input
# Works on second esc press
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _main_menu.visible:
		return
	if not PauseManager.is_paused():
		UIManager.on_game_paused()
	else:
		UIManager.on_game_started()
	get_viewport().set_input_as_handled()


func show_main_menu() -> void:
	_menus.visible = true
	_main_menu.visible = true
	_pause_menu.visible = false
	_hud.visible = false
	_overlays.visible = false


func show_game() -> void:
	_menus.visible = false
	_hud.visible = GameEvents.hud_visible
	_overlays.visible = true


func show_pause_menu() -> void:
	_menus.visible = true
	_main_menu.visible = false
	_pause_menu.visible = true
	_hud.visible = false
	_overlays.visible = false


func _on_hud_visibility_toggled(visible: bool) -> void:
	GameEvents.hud_visible = visible
	_hud.visible = visible
