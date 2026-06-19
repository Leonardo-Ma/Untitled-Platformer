# https://www.youtube.com/watch?v=JWjzSn95bM0 - How to Code Melee Attacks in Godot: Hitboxes and Hurtboxes

## Used to check when a hurtbox has collided
class_name Hitbox
extends Area3D


func _init() -> void:
	collision_layer = 524288  # Layer 20 (It's in bits)
	collision_mask = 0


# TODO Remove this status manager event on damage dealt and swap for respective different type treatment
# like: acid or fire doing DoT damage
func on_hit_connected(damage_dealt: float) -> void:
	var attacker: Node = owner
	var status_manager: Node = attacker.status_manager
	if status_manager:
		status_manager.dispatch_event(&"on_damage_dealt", {"damage": damage_dealt})
