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

	skills_controller.spawn_ghost_trail(0.6)  # Slightly longer duration for multi-jump

	var tween: Tween = skills_controller.create_tween()
	var target_fov: float = skills_controller.base_fov + skills.jump_fov_increase
	var duration: float = skills.jump_fov_duration

	# Smoothly scale up FOV and then smoothly scale it back down
	tween.tween_property(skills_controller.camera, "fov", target_fov, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(skills_controller.camera, "fov", skills_controller.base_fov, duration * 0.7).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_IN_OUT
	)
