## Transition logic (start, pause, resume)
## Holds reference to UI view (UI scene onready)
## https://refactoring.guru/design-patterns/mediator
extends Node

enum State {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	SETTINGS,
}

var hud_visible: bool = true

var _ui: UIView
var _state: State = State.MAIN_MENU
## Tracks which state to return to when closing settings.
var _pre_settings_state: State = State.MAIN_MENU


func register_ui(ui: UIView) -> void:
	_ui = ui
	_set_state(State.MAIN_MENU)
	PauseManager.request_pause("main_menu")


func on_game_started() -> void:
	assert(_ui != null, "UIManager: no UIView registered in " + name)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PauseManager.release_pause("main_menu")
	PauseManager.release_pause("pause_menu")
	_set_state(State.PLAYING)


func on_game_paused() -> void:
	assert(_ui != null, "UIManager: no UIView registered in " + name)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PauseManager.request_pause("pause_menu")
	_set_state(State.PAUSED)


func open_settings() -> void:
	assert(_ui != null, "UIManager: no UIView registered in " + name)
	_pre_settings_state = _state
	_set_state(State.SETTINGS)


func close_settings() -> void:
	assert(_ui != null, "UIManager: no UIView registered in " + name)
	_set_state(_pre_settings_state)


func set_hud_visible(visible: bool) -> void:
	hud_visible = visible
	assert(_ui != null, "UIManager: no UIView registered in " + name)
	_ui.set_hud_visible(visible)


func is_in_main_menu() -> bool:
	return _state == State.MAIN_MENU


func _set_state(state: State) -> void:
	_state = state
	match state:
		State.MAIN_MENU:
			_ui.show_main_menu()
		State.PLAYING:
			_ui.show_game()
		State.PAUSED:
			_ui.show_pause_menu()
		State.SETTINGS:
			_ui.show_settings()
