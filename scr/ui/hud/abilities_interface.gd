# BUG Need to heavily improve this garbage
# TODO Make diagrams >:(
extends MarginContainer

var ability_uis: Dictionary = {}  # { module_instance : { icon, charge_label, cooldown_progress } }

@onready var abilities_container: GridContainer = %AbilitiesContainer


func _ready() -> void:
	assert(abilities_container != null, "abilities_container missing in " + self.name)
	for ability_slot: Control in abilities_container.get_children():
		assert(ability_slot is TextureRect, "Ability slot %s is not a TextureRect in %s" % [ability_slot.name, self.name])
		assert(
			ability_slot.get_node("CooldownProgress") is TextureProgressBar,
			"CooldownProgress missing in slot %s of %s" % [ability_slot.name, self.name],
		)
		assert(ability_slot.get_node("ChargeLabel") is Label, "ChargeLabel missing in slot %s of %s" % [ability_slot.name, self.name])
		assert(ability_slot.get_node("InputHint") is Label, "InputHint missing in slot %s of %s" % [ability_slot.name, self.name])

	GameEvents.player_spawned.connect(_on_player_spawned)

	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYERS)
	if not players.is_empty() and players[0] is CharacterBody3D:
		_on_player_spawned(players[0] as CharacterBody3D)


func _on_player_spawned(player: CharacterBody3D) -> void:
	if not player.is_node_ready():
		await player.ready

	var skills_controller: SkillsController = player.get("skills_controller")
	if not skills_controller or not skills_controller is SkillsController:
		return

	if not skills_controller.is_node_ready():
		await skills_controller.ready

	# Await an extra frame in case the controller delays its initialization slightly
	if skills_controller.modules.is_empty():
		await get_tree().process_frame

	if skills_controller.modules.is_empty():
		return

	# Hide all existing UI slots to start
	for child: Control in abilities_container.get_children():
		if child is Control:
			child.visible = false
	ability_uis.clear()

	# Bind UI for each module dynamically
	var slots: Array[Node] = abilities_container.get_children()
	var slot_index: int = 0

	var player_skills: PlayerSkills = player.get("skills")

	for module: PlayerSkillModule in skills_controller.modules:
		if player_skills and not module.is_unlocked(player_skills):
			continue

		if slot_index >= slots.size():
			break

		var ability_icon: TextureRect = slots[slot_index] as TextureRect
		if not ability_icon:
			continue

		ability_icon.visible = true
		ability_icon.texture = module.get_icon()

		var input_hint: Label = ability_icon.get_node("InputHint") as Label
		input_hint.text = _get_input_hint(module)

		var charge_label: Label = ability_icon.get_node("ChargeLabel") as Label
		charge_label.visible = false

		var cooldown_progress: TextureProgressBar = ability_icon.get_node("CooldownProgress") as TextureProgressBar

		ability_uis[module] = {"icon": ability_icon, "charge_label": charge_label, "cooldown_progress": cooldown_progress}

		assert(ability_uis[module]["icon"] != null, "Icon missing for module in " + self.name)
		assert(cooldown_progress != null or not _module_uses_cooldown(module), "Cooldown Progress missing in slot mapped for module in " + self.name)

		_connect_module_signals(module, ability_icon)
		slot_index += 1


func _module_uses_cooldown(module: PlayerSkillModule) -> bool:
	return module is PlayerGroundDashSkill or module is PlayerAirDashSkill or module is PlayerTeleportSkill


func _get_action_key(action_name: String, fallback: String) -> String:
	if InputMap.has_action(action_name):
		var events: Array[InputEvent] = InputMap.action_get_events(action_name)
		for event: InputEvent in events:
			if event is InputEventKey:
				return OS.get_keycode_string(event.physical_keycode)
			if event is InputEventMouseButton:
				return "M" + str(event.button_index)
	return fallback


func _get_input_hint(module: PlayerSkillModule) -> String:
	# Check module overrides first
	var custom_hint: String = module.get_custom_input_hint()
	if custom_hint != "":
		return custom_hint

	var mapped_action: String = module.get_action_name()
	if mapped_action != "":
		return _get_action_key(mapped_action, mapped_action).to_upper()

	return "?"


