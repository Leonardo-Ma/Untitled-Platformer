extends TextureButton

const SHUT_DOWN_SOUND: AudioStream = preload("uid://yvujl2l3onjt")  # synth_shut_down.wav
const CLOSE_COLOR: Color = Color.RED


func _ready() -> void:
	modulate = CLOSE_COLOR
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	SoundManager.play_sound(SHUT_DOWN_SOUND, SoundManager.SoundCategory.UI)
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()
