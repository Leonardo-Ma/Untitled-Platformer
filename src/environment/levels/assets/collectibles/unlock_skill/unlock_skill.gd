extends Collectible


func _child_ready() -> void:
	collect_sounds = [
		preload("uid://cag33c6eom3kf"),  # harpsichord_chime_positive.wav
	]
	var skill_data: SkillCollectible = data as SkillCollectible
	assert(skill_data != null and skill_data.definition != null, "UnlockSkill: SkillCollectible with a valid definition required on " + name)
# TODO Add a festive animation effect when picking up this (tween?)
