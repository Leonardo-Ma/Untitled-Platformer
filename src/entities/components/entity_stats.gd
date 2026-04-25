## General entity stats
## Health and attack specifics are in another castle

@icon("res://icons/16x16/script.png")
class_name EntityStats
extends Resource

signal stats_changed

@export var base_stats: Dictionary[StatTypes.Type, float] = {}


func _init() -> void:
	for stat_val: int in StatTypes.Type.values():
		var stat: StatTypes.Type = stat_val as StatTypes.Type
		if not base_stats.has(stat):
			base_stats[stat] = 0.0


func get_stat(stat: StatTypes.Type) -> float:
	return base_stats.get(stat, 0.0)


func set_stat(stat: StatTypes.Type, value: float) -> void:
	base_stats[stat] = value
	stats_changed.emit()
