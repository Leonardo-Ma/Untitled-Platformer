class_name JumpBoostStatus
extends StatusEffect

@export var bonus_speed: float = 5.0


func get_id() -> StringName:
	return &"jump_boost"


func get_status_name() -> String:
	return "Jump Boost"


func on_apply(_target: Node) -> void:
	var player: PlayerEntity = _target.owner as PlayerEntity
	if player and not _target.has_meta("jump_boost_applied"):
		player.movement.jump_velocity += bonus_speed
		_target.set_meta("jump_boost_applied", true)


func on_remove(_target: Node) -> void:
	var player: PlayerEntity = _target.owner as PlayerEntity
	if player and _target.has_meta("jump_boost_applied"):
		player.movement.jump_velocity -= bonus_speed
		_target.remove_meta("jump_boost_applied")
