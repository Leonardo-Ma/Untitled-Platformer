extends Node

signal checkpoint_activated(checkpoint_position: Vector3)

var _active_checkpoint: Checkpoint = null


func on_checkpoint_activated(new_checkpoint: Checkpoint) -> void:
	# Deactivate the old one to show visual changes
	if _active_checkpoint and _active_checkpoint != new_checkpoint:
		_active_checkpoint.deactivate_checkpoint()

	_active_checkpoint = new_checkpoint

	# TODO Implement save checkpoint active here (Probably save manager autoload)
	#SaveManager.save_game(new_checkpoint.global_position)
	print_debug("Checkpoint activated at: ", new_checkpoint.global_position)
	checkpoint_activated.emit(new_checkpoint.global_position)


func has_active_checkpoint() -> bool:
	return _active_checkpoint != null


func get_respawn_position() -> Vector3:
	assert(_active_checkpoint != null, "No active checkpoint found. Check if default spawn point defined.")
	return _active_checkpoint.global_position
