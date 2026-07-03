## Level trigger that returns control from a car back to player
class_name CarExitZone
extends Area3D


func _init() -> void:
	collision_layer = 0
	collision_mask = 8  # Layer 4 (World Object)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	var car: Car = body as Car
	if car == null or not car.is_driven:
		return
	car.exit(car.global_position)
