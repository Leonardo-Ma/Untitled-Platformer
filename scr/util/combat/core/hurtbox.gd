# https://www.youtube.com/watch?v=JWjzSn95bM0 GDQuest - How to Code Melee Attacks in Godot: Hitboxes and Hurtboxes
# https://www.youtube.com/watch?v=y3faMdIb2II Bitlytic - Maximize Your Game Development Potential with Classes in Godot (class_name is OP)

# https://www.youtube.com/watch?v=h5vpjCDNa-w& Bitlytic - How to use Resources in Godot 4

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
		var attack_used: Attack = hitbox.owner.attack
		owner.health.take_damage(attack_used)

		var attacker: Node = hitbox.owner
		assert(attacker != null, "Hitbox owner cannot be null on damage.")
		assert(attacker.has_node("%StatusManager"), "Attacker " + attacker.name + " missing StatusManager.")

		var damage_dealt: float = float(attack_used.power)
		attacker.get_node("%StatusManager").dispatch_event(&"on_damage_dealt", {"damage": damage_dealt})

	# TODO Confirm if this will ever be called
	else:
		push_error("Health not properly configured for " + owner.name)
