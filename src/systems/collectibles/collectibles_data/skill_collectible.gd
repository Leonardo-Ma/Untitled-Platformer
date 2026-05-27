## Unlocks a player skill
class_name SkillCollectible
extends CollectibleData

@export_category("Skill")
@export var definition: SkillDefinition


func apply_effect(_player: PlayerEntity) -> void:
	assert(definition != null, "SkillCollectible: definition is null in " + identifier)
	_player.skills_controller.unlock(definition)
