# https://refactoring.guru/design-patterns/observer
extends Node

#region Player
@warning_ignore("unused_signal")
signal player_spawned(player: Node)
@warning_ignore("unused_signal")
signal counter_collectible_collected(identifier: StringName, amount: int, icon: Texture2D)
@warning_ignore("unused_signal")
signal status_buff_collected(status_effect: StatusEffect, icon: Texture2D)
signal score_updated(new_score: int)
@warning_ignore("unused_signal")
signal player_respawning(duration: float)
signal gold_updated(new_total: int)
@warning_ignore("unused_signal")
signal collectible_consumed(world_position: Vector3)
@warning_ignore("unused_signal")
signal enemy_killed(world_position: Vector3)
signal controlled_entity_changed(entity: Node3D)
#endregion

var procedural_seed: int = 0
var score: int = 0
var gold: int = 0
var controlled_entity: Node3D = null


func add_score(points: int) -> void:
	score += points
	score_updated.emit(score)


func remove_score(points: int) -> void:
	score -= points
	# TODO Improve
	if score <= 0:
		score = 0
	score_updated.emit(score)


func add_gold(amount: int) -> void:
	gold += amount
	gold_updated.emit(gold)


## Returns false if insufficient funds
func remove_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_updated.emit(gold)
	return true


func set_controlled_entity(entity: Node3D) -> void:
	controlled_entity = entity
	controlled_entity_changed.emit(entity)
