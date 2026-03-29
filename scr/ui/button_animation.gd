extends Control


func _ready() -> void:
	var buttons: Array = find_children("*", "Button", true, false)

	for button: Button in buttons:
		button.mouse_entered.connect(_on_hover.bind(button))
		button.mouse_exited.connect(_on_exit.bind(button))


func _on_pressed(_button: Button) -> void:
	(
		SoundManager
		. play_sound(
			preload("res://scr/common/audio/ui/ui_sfx_set/switch1.wav"),
			SoundManager.SoundCategory.UI,
		)
	)


func _on_hover(button: Button) -> void:
	(
		SoundManager
		. play_sound(
			preload("res://scr/common/audio/ui/ui_sfx_set/rollover3.wav"),
			SoundManager.SoundCategory.UI,
		)
	)
	var tween: Tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_exit(button: Button) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_new_game_pressed() -> void:
	pass
