extends Area3D

# TODO Check if this is best approach
@export var attack: Attack


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(Groups.PLAYERS):
		# TODO Add delay and animation
		body.global_position = CheckpointManager.get_respawn_position()
	else:
		print_debug("Something wrong here at " + self.name + " House.")
