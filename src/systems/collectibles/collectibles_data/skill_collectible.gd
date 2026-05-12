class_name SkillCollectible
extends CollectibleData

# TODO Refactor skills to avoid hardcode
@export_category("Skill")
@export_enum(
	"can_double_jump",
	"can_triple_jump",
	"can_ground_dash",
	"can_air_dash",
	"can_teleport_dash",
	"can_feather_fall",
)
var skill_to_unlock: String


func apply_effect(_player: PlayerEntity) -> void:
	_player.skills.set(skill_to_unlock, true)
	_player.skills.skill_unlocked.emit(skill_to_unlock)
	print(skill_to_unlock + " unlocked")
