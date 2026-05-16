class_name LargeDoor
extends Node3D

@export var _button: Area3D = null

@onready var door: MeshInstance3D = $Door


func _ready() -> void:
	_button.button_toggled_on.connect(open)
	_button.button_toggled_off.connect(close)


func open() -> void:
	door.rotation.y = -90


func close() -> void:
	door.rotation.y = 0
