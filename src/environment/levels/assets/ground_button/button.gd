extends Area3D

signal button_toggled_on
signal button_toggled_off


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node3D) -> void:
	if _body is PlayerEntity:
		button_toggled_on.emit()
		set_deferred("monitoring", false)
		await get_tree().create_timer(4).timeout
		set_deferred("monitoring", true)
		button_toggled_off.emit()
