class_name Collectible
extends Area3D

@export var data: CollectibleData


func _ready() -> void:
	assert(data != null, "Collectible data missing on " + self.name)
	body_entered.connect(_on_body_entered)
	_setup_float_animation()


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerEntity:
		_apply_effect(body as PlayerEntity)
		queue_free()


func _apply_effect(player: PlayerEntity) -> void:
	data.apply_effect(player)


func _setup_float_animation() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", 0.5, 1.0).as_relative()
	tween.tween_property(self, "position:y", -0.5, 1.0).as_relative()

	var rot_tween: Tween = create_tween()
	rot_tween.set_loops()
	rot_tween.tween_property(self, "rotation:y", TAU, 2.0).as_relative()
