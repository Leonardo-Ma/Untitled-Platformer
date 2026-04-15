## Handles player score and applies a visual animation
extends HBoxContainer

@onready var _score_label: Label = get_node_or_null("%ScoreLabel") as Label
@onready var _score_icon: TextureRect = get_node_or_null("%ScoreIcon") as TextureRect


func _ready() -> void:
	GameEvents.score_updated.connect(_on_score_updated)
	_update_ui(GameEvents.player_score)


func _on_score_updated(new_score: int, _added_points: int) -> void:
	_update_ui(new_score)
	_play_score_animation()


func _update_ui(score: int) -> void:
	if _score_label != null:
		_score_label.text = str(score)


func _play_score_animation() -> void:
	var tween: Tween = create_tween().set_parallel(true)

	if _score_label != null:
		_score_label.pivot_offset = _score_label.size / 2.0
		tween.tween_property(_score_label, "scale", Vector2(1.5, 1.5), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_score_label, "scale", Vector2.ONE, 0.2).set_delay(0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	if _score_icon != null:
		_score_icon.pivot_offset = _score_icon.size / 2.0
		tween.tween_property(_score_icon, "rotation", deg_to_rad(15), 0.05).set_trans(Tween.TRANS_SINE)
		tween.tween_property(_score_icon, "rotation", deg_to_rad(-15), 0.1).set_delay(0.05).set_trans(Tween.TRANS_SINE)
		tween.tween_property(_score_icon, "rotation", 0.0, 0.05).set_delay(0.15).set_trans(Tween.TRANS_SINE)
