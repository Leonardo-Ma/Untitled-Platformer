class_name Checkpoint
extends Area3D

signal checkpoint_activated(checkpoint_node: Checkpoint)

@export var is_active: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not is_active and body is PlayerEntity:
		activate_checkpoint()


func activate_checkpoint() -> void:
	is_active = true
	# TODO Add animation, visual, sound for checkpoint activation
	checkpoint_activated.emit(self)

	CheckpointManager.on_checkpoint_activated(self)


func deactivate_checkpoint() -> void:
	is_active = false
	# TODO Add deactivation logic
