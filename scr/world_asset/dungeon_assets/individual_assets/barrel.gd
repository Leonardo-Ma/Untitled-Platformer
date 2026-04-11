extends RigidBody3D

@export var health: Health


func _ready() -> void:
	health.died.connect(_on_death)


func _on_death() -> void:
	print("dead")
