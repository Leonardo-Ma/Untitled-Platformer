## Coordinates high-level game state transitions (start, pause, resume).
## Holds a reference to the active UI view, registered by the UI scene on ready.
## Implements the Mediator pattern between input sources and the UI view.
extends Node

var _ui: UIView


func register_ui(ui: UIView) -> void:
	_ui = ui
	_ui.show_main_menu()
	PauseManager.request_pause("main_menu")


func on_game_started() -> void:
	assert(_ui != null, "UIManager: no UIView registered")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PauseManager.release_pause("main_menu")
	PauseManager.release_pause("pause_menu")
	_ui.show_game()


func on_game_paused() -> void:
	assert(_ui != null, "UIManager: no UIView registered")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PauseManager.request_pause("pause_menu")
	_ui.show_pause_menu()
