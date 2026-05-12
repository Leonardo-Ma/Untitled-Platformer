## View model for each skill UI, managed by skills interface
class_name HUDSkillSlot
extends VBoxContainer

var tracked_skill: ActivePlayerSkill
var _connections: Array[Dictionary] = []
var _tweens: Array[Tween] = []

@onready var skill_icon: TextureRect = %Skill
@onready var cooldown_progress: TextureProgressBar = %CooldownProgress
@onready var charge_label: Label = %ChargeLabel
@onready var input_hint: Label = %InputHint


func setup(skill: ActivePlayerSkill) -> void:
	cleanup()
	tracked_skill = skill
	show()
	skill_icon.texture = skill.get_icon()

	var custom_hint: String = skill.get_custom_input_hint()
	if custom_hint != "":
		input_hint.text = custom_hint
	else:
		var mapped_action: String = skill.get_action_name()
		if mapped_action != "":
			input_hint.text = _get_action_key(mapped_action, mapped_action).to_upper()
		else:
			assert(false, "Input hint missing for " + self.name)

	charge_label.hide()

	cooldown_progress.texture_progress = skill.get_icon()
	cooldown_progress.visible = _skill_uses_cooldown(skill)
	cooldown_progress.value = 0.0

	_connect_skill_signals()


func _skill_uses_cooldown(skill: ActivePlayerSkill) -> bool:
	return skill is PlayerGroundDashSkill or skill is PlayerAirDashSkill or skill is PlayerTeleportSkill or skill is PlayerMultiJumpSkill


func _get_action_key(action_name: String, fallback: String) -> String:
	if InputMap.has_action(action_name):
		var events: Array[InputEvent] = InputMap.action_get_events(action_name)
		for event: InputEvent in events:
			if event is InputEventKey:
				return OS.get_keycode_string(event.physical_keycode)
			if event is InputEventMouseButton:
				return "M" + str(event.button_index)
	return fallback


func _connect_and_track(sig: Signal, callable: Callable) -> void:
	sig.connect(callable)
	_connections.append({"signal": sig, "callable": callable})


func _connect_skill_signals() -> void:
	if tracked_skill is PlayerGroundDashSkill:
		var ground_dash: PlayerGroundDashSkill = tracked_skill as PlayerGroundDashSkill
		_connect_and_track(ground_dash.ground_dash_cooldown_started, _start_cooldown)
		_connect_and_track(ground_dash.ground_dash_cooldown_finished, _finish_cooldown)

	elif tracked_skill is PlayerAirDashSkill:
		var air_dash: PlayerAirDashSkill = tracked_skill as PlayerAirDashSkill
		_connect_and_track(air_dash.air_dash_cooldown_started, _start_cooldown)
		_connect_and_track(air_dash.air_dash_cooldown_finished, _finish_cooldown)

	elif tracked_skill is PlayerTeleportSkill:
		var teleport: PlayerTeleportSkill = tracked_skill as PlayerTeleportSkill
		_connect_and_track(teleport.teleport_charges_updated, _update_charge_display)
		_connect_and_track(teleport.teleport_cooldown_started, _start_cooldown_unblocked)
		if "_teleport_charges" in teleport:
			_update_charge_display(teleport.get("_teleport_charges"))

	elif tracked_skill is PlayerFeatherFallSkill:
		var feather: PlayerFeatherFallSkill = tracked_skill as PlayerFeatherFallSkill
		_connect_and_track(feather.feather_fall_toggled, _update_toggle_display)
		if "_is_toggled" in feather:
			_update_toggle_display(feather.get("_is_toggled"))

	elif tracked_skill is PlayerMultiJumpSkill:
		var multi_jump: PlayerMultiJumpSkill = tracked_skill as PlayerMultiJumpSkill
		_connect_and_track(multi_jump.multi_jump_executed, _play_pulse_animation)
		if multi_jump.has_signal("multi_jump_cooldown_started"):
			_connect_and_track(multi_jump.multi_jump_cooldown_started, _start_cooldown_unblocked)


func cleanup() -> void:
	for conn: Dictionary in _connections:
		if conn.signal.is_connected(conn.callable):
			conn.signal.disconnect(conn.callable)
	_connections.clear()

	tracked_skill = null

	for t: Tween in _tweens:
		if is_instance_valid(t):
			t.kill()
	_tweens.clear()

	if has_meta("pulse_tween"):
		var old_tween: Tween = get_meta("pulse_tween")
		if is_instance_valid(old_tween):
			old_tween.kill()
		remove_meta("pulse_tween")

	modulate = Color.WHITE
	scale = Vector2.ONE
	cooldown_progress.value = 0.0

	hide()


#region Skills slots animations


#region Cooldowns
func _create_tracked_tween() -> Tween:
	var t: Tween = create_tween()
	_tweens.append(t)
	t.finished.connect(func() -> void: _tweens.erase(t))
	return t


func _start_cooldown(duration: float) -> void:
	var tween: Tween = _create_tracked_tween()
	cooldown_progress.value = 100.0
	tween.tween_property(cooldown_progress, "value", 0.0, duration)
	modulate = Color(0.4, 0.4, 0.4, 0.8)
	_show_input_blocked_feedback()


func _start_cooldown_unblocked(duration: float) -> void:
	var tween: Tween = _create_tracked_tween()
	cooldown_progress.value = 100.0
	tween.tween_property(cooldown_progress, "value", 0.0, duration)


func _finish_cooldown() -> void:
	modulate = Color(2.0, 2.0, 2.0, 1.0)
	var mod_tween: Tween = _create_tracked_tween()
	mod_tween.tween_property(self, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_play_pulse_animation()
	cooldown_progress.value = 0.0


#endregion


func _update_charge_display(charges: int) -> void:
	charge_label.text = str(charges)
	charge_label.visible = charges > 0
	if charges == 0:
		modulate = Color(0.3, 0.3, 0.3, 0.6)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)


func _update_toggle_display(toggled: bool) -> void:
	if has_meta("pulse_tween"):
		var old_tween: Tween = get_meta("pulse_tween")
		if is_instance_valid(old_tween):
			old_tween.kill()

	if toggled:
		modulate = Color(0.5, 1.0, 0.5, 1.0)
		var tween: Tween = _create_tracked_tween()
		tween.set_loops(0)
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.3)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
		set_meta("pulse_tween", tween)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		var tween: Tween = _create_tracked_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
		set_meta("pulse_tween", tween)


func _play_pulse_animation() -> void:
	if has_meta("pulse_tween"):
		var old_tween: Tween = get_meta("pulse_tween")
		if is_instance_valid(old_tween):
			old_tween.kill()

	var tween: Tween = _create_tracked_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)
	set_meta("pulse_tween", tween)


func _show_input_blocked_feedback() -> void:
	var original_modulate: Color = modulate
	var tween: Tween = _create_tracked_tween()
	modulate = Color(1.0, 0.3, 0.3, 1.0)
	tween.tween_interval(0.1)
	tween.tween_callback(func() -> void: modulate = original_modulate)
#endregion
