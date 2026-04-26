class_name Hazard
extends Node3D

signal activate
signal deactivate

@export var attack: Attack

@onready var hitbox: Hitbox = %Hitbox


func _ready() -> void:
	assert(attack and attack.damage > 0 and attack.type != null, "Attack property incorrect for " + name)

	if self.get_parent() is Area3D or StaticBody3D:
		self.body_entered.connect(_on_body_entered)
		self.body_exited.connect(_on_body_exited)
	else:
		assert(false, "I am not Area3D or StaticBody3D " + self.name)


func _on_body_entered(body: Node3D) -> void:
	if body is AggressiveEntity:
		hitbox.find_child("CollisionShape3D").disabled = false
		activate.emit()


func _on_body_exited(body: Node3D) -> void:
	if body is AggressiveEntity:
		hitbox.find_child("CollisionShape3D").disabled = true
		deactivate.emit()
