class_name UIManager
extends CanvasLayer

static var instance: UIManager

@onready var menus: Control = $Menus
@onready var hud: Control = $HUD
@onready var overlays: Control = $Overlays
@onready var debug_interface: Control = $DebugInterface
@onready var inventory_interface: Control = $InventoryInterface


func _enter_tree() -> void:
	instance = self


# TODO Check if this is the correct approach, probably not
# But idk a better way, send help :(
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Default state when the game first launches
	menus.visible = true

	hud.visible = false
	overlays.visible = false
	inventory_interface.visible = false

	# Pause the game tree while main menu is open
	get_tree().paused = true


func on_game_started() -> void:
	# Recapture the mouse for 3D gameplay
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	menus.visible = false
	hud.visible = true
	overlays.visible = true
	inventory_interface.visible = true
