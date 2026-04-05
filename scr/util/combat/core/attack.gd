@icon("res://icons/16x16/sword.png")
## This is attached to 'Attack' resources on entities to deal damage (passing to hurtbox)
class_name Attack
extends Resource

#@export_group("Attack Type")
@export_flags("Physical", "Fire", "Earth", "Water", "Ice", "Lightning", "Wind") var type: int

#@export_group("Atributes")
@export_range(-99999, 99999, 1, "suffix:base dmg") var power: int
@export_range(-99, 99, 0.1, "suffix:meters") var knockback_force: float
@export_range(0.1, 999, 0.1, "suffix:Seconds/attack") var rate: float = 1
#@export var attack_position: Vector2