func _connect_module_signals(module: PlayerSkillModule, icon: Control) -> void:
	if module is PlayerGroundDashSkill:
		module.ground_dash_cooldown_started.connect(func(duration: float) -> void: _start_cooldown(icon, duration))
		module.ground_dash_cooldown_finished.connect(func() -> void: _finish_cooldown(icon))

	elif module is PlayerAirDashSkill:
		module.air_dash_cooldown_started.connect(func(duration: float) -> void: _start_cooldown(icon, duration))
		module.air_dash_cooldown_finished.connect(func() -> void: _finish_cooldown(icon))

	elif module is PlayerTeleportSkill:
		module.teleport_charges_updated.connect(func(charges: int) -> void: _update_charge_display(icon, charges))
		if "_teleport_charges" in module:
			_update_charge_display(icon, module.get("_teleport_charges"))

	elif module is PlayerFeatherFallSkill:
		module.feather_fall_toggled.connect(func(toggled: bool) -> void: _update_toggle_display(icon, toggled))
		if "_is_toggled" in module:
			_update_toggle_display(icon, module.get("_is_toggled"))

	elif module is PlayerMultiJumpSkill:
		module.multi_jump_executed.connect(func() -> void: _play_pulse_animation(icon))


func _start_cooldown(icon: Control, duration: float) -> void:
	var cooldown_progress: TextureProgressBar = icon.get_node("CooldownProgress") as TextureProgressBar
	assert(cooldown_progress != null)

	var tween: Tween = create_tween()
	cooldown_progress.value = 100.0
	tween.tween_property(cooldown_progress, "value", 0.0, duration)

	icon.modulate = Color(0.4, 0.4, 0.4, 0.8)

	_show_input_blocked_feedback(icon)


func _finish_cooldown(icon: Control) -> void:
	icon.modulate = Color(2.0, 2.0, 2.0, 1.0)  # Bright bloom

	var mod_tween: Tween = create_tween()
	mod_tween.tween_property(icon, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if icon.has_meta("pulse_tween"):
		var old_tween: Tween = icon.get_meta("pulse_tween")
		if is_instance_valid(old_tween):
			old_tween.kill()

	var tween: Tween = create_tween()
	tween.tween_property(icon, "scale", Vector2(1.25, 1.25), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	icon.set_meta("pulse_tween", tween)

	var cooldown_progress: TextureProgressBar = icon.get_node("CooldownProgress") as TextureProgressBar
	assert(cooldown_progress != null)
	cooldown_progress.value = 0.0


func _update_charge_display(icon: Control, charges: int) -> void:
	var charge_label: Label = icon.get_node("ChargeLabel") as Label
	assert(charge_label != null)

	charge_label.text = str(charges)
	charge_label.visible = charges > 0

	if charges == 0:
		icon.modulate = Color(0.3, 0.3, 0.3, 0.6)
	elif charges == 1:
		icon.modulate = Color(0.7, 0.7, 1.0, 1.0)
	else:
		icon.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _update_toggle_display(icon: Control, toggled: bool) -> void:
	if icon.has_meta("pulse_tween"):
		var old_tween: Tween = icon.get_meta("pulse_tween")
		if is_instance_valid(old_tween):
			old_tween.kill()

	if toggled:
		icon.modulate = Color(0.5, 1.0, 0.5, 1.0)
		var tween: Tween = create_tween()
		tween.set_loops(0)
		tween.tween_property(icon, "scale", Vector2(1.05, 1.05), 0.3)
		tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.3)
		icon.set_meta("pulse_tween", tween)
	else:
		icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
		var tween: Tween = create_tween()
		tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.15)
		icon.set_meta("pulse_tween", tween)


func _play_pulse_animation(icon: Control) -> void:
	if icon.has_meta("pulse_tween"):
		var old_tween: Tween = icon.get_meta("pulse_tween")
		if is_instance_valid(old_tween):
			old_tween.kill()

	var tween: Tween = create_tween()
	tween.tween_property(icon, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.08)
	icon.set_meta("pulse_tween", tween)


func _show_input_blocked_feedback(icon: Control) -> void:
	var original_modulate: Color = icon.modulate
	icon.modulate = Color(1.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(icon):
		icon.modulate = original_modulate
