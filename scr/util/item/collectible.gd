class_name Collectible
extends Area3D

const COLLECT_SOUNDS: Array[AudioStream] = [
	preload("uid://cwptti4mle3g0"),  # coin.wav
	preload("uid://dgdotgk6kwxi"),  # coin_3.wav
	preload("uid://luy8ck7csy0q"),  # coin_4.wav
	preload("uid://ckl5fl1a1sq0w"),  # coin_collect.wav
]

@export var data: CollectibleData


func _ready() -> void:
	assert(data != null, "Collectible data missing on " + self.name)
	body_entered.connect(_on_body_entered)
	_setup_float_animation()


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerEntity:
		SoundManager.play_sound(COLLECT_SOUNDS.pick_random(), SoundManager.SoundCategory.SFX, Vector2(global_position.x, global_position.z))
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
