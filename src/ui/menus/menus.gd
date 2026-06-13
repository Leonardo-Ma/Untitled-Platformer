extends Control

@onready var pause_menu: Control = %PauseMenu
@onready var settings_menu: Control = %SettingsMenu


func _ready() -> void:
	GameEvents.settings_opened.connect(_on_settings_opened)
	GameEvents.settings_closed.connect(_on_settings_closed)


func _on_settings_opened() -> void:
	settings_menu.show()
	pause_menu.hide()


func _on_settings_closed() -> void:
	settings_menu.hide()
