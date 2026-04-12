class_name PlayerMultiJumpSkill extends PlayerSkillModule

signal multi_jump_executed

var _jumps_made: int = 0


func get_icon() -> Texture2D:
	return preload("uid://01223baevlix")


func get_action_name() -> String:
	return "jump"


func is_unlocked(skills: PlayerSkills) -> bool:
	return skills.can_double_jump or skills.can_triple_jump


func on_landed() -> void:
	_jumps_made = 0


func handle_input(body: CharacterBody3D, skills: PlayerSkills) -> void:
	if skills_controller.is_sliding or not skills_controller.movement_controller.movement_enabled:
		return

	if Input.is_action_just_pressed("jump") and not body.is_on_floor() and skills_controller.movement_controller.coyote_timer <= 0.0:
		var max_jumps: int = 1
		if skills.can_double_jump:
			max_jumps = 2
		if skills.can_triple_jump:
			max_jumps = 3

		if _jumps_made < max_jumps - 1:
			_jumps_made += 1
			body.velocity.y = skills.extra_jump_velocity
			_apply_jump_effects(skills)


func _apply_jump_effects(skills: PlayerSkills) -> void:
	multi_jump_executed.emit()
	if skills_controller.camera:
		var tween: Tween = skills_controller.create_tween()
		var target_fov: float = skills_controller.base_fov + skills.jump_fov_increase
		var duration: float = skills.jump_fov_duration

		# Smoothly scale up FOV and then smoothly scale it back down
		tween.tween_property(skills_controller.camera, "fov", target_fov, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(skills_controller.camera, "fov", skills_controller.base_fov, duration * 0.7).set_trans(Tween.TRANS_SINE).set_ease(
			Tween.EASE_IN_OUT
		)

	# TODO Make these in editor instead of code
	var particles: GPUParticles3D = GPUParticles3D.new()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.emission_enabled = true
	material.emission = Color(1.0, 1.0, 1.0)
	material.albedo_color = Color(3.0, 3.0, 3.0)

	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = Vector3(0.1, 0.1, 0.1)
	box_mesh.material = material

	particles.draw_pass_1 = box_mesh
	particles.amount = 8
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.5

	var p_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	p_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	p_mat.emission_sphere_radius = 0.5
	p_mat.direction = Vector3(0, -1, 0)
	p_mat.spread = 45.0
	p_mat.initial_velocity_min = 2.0
	p_mat.initial_velocity_max = 5.0
	particles.process_material = p_mat

	skills_controller.entity.add_child(particles)
	particles.global_position = skills_controller.entity.global_position + Vector3(0, 0.5, 0)
	particles.emitting = true

	var timer: SceneTreeTimer = skills_controller.entity.get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
