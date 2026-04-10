# https://www.youtube.com/watch?v=JWjzSn95bM0 GDQuest - How to Code Melee Attacks in Godot: Hitboxes and Hurtboxes
# https://www.youtube.com/watch?v=y3faMdIb2II Bitlytic - Maximize Your Game Development Potential with Classes in Godot (class_name is OP)

## Upon colliding with a hitbox, triggers take damage from colliding entity, passing own attack
class_name Hurtbox
extends Area3D


func _init() -> void:
	collision_layer = 0
	collision_mask = 524288  # Layer 20 (It's in bits)


func _ready() -> void:
	connect("area_entered", self._on_area_entered)


func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return

	if owner.health is Health:
		var attacker: Node = hitbox.get_parent()
		var attack_used: Attack = attacker.attack
		owner.health.take_damage(attack_used)

		hitbox.on_hit_connected(float(attack_used.power))
