## Configuration data for visual perception processing
class_name VisualConfig
extends Resource

@export var visual_range: float = 30.0
@export var field_of_view: float = 120.0
@export_flags_3d_physics var collision_mask: int = 1
@export var distance_weight: float = 0.7
@export var angle_weight: float = 0.3
