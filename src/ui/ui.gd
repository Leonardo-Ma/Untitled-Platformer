class_name UIManager
extends CanvasLayer

static var instance: UIManager

@onready var menus: Control = %Menus
@onready var hud: Control = %HUD
@onready var overlays: Control = %Overlays
@onready var debug_interface: Control = %DebugInterface


# TODO Study this better, it is a 'locally declared singleton' globally accessible
func _enter_tree() -> void:
	instance = self


# TODO Check if this is the correct approach, probably not
# But idk a better way, send help :(
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Default state when the game first launches (Show Main Menu)
	menus.visible = true
	menus.get_node("MainMenu").visible = true
	menus.get_node("PauseMenu").visible = false

	hud.visible = false
	overlays.visible = false

	# Pause the game tree while main menu is open
	get_tree().paused = true


func on_game_started() -> void:
	# Recapture the mouse for 3D gameplay
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	menus.visible = false
	hud.visible = true
	overlays.visible = true

	# Ensure the tree plays
	get_tree().paused = false


func on_game_paused() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	menus.visible = true
	menus.get_node("MainMenu").visible = false
	menus.get_node("PauseMenu").visible = true

	hud.visible = false
	overlays.visible = false
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# If MainMenu is open, Esc should do nothing (or maybe open a quit prompt, but standard is nothing or quit).
		if menus.visible and menus.get_node("MainMenu").visible:
			return

		# Toggle pause/unpause if we are in game or already in the pause menu
		if not get_tree().paused:
			on_game_paused()
		else:
			on_game_started()

		get_viewport().set_input_as_handled()
