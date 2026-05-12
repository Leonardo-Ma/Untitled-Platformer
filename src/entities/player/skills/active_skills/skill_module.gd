## Abstract base class for individual player skill modules.
## Handled and processed centrally by the SkillsController.
@abstract class_name ActivePlayerSkill
extends RefCounted

## The central SkillsController node handling all state orchestration.
var skills_controller: SkillsController


func _init(c: SkillsController) -> void:
	skills_controller = c


## UI Configuration: Returns the display icon for this module
func get_icon() -> Texture2D:
	return preload("uid://biqb3l8idkgqj")


## UI Configuration: Returns the primary input action name mapped to this skill (e.g. "jump")
func get_action_name() -> String:
	return ""


## UI Configuration: Returns a custom input string overriding the action mapping (e.g. "Double W/A/S/D")
func get_custom_input_hint() -> String:
	return ""


## UI Configuration: Indicates if this skill is currently active/unlocked on the player
func is_unlocked(_skills: PlayerSkills) -> bool:
	return false


func on_landed() -> void:
	pass


## Called every frame to process cool-downs or active timers
func process_timers(_skills: PlayerSkills, _delta: float) -> void:
	pass


## Called every frame to run passive mechanics (gravity, )
func process_passive(_body: CharacterBody3D, _skills: PlayerSkills, _delta: float) -> void:
	pass


## Called every frame to process raw player input
func handle_input(_body: CharacterBody3D, _skills: PlayerSkills) -> void:
	pass


## Called every frame to forcibly modify the player physics velocity after inputs
func apply_logic(_body: CharacterBody3D, _skills: PlayerSkills) -> void:
	pass
