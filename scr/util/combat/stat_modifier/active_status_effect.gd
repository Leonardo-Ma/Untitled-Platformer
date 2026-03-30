class_name ActiveStatusEffect
extends RefCounted

signal expired(effect: ActiveStatusEffect)

var effect: StatusEffect
var target: Node
var current_stacks: int = 1
var remaining_time: float = 0.0
var tick_timer: float = 0.0


func _init(p_effect: StatusEffect, p_target: Node) -> void:
	effect = p_effect
	target = p_target
	remaining_time = effect.duration
	tick_timer = effect.tick_interval
	effect.on_apply(target)


func process_time(delta: float) -> void:
	# Process localized ticking to avoid spamming the main loop
	if effect.tick_interval > 0.0:
		tick_timer -= delta
		if tick_timer <= 0.0:
			effect.on_tick(target, effect.tick_interval)
			tick_timer = effect.tick_interval

	# Process duration
	if not effect.is_infinite():
		remaining_time -= delta
		if remaining_time <= 0.0:
			expired.emit(self)


func handle_reapplication() -> void:
	match effect.stack_mode:
		StatusEffect.StackMode.STACK:
			if current_stacks < effect.max_stacks:
				current_stacks += 1
		StatusEffect.StackMode.REPLACE:
			remaining_time = effect.duration
		StatusEffect.StackMode.ADD_DURATION:
			if not effect.is_infinite():
				remaining_time += effect.duration
		StatusEffect.StackMode.NONE:
			pass


func remove() -> void:
	effect.on_remove(target)
