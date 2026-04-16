extends Button

const SHUT_DOWN_SOUND: AudioStream = preload("uid://yvujl2l3onjt")  # synth_shut_down.wav


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	SoundManager.play_sound(SHUT_DOWN_SOUND, SoundManager.SoundCategory.UI)
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()
