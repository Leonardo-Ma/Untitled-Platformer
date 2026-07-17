class_name Main
extends Node


func _ready() -> void:
	LevelChunkManager.initialize_level()

	#var player: PlayerEntity = player_scene.instantiate()
	#var boundary: FloorLevelBoundary = boundary_scene.instantiate()
#
#boundary.target = player
#
#world.add_child(player)
#world.add_child(boundary)
