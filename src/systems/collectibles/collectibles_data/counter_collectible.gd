class_name CounterCollectible
extends CollectibleData

@export_category("Counter Mechanics")
@export var amount: int = 1


func apply_effect(_player: PlayerEntity) -> void:
	GameEvents.counter_collectible_collected.emit(identifier, amount, icon)
