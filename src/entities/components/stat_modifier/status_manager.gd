@icon("res://icons/16x16/star.png")
class_name StatusManager
extends Node

signal statuses_changed
signal event_dispatched(event_name: StringName, data: Dictionary)

@export_category("Statuses")
## Statuses that are permanent/innate (like passives or racial bonuses)
@export var permanent_statuses: Array[StatusEffect] = []
## Statuses that are applied temporarily at the start (e.g., starting with a timed buff)
@export var initial_statuses: Array[StatusEffect] = []

var _active_statuses: Dictionary = {}  # Dictionary[StringName, ActiveStatusEffect]
var _base_stats: Dictionary = {}  # Dictionary[StatTypes.Type, float]
var _cached_stats: Dictionary = {}  # Dictionary[StatTypes.Type, float]

var _target: Node = null


func _ready() -> void:
	_target = get_parent()
	for status: StatusEffect in permanent_statuses:
		if status:
			apply_status(status)
	for status: StatusEffect in initial_statuses:
		if status:
			apply_status(status)


func _process(delta: float) -> void:
	for key: StringName in _active_statuses:
		var active: ActiveStatusEffect = _active_statuses[key]
		active.process_time(delta)


func apply_status(status: StatusEffect) -> void:
	if _active_statuses.has(status.id):
		_active_statuses[status.id].handle_reapplication()
	else:
		var new_active: ActiveStatusEffect = ActiveStatusEffect.new(status, _target)
		new_active.expired.connect(_on_status_expired)
		_active_statuses[status.id] = new_active

	_recalculate_all_stats()
	statuses_changed.emit()


func remove_status(status_id: StringName) -> void:
	if _active_statuses.has(status_id):
		var active: ActiveStatusEffect = _active_statuses[status_id]
		active.expired.disconnect(_on_status_expired)
		active.remove()
		_active_statuses.erase(status_id)
		_recalculate_all_stats()
		statuses_changed.emit()


func _on_status_expired(active_status: ActiveStatusEffect) -> void:
	remove_status(active_status.status.id)


func dispatch_event(event_name: StringName, data: Dictionary) -> void:
	for key: StringName in _active_statuses:
		var active: ActiveStatusEffect = _active_statuses[key]
		active.status.on_event(_target, event_name, data)
	event_dispatched.emit(event_name, data)


func clear_temporary_statuses() -> void:
	var keys_to_remove: Array[StringName] = []
	for key: StringName in _active_statuses:
		var active: ActiveStatusEffect = _active_statuses[key]
		if active.status not in permanent_statuses:
			keys_to_remove.append(key)

	for key: StringName in keys_to_remove:
		remove_status(key)


# --- Stat Pipeline ---


func set_base_stat(stat: StatTypes.Type, value: float) -> void:
	_base_stats[stat] = value
	_recalculate_stat(stat)


func get_stat(stat: StatTypes.Type) -> float:
	if _cached_stats.has(stat):
		return _cached_stats[stat]
	if _base_stats.has(stat):
		return _base_stats[stat]
	return 0.0


## Formula: (Base + Flat Additions) * Multipliers + Post Multiplier Flat Additions
func _recalculate_stat(stat: StatTypes.Type) -> void:
	var base_val: float = _base_stats.get(stat, 0.0)

	var add_val: float = 0.0
	var mul_val: float = 1.0  # Multipliers usually base off 1.0
	var post_add_val: float = 0.0

	for key: StringName in _active_statuses:
		var active: ActiveStatusEffect = _active_statuses[key]
		for mod: StatModifier in active.status.modifiers:
			if mod.target_stat == stat:
				match mod.type:
					StatModifier.ModifierType.ADD:
						add_val += (mod.value * active.current_stacks)
					StatModifier.ModifierType.MULTIPLY:
						mul_val *= pow(mod.value, active.current_stacks)  # Exponential stacking for multipliers, adjust if linear desired
					StatModifier.ModifierType.POST_ADD:
						post_add_val += (mod.value * active.current_stacks)

	var final_val: float = (base_val + add_val) * mul_val + post_add_val
	_cached_stats[stat] = final_val


func _recalculate_all_stats() -> void:
	# Recompute only stats that currently exist as base stats
	for stat: StatTypes.Type in _base_stats:
		_recalculate_stat(stat)
