class_name PlayerFeatherFallSkill
extends ActivePlayerSkill

signal feather_fall_toggled(toggled: bool)

var _is_toggled: bool = false
var _feather_particles: GPUParticles3D


func get_icon() -> Texture2D:
	return preload("uid://6sr7ekalyi34")


func get_action_name() -> String:
	return "feather_fall"


func is_unlocked(skills: PlayerSkills) -> bool:
	return skills.can_feather_fall


func on_landed() -> void:
	_is_toggled = false
	feather_fall_toggled.emit(false)
	_update_feather_particles(false)


func handle_input(body: CharacterBody3D, skills: PlayerSkills) -> void:
	if skills_controller.is_sliding or not skills_controller.movement_controller.movement_enabled:
		return

	if Input.is_action_just_pressed("feather_fall") and skills.can_feather_fall and not body.is_on_floor():
		_is_toggled = not _is_toggled
		feather_fall_toggled.emit(_is_toggled)
		_update_feather_particles(_is_toggled)


func process_passive(body: CharacterBody3D, skills: PlayerSkills, delta: float) -> void:
	if skills.can_feather_fall and _is_toggled and not body.is_on_floor() and body.velocity.y < 0.0:
		body.velocity.y += (skills_controller.movement_controller.gravity * delta) * (1.0 - skills.feather_fall_gravity_mult)

	if _is_toggled and _feather_particles:
		_feather_particles.global_position = body.global_position


func _update_feather_particles(active: bool) -> void:
	var vfx: VFXController = skills_controller.get_node_or_null("%VFXController") as VFXController
	vfx.toggle_feather_fall(active, skills_controller.entity)
