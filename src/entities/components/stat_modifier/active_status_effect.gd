class_name ActiveStatusEffect
extends RefCounted

signal expired(active_status: ActiveStatusEffect)

var status: StatusEffect
var target: Node
var current_stacks: int = 1
var remaining_time: float = 0.0
var tick_timer: float = 0.0


func _init(p_status: StatusEffect, p_target: Node) -> void:
	status = p_status
	target = p_target
	remaining_time = status.duration
	tick_timer = status.tick_interval
	status.on_apply(target)


func process_time(delta: float) -> void:
	# Process localized ticking to avoid spamming the main loop
	if status.tick_interval > 0.0:
		tick_timer -= delta
		if tick_timer <= 0.0:
			status.on_tick(target, status.tick_interval)
			tick_timer = status.tick_interval

	# Process duration
	if not status.is_infinite():
		remaining_time -= delta
		if remaining_time <= 0.0:
			expired.emit(self)


func handle_reapplication() -> void:
	match status.stack_mode:
		StatusEffect.StackMode.STACK:
			if current_stacks < status.max_stacks:
				current_stacks += 1
		StatusEffect.StackMode.REPLACE:
			remaining_time = status.duration
		StatusEffect.StackMode.ADD_DURATION:
			if not status.is_infinite():
				remaining_time += status.duration
		StatusEffect.StackMode.NONE:
			pass


func remove() -> void:
	status.on_remove(target)
