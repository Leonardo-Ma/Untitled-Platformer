extends Collectible


func _ready() -> void:
	super._ready()
	collect_sounds = [
		preload("uid://cag33c6eom3kf"),  # harpsichord_chime_positive.wav
	]

# TODO Add a festive animation effect when picking up this (tween?)
