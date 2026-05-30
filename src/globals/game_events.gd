# https://refactoring.guru/design-patterns/observer
extends Node

@warning_ignore("unused_signal")
signal player_spawned(player: Node)
@warning_ignore("unused_signal")
signal counter_collectible_collected(identifier: StringName, amount: int, icon: Texture2D)
@warning_ignore("unused_signal")
signal status_buff_collected(status_effect: StatusEffect, icon: Texture2D)
@warning_ignore("unused_signal")
signal score_updated(new_score: int)
@warning_ignore("unused_signal")
signal player_respawning(duration: float)
@warning_ignore("unused_signal")
signal gold_changed(new_total: int)

var procedural_seed: int = 0
var player_score: int = 0
var gold: int = 0


func add_score(points: int) -> void:
	player_score += points
	score_updated.emit(player_score)


func remove_score(points: int) -> void:
	player_score -= points
	# TODO Improve
	if player_score <= 0:
		player_score = 0
	score_updated.emit(player_score)


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


## Returns false if insufficient funds
func remove_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true
