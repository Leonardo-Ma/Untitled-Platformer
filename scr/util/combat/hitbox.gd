# https://www.youtube.com/watch?v=JWjzSn95bM0 - How to Code Melee Attacks in Godot: Hitboxes and Hurtboxes

## Used to check when a hurtbox has collided
class_name Hitbox
extends Area3D

func _init() -> void:
	# Layer 20 (It's in bits)
	collision_layer = 524288
	collision_mask = 0
