## Coordinates music state with game state. Listens to GameStateManager signals.
extends Node


func _ready() -> void:
	GameStateManager.state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: GameStateManager.GameState, previous_state: GameStateManager.GameState) -> void:
	match new_state:
		GameStateManager.GameState.MAIN_MENU:
			SoundManager.change_music_state(MusicController.MusicState.MAIN_MENU, true)
		GameStateManager.GameState.PLAYING:
			if previous_state == GameStateManager.GameState.PAUSED:
				# Resume from pause, continue music
				pass
			else:
				SoundManager.change_music_state(MusicController.MusicState.EXPLORATION, true)
		GameStateManager.GameState.PAUSED:
			# Keep music playing but could lower volume if desired
			pass
		GameStateManager.GameState.SETTINGS:
			pass
		GameStateManager.GameState.SAVE_MENU:
			pass
		GameStateManager.GameState.ACHIEVEMENTS_MENU:
			pass
		GameStateManager.GameState.MAIN_MENU_SETTINGS:
			pass
