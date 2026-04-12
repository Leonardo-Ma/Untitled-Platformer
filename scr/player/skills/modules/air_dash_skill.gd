class_name PlayerAirDashSkill
extends PlayerSkillModule

signal air_dash_cooldown_started(duration: float)
signal air_dash_cooldown_finished

const DOUBLE_TAP_THRESHOLD: float = 0.3

var _air_dash_used: bool = false
var _dash_timer: float = 0.0
var _dash_cooldown: float = 0.0
var _dash_direction: Vector3 = Vector3.ZERO
var _last_pressed_action: String = ""
var _last_pressed_time: float = 0.0


func get_icon() -> Texture2D:
	return preload("uid://cn2f0on7ha6yv")


func get_custom_input_hint() -> String:
	return "Air Dash (x2)"


func is_unlocked(skills: PlayerSkills) -> bool:
	return skills.can_air_dash


func on_landed() -> void:
	_air_dash_used = false


func process_timers(_skills: PlayerSkills, delta: float) -> void:
	if _dash_timer > 0.0:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			skills_controller.is_sliding = false

	if _dash_cooldown > 0.0:
		_dash_cooldown -= delta
		if _dash_cooldown <= 0.0:
			air_dash_cooldown_finished.emit()


func handle_input(body: CharacterBody3D, skills: PlayerSkills) -> void:
	if skills_controller.is_sliding or not skills_controller.movement_controller.movement_enabled:
		return

	if body.is_on_floor() or not skills.can_air_dash or _air_dash_used or _dash_cooldown > 0.0:
		return

	var actions: Array[String] = ["forward", "backward", "left", "right"]
	var current_time: float = Time.get_ticks_msec() / 1000.0

	for action: String in actions:
		if Input.is_action_just_pressed(action):
			if _last_pressed_action == action and (current_time - _last_pressed_time) < DOUBLE_TAP_THRESHOLD:
				_start_air_dash(body, skills, action)
				_last_pressed_action = ""
				break
			else:
				_last_pressed_action = action
				_last_pressed_time = current_time


func apply_logic(body: CharacterBody3D, _skills: PlayerSkills) -> void:
	if skills_controller.is_sliding and _dash_timer > 0.0:
		body.velocity.x = _dash_direction.x
		body.velocity.z = _dash_direction.z
		body.velocity.y = 0.0  # Ignore gravity completely


func _start_air_dash(body: CharacterBody3D, skills: PlayerSkills, action_dir: String) -> void:
	_air_dash_used = true
	skills_controller.is_sliding = true
	_dash_timer = skills.air_dash_duration
	_dash_cooldown = skills.air_dash_cooldown
	air_dash_cooldown_started.emit(_dash_cooldown)

	var input_vec: Vector2 = Vector2.ZERO
	match action_dir:
		"forward":
			input_vec = Vector2(0, -1)
		"backward":
			input_vec = Vector2(0, 1)
		"left":
			input_vec = Vector2(-1, 0)
		"right":
			input_vec = Vector2(1, 0)

	var forward: Vector3 = (body.transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()

	_dash_direction = forward * skills_controller.movement_controller.current_speed * skills.air_dash_velocity_multiplier
	skills_controller.movement_controller.disable_movement(skills.air_dash_duration)
