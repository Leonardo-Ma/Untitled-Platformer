@icon("res://icons/16x16/star.png")
class_name StatModifierManager
extends Node

signal effects_changed
signal event_dispatched(event_name: StringName, data: Dictionary)

@export var initial_effects: Array[StatusEffect] = []

var _active_effects: Dictionary = {}  # Dictionary[StringName, ActiveStatusEffect]
var _base_stats: Dictionary = {}  # Dictionary[StringName, float]
var _cached_stats: Dictionary = {}  # Dictionary[StringName, float]

var _target: Node = null


func _ready() -> void:
	_target = get_parent()
	for effect: StatusEffect in initial_effects:
		if effect:
			apply_effect(effect)


func _process(delta: float) -> void:
	# Process effects
	for key: StringName in _active_effects:
		var active: ActiveStatusEffect = _active_effects[key]
		active.process_time(delta)


func apply_effect(effect: StatusEffect) -> void:
	if _active_effects.has(effect.id):
		_active_effects[effect.id].handle_reapplication()
	else:
		var new_active: ActiveStatusEffect = ActiveStatusEffect.new(effect, _target)
		new_active.expired.connect(_on_effect_expired)
		_active_effects[effect.id] = new_active

	_recalculate_all_stats()
	effects_changed.emit()


func remove_effect(effect_id: StringName) -> void:
	if _active_effects.has(effect_id):
		var active: ActiveStatusEffect = _active_effects[effect_id]
		active.expired.disconnect(_on_effect_expired)
		active.remove()
		_active_effects.erase(effect_id)
		_recalculate_all_stats()
		effects_changed.emit()


func _on_effect_expired(active_effect: ActiveStatusEffect) -> void:
	remove_effect(active_effect.effect.id)


func dispatch_event(event_name: StringName, data: Dictionary) -> void:
	for key: StringName in _active_effects:
		var active: ActiveStatusEffect = _active_effects[key]
		active.effect.on_event(_target, event_name, data)
	event_dispatched.emit(event_name, data)


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

	for key: StringName in _active_effects:
		var active: ActiveStatusEffect = _active_effects[key]
		for mod: StatModifier in active.effect.modifiers:
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
