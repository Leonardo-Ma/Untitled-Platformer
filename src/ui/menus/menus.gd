## Controls menus visibility
class_name MenusView
extends Control

@onready var _main_menu: Control = %MainMenu
@onready var _pause_menu: Control = %PauseMenu
@onready var _settings_menu: Control = %SettingsMenu
@onready var _save_menu: Control = %SaveMenu


func show_main_menu() -> void:
	_main_menu.visible = true
	_pause_menu.visible = false
	_settings_menu.visible = false
	_save_menu.visible = false


func show_save_menu() -> void:
	_main_menu.visible = false
	_pause_menu.visible = false
	_settings_menu.visible = false
	_save_menu.visible = true


func show_pause_menu() -> void:
	_main_menu.visible = false
	_pause_menu.visible = true
	_settings_menu.visible = false
	_save_menu.visible = false


func show_settings() -> void:
	_main_menu.visible = false
	_pause_menu.visible = false
	_settings_menu.visible = true
	_save_menu.visible = false
