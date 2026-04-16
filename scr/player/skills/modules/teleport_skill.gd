class_name PlayerTeleportSkill
extends PlayerSkillModule

signal teleport_charges_updated(charges: int)

const DASH_SOUND: AudioStream = preload("uid://vo301kuo1mby")  # whoosh_2.wav

var _teleport_charges: int = 0
var _teleport_regen_timer: float = 0.0


func _init(c: SkillsController) -> void:
	super._init(c)
	if skills_controller.entity.skills:
		_teleport_charges = skills_controller.entity.skills.teleport_max_charges


func get_icon() -> Texture2D:
	return preload("uid://d4fuvtn4yvdfx")


func get_action_name() -> String:
	return "teleport"  # Adjust action name if different in map


func is_unlocked(skills: PlayerSkills) -> bool:
	return skills.can_teleport_dash


func process_timers(skills: PlayerSkills, delta: float) -> void:
	if skills.can_teleport_dash and _teleport_charges < skills.teleport_max_charges:
		_teleport_regen_timer += delta
		if _teleport_regen_timer >= skills.teleport_charge_regen_time:
			_teleport_charges += 1
			_teleport_regen_timer = 0.0
			teleport_charges_updated.emit(_teleport_charges)


func handle_input(body: CharacterBody3D, skills: PlayerSkills) -> void:
	if skills_controller.is_sliding or not skills_controller.movement_controller.movement_enabled:
		return

	if Input.is_action_just_pressed("teleport"):
		if skills.can_teleport_dash and _teleport_charges > 0:
			_perform_teleport_dash(body, skills)


func _perform_teleport_dash(body: CharacterBody3D, skills: PlayerSkills) -> void:
	_teleport_charges -= 1
	teleport_charges_updated.emit(_teleport_charges)

	SoundManager.play_sound(DASH_SOUND, SoundManager.SoundCategory.SFX)

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var forward: Vector3 = -body.transform.basis.z
	if input_dir.length() > 0:
		forward = (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# TODO Check performance for this code raycast
	var target_pos: Vector3 = body.global_position + forward * skills.teleport_distance

	# Lift the raycast slightly off the floor to avoid clipping the ground collision geometry
	var raycast_origin: Vector3 = body.global_position + Vector3(0, 0.5, 0)
	var raycast_target: Vector3 = target_pos + Vector3(0, 0.5, 0)

	var space_state: PhysicsDirectSpaceState3D = body.get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_target)

	# Exclude the player body from the raycast collision check
	query.exclude = [body.get_rid()]

	var result: Dictionary = space_state.intersect_ray(query)

	skills_controller.spawn_ghost_trail(2.0, Color(0.1, 0.1, 0.1, 0.7))  # Shadow

	if result.is_empty():
		body.global_position = target_pos
	else:
		# Teleport right in front of the wall instead of through it.
		# Apply X/Z from hit, but maintain raw Y to not snap upward
		var hit_grounded: Vector3 = result.position - Vector3(0, 0.5, 0)
		body.global_position = hit_grounded - (forward * 0.5)
