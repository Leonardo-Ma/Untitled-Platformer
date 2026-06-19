extends Collectible


func _child_ready() -> void:
	collect_sounds = [
		preload("uid://cag33c6eom3kf"),  # harpsichord_chime_positive.wav
	]
	assert(self.data.definition, "Skill not defined by + " + owner.name)

# TODO Add a festive animation effect when picking up this (tween?)
