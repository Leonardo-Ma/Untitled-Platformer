extends Node


func _ready() -> void:
	var is_steam_running: bool = Steam.isSteamRunning()

	if !is_steam_running:
		push_error("Steam not running")
		return

	var steam_player_name: String = Steam.getPersonaName()
	print("Username: ", steam_player_name + "\n")


func _process(_delta: float) -> void:
	Steam.run_callbacks()
