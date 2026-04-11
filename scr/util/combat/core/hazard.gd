class_name Hazard
extends StaticBody3D

@export var attack: Attack


func _ready() -> void:
	assert(attack and attack.damage > 0 and attack.type != null, "Attack property incorrect for " + self.name)
