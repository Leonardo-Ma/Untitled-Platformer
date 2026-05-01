extends Control

const POP_SOUNDS: Array[AudioStream] = [
	preload("uid://bmmjv51rywjed"),  # pop_1.wav
	preload("uid://bs5ws2by636gj"),  # pop_2.wav
	preload("uid://51tu1dqta8wv"),  # pop_3.wav
	preload("uid://dyr0xhho2e7pv"),  # pop_4.wav
]


func _ready() -> void:
	var buttons: Array = find_children("*", "Button", true, false)

	for button: Button in buttons:
		button.mouse_entered.connect(_on_hover.bind(button))
		button.mouse_exited.connect(_on_exit.bind(button))
		button.pressed.connect(_on_pressed.bind(button))


func _on_pressed(_button: Button) -> void:
	(
		SoundManager
		. play_sound(
			POP_SOUNDS.pick_random(),
			SoundManager.SoundCategory.UI,
		)
	)


func _on_hover(button: Button) -> void:
	(
		SoundManager
		. play_sound(
			preload("uid://cxb6ockccyuf0"),  # switch1.wav
			SoundManager.SoundCategory.UI,
		)
	)
	button.pivot_offset = button.size / 2.0
	var tween: Tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(button, "modulate", Color.DARK_ORANGE.darkened(0.2), 0.1)


func _on_exit(button: Button) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(button, "modulate", Color.WHITE, 0.1)


func _on_new_game_pressed() -> void:
	pass
