class_name SpeedBoostStatus
extends StatusEffect

@export var bonus_speed: float = 5.0


func get_id() -> StringName:
	return &"speed_boost"


func get_status_name() -> String:
	return "Speed Boost"


func on_apply(_target: Node) -> void:
	var player: PlayerEntity = _target.owner as PlayerEntity
	if player and not _target.has_meta("speed_boost_applied"):
		player.movement.speed += bonus_speed
		_target.set_meta("speed_boost_applied", true)


func on_remove(_target: Node) -> void:
	var player: PlayerEntity = _target.owner as PlayerEntity
	if player and _target.has_meta("speed_boost_applied"):
		player.movement.speed -= bonus_speed
		_target.remove_meta("speed_boost_applied")
