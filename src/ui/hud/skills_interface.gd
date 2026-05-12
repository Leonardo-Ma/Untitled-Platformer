## View controller, bridge between UI and skills' data
extends Control

@onready var skills_container: GridContainer = %SkillsContainer


func _ready() -> void:
	assert(skills_container != null, "skills_container missing in " + self.name)
	for skill_slot: Control in skills_container.get_children():
		assert(skill_slot is HUDSkillSlot, "Skill slot %s is not HUDSkillSlot in %s" % [skill_slot.name, self.name])

	GameEvents.player_spawned.connect(_on_player_spawned)

	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYERS)
	if not players.is_empty() and players[0] is CharacterBody3D:
		await _on_player_spawned(players[0] as CharacterBody3D)


func _on_player_spawned(player: CharacterBody3D) -> void:
	if not player.is_node_ready():
		await player.ready

	var skills_controller: SkillsController = player.get("skills_controller")
	if not skills_controller or not skills_controller is SkillsController:
		return

	if not skills_controller.is_node_ready():
		await skills_controller.ready

	# Await an extra frame in case controller delay initialization
	if skills_controller.active_skills.is_empty():
		await get_tree().process_frame

	if skills_controller.active_skills.is_empty():
		return

	for child: HUDSkillSlot in skills_container.get_children():
		child.cleanup()

	# Bind UI for each module dynamically
	var slots: Array[Node] = skills_container.get_children()
	var slot_index: int = 0

	var player_skills: PlayerSkills = player.get("skills")
	if player_skills and not player_skills.skill_unlocked.is_connected(_on_skill_unlocked.bind(player)):
		player_skills.skill_unlocked.connect(_on_skill_unlocked.bind(player))

	for active_skill: ActivePlayerSkill in skills_controller.active_skills:
		if player_skills and not active_skill.is_unlocked(player_skills):
			continue

		if slot_index >= slots.size():
			break

		var slot_node: HUDSkillSlot = slots[slot_index] as HUDSkillSlot
		if slot_node:
			slot_node.setup(active_skill)
			slot_index += 1


func _on_skill_unlocked(_skill_name: String, player: CharacterBody3D) -> void:
	await _on_player_spawned(player)
