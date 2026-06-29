class_name Trampoline
extends StaticBody3D

@export_range(5.0, 30.0, 0.5, "suffix:m/s") var launch_velocity: float = 18.0
@export_range(0.05, 0.5, 0.01, "suffix:s") var squash_duration: float = 0.15

@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _surface: Area3D = $Surface


func _ready() -> void:
	_surface.body_entered.connect(_on_surface_entered)


func _on_surface_entered(body: Node3D) -> void:
	var char_body: CharacterBody3D = body as CharacterBody3D
	# Only bounce when falling onto the surface (velocity.y <= 0)
	if char_body == null or char_body.velocity.y > 1.0:
		return
	char_body.velocity.y = launch_velocity
	_play_squash()


func _play_squash() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_mesh, "scale", Vector3(1.35, 0.45, 1.35), squash_duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_mesh, "scale", Vector3(0.85, 1.3, 0.85), squash_duration * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_mesh, "scale", Vector3.ONE, squash_duration * 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
