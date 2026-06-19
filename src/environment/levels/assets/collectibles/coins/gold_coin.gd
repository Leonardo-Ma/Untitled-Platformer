extends Collectible


func _child_ready() -> void:
	collect_sounds = [
		preload("uid://cwptti4mle3g0"),  # coin.wav
		preload("uid://dgdotgk6kwxi"),  # coin_3.wav
		preload("uid://luy8ck7csy0q"),  # coin_4.wav
		preload("uid://ckl5fl1a1sq0w"),  # coin_collect.wav
	]


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerEntity:
		SoundManager.play_sound(collect_sounds.pick_random(), SoundManager.SoundCategory.SFX, global_position)
		_apply_effect(body as PlayerEntity)
		queue_free()


# Overriding
func _apply_effect(_player: PlayerEntity) -> void:
	GameEvents.add_gold(data.amount)
