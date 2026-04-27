# https://refactoring.guru/design-patterns/observer
extends Node

@warning_ignore("unused_signal")
signal player_spawned(player: Node)
@warning_ignore("unused_signal")
signal counter_collectible_collected(identifier: StringName, amount: int, icon: Texture2D)
@warning_ignore("unused_signal")
signal score_updated(new_score: int, added_points: int)
@warning_ignore("unused_signal")
signal player_respawning(duration: float)

var procedural_seed: int = 0
var player_score: int = 0


func add_score(points: int) -> void:
	player_score += points
	score_updated.emit(player_score, points)
