## Base data container for collectibles. Use specific subclasses like CounterCollectibleData, StatusCollectibleData, or HealthCollectibleData.
@abstract class_name CollectibleData
extends Resource

@export_category("General")
@export var identifier: StringName = &"collectible_name"
@export var icon: Texture2D

## To override
@abstract func apply_effect(_player: PlayerEntity) -> void
