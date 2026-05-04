extends Collectible


func _ready() -> void:
	super._ready()
	collect_sounds = [
		preload("uid://dph7e3ucr86v7"),  # ambient_wind.wav
	]
