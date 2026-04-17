extends Area3D

# TODO Check if this is best approach
@export var attack: Attack
## The distance below the current checkpoint before the player dies
@export var fall_margin: float = 30.0

# Store the exact spot the player was born before any checkpoints existed
var _fallback_spawn: Vector3


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	CheckpointManager.checkpoint_activated.connect(_on_checkpoint_activated)
	call_deferred("_initialize_position")


func _physics_process(_delta: float) -> void:
	var player: Node3D = get_tree().get_first_node_in_group(Groups.PLAYERS)
	if player != null:
		# Since it's a BoxShape3D and not infinite, we DO need to update X and Z to cover the player's lateral movements!
		# The Y position strictly obeys the checkpoint height (it does not move up or down here).
		global_position.x = player.global_position.x
		global_position.z = player.global_position.z


func _initialize_position() -> void:
	var player: Node3D = get_tree().get_first_node_in_group(Groups.PLAYERS)
	if player != null:
		_fallback_spawn = player.global_position
		if CheckpointManager.has_active_checkpoint():
			global_position.y = CheckpointManager.get_respawn_position().y - fall_margin
		else:
			global_position.y = player.global_position.y - fall_margin


func _on_checkpoint_activated(checkpoint_position: Vector3) -> void:
	# Only update the Y height on signal
	global_position.y = checkpoint_position.y - fall_margin


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(Groups.PLAYERS):
		# TODO Add delay and animation
		if CheckpointManager.has_active_checkpoint():
			body.global_position = CheckpointManager.get_respawn_position()
		else:
			# Fallback if the player falls before hitting the first checkpoint
			body.global_position = _fallback_spawn
	else:
		print_debug("Something wrong here at " + self.name + " House.")
