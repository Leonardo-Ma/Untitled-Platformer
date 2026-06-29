## Uses GodotSteam achievement API
extends Node

## Keys here must match API names in Steamworks Partner dashboard
const _API_NAMES: Dictionary = {
	&"first_run": "ACH_FIRST_RUN",
	&"score_100": "ACH_SCORE_100",
	&"score_500": "ACH_SCORE_500",
	&"score_2000": "ACH_SCORE_2000",
	&"score_5000": "ACH_SCORE_5000",
	&"score_10000": "ACH_SCORE_10000",
	&"all_skills": "ACH_ALL_SKILLS",
}

# TODO Should not be hardcoded
const _ALL_SKILL_IDS: Array[StringName] = [&"dash", &"double_jump", &"feather_fall"]


func _ready() -> void:
	GameEvents.score_updated.connect(_on_score_updated)
	GameEvents.player_spawned.connect(_on_player_spawned)
	GameEvents.status_buff_collected.connect(func(_e: StatusEffect, _i: Texture2D) -> void: _check_skill_completion())


func unlock(key: StringName) -> void:
	if not Steam.isSteamRunning():
		return
	var api_name: String = _API_NAMES.get(key, "")
	assert(api_name != "", "Unknown achievement key: " + str(key) + " in " + name)
	Steam.setAchievement(api_name)
	Steam.storeStats()


func _on_player_spawned(_player: Node) -> void:
	unlock(&"first_run")


func _on_score_updated(score: int) -> void:
	if score >= 100:
		unlock(&"score_100")
	if score >= 500:
		unlock(&"score_500")
	if score >= 2000:
		unlock(&"score_2000")
	if score >= 5000:
		unlock(&"score_5000")
	if score >= 10000:
		unlock(&"score_10000")


func _check_skill_completion() -> void:
	var player: PlayerEntity = get_tree().get_first_node_in_group(Groups.PLAYERS) as PlayerEntity
	if player == null:
		return
	var ids: Array[StringName] = player.skills_controller.get_unlocked_ids()
	if _ALL_SKILL_IDS.all(func(id: StringName) -> bool: return ids.has(id)):
		unlock(&"all_skills")
