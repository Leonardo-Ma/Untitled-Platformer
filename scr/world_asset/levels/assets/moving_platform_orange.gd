extends Path3D

@onready var path_follow_3d: PathFollow3D = %PathFollow3D


func _physics_process(delta: float) -> void:
	path_follow_3d.progress += 1.5 * delta
