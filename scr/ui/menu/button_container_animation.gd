extends Control


func _ready():
	var buttons = find_children("*", "Button", true, false)

	for button in buttons:
		button.mouse_entered.connect(_on_hover.bind(button))
		button.mouse_exited.connect(_on_exit.bind(button))


func _on_hover(button):
	var tween = create_tween()
	(
		tween
		. tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)


func _on_exit(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_OUT
	)
