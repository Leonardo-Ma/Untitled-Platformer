# TODO Consider redo this script so each magic is actually an array property that can be
# easily changed like the inventory

@icon("res://icons/16x16/wizard.png")
extends Node

signal casted
signal cast_started(freeze_duration: float)

const EARTH_ATTACK: PackedScene = preload("uid://ch4rskg6ravmg")
const CAST_FREEZE_DURATION: float = 1.0

#@onready var timer: Timer = $Timer
@onready var cam_root: Node3D = %CamRoot


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("magic_z"):
		cast_started.emit(CAST_FREEZE_DURATION)

		var magic_attack: GroundedEarthAttack = EARTH_ATTACK.instantiate()
		magic_attack.position = owner.global_position
		magic_attack.rotation.y = owner.rotation.y
		casted.emit()
		self.add_child(magic_attack)

# TODO Redo this, it's the bridge between action pressed and showing on UI
#	func _physics_process(_delta: float) -> void:
#	TODO Use a switch(match) statement instead
#	TODO Remove from process and bind to a on_pressed signal
#	if Input.is_action_just_pressed("magic_z"):
#		timer.start()
#		self.text = "Z"
#	if Input.is_action_just_pressed("magic_x"):
#		timer.start()
#		self.text = "X"
#	if Input.is_action_just_pressed("magic_c"):
#		timer.start()
#		self.text = "C"
#
#
#	func _on_timer_timeout() -> void:
#		self.text = " "
