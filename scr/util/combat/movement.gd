## To be used with movement controller
@icon("res://icons/16x16/entity_move.png")
class_name Movement
extends Resource

@export_range(3.0, 100.0, 0.1, "suffix:meters/second?") var walk_speed: float = 3.0
@export_range(5.0, 150.0, 0.1, "suffix:meters/second?") var run_speed: float = 5.0
