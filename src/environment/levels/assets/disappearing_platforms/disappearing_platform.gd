extends StaticBody3D

@export var fade_in_seconds: int = 2
@export var fade_out_seconds: int = 3

var _is_cycle_running: bool = false
var _mesh_parts: Array[MeshInstance3D] = []
var _base_scale: Vector3 = Vector3.ONE
var _part_base_scales: Dictionary[MeshInstance3D, Vector3] = {}
var _part_base_positions: Dictionary[MeshInstance3D, Vector3] = {}

@onready var surface: Area3D = $Surface
@onready var body_collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_base_scale = scale
	_mesh_parts = _collect_mesh_parts()
	for mesh_part: MeshInstance3D in _mesh_parts:
		_part_base_scales[mesh_part] = mesh_part.scale
		_part_base_positions[mesh_part] = mesh_part.position
	surface.body_entered.connect(_on_character_step)


func _on_character_step(body: Node3D) -> void:
	if body is not PlayerEntity or _is_cycle_running:
		return
	_is_cycle_running = true
	surface.set_deferred("monitoring", false)
	await get_tree().create_timer(fade_out_seconds).timeout
	surface.set_deferred("monitoring", true)
	await _play_vanish_effect()
	disable()
	await get_tree().create_timer(fade_in_seconds).timeout
	await _play_appear_effect()
	enable()
	_is_cycle_running = false


func enable() -> void:
	scale = _base_scale
	for mesh_part: MeshInstance3D in _mesh_parts:
		mesh_part.scale = _part_base_scales[mesh_part]
		mesh_part.position = _part_base_positions[mesh_part]
	visible = true
	body_collision.disabled = false


func disable() -> void:
	visible = false
	body_collision.disabled = true


func _play_vanish_effect() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", _base_scale * 0.92, 0.25)
	for mesh_part: MeshInstance3D in _mesh_parts:
		var part_base_scale: Vector3 = _part_base_scales[mesh_part]
		var part_base_position: Vector3 = _part_base_positions[mesh_part]
		tween.tween_property(mesh_part, "scale", part_base_scale * 0.08, 0.3)
		tween.tween_property(mesh_part, "position", part_base_position + Vector3(0.0, -0.7, 0.0), 0.3)
	await tween.finished


func _play_appear_effect() -> void:
	visible = true
	for mesh_part: MeshInstance3D in _mesh_parts:
		var part_base_scale: Vector3 = _part_base_scales[mesh_part]
		var part_base_position: Vector3 = _part_base_positions[mesh_part]
		mesh_part.scale = part_base_scale * 0.08
		mesh_part.position = part_base_position + Vector3(0.0, -0.7, 0.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", _base_scale, 0.25)
	for mesh_part: MeshInstance3D in _mesh_parts:
		var part_base_scale: Vector3 = _part_base_scales[mesh_part]
		var part_base_position: Vector3 = _part_base_positions[mesh_part]
		tween.tween_property(mesh_part, "scale", part_base_scale, 0.28)
		tween.tween_property(mesh_part, "position", part_base_position, 0.28)
	await tween.finished


func _collect_mesh_parts() -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child: Node in find_children("*", "MeshInstance3D", true, false):
		result.append(child as MeshInstance3D)
	return result
