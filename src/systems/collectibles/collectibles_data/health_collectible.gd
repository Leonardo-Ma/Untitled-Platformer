class_name HealthCollectible
extends CollectibleData

@export_category("Health Recovery")
@export var health_recovered: int = 20


func apply_effect(player: PlayerEntity) -> void:
	var player_entity: PlayerEntity = player
	var health_resource: Health = player_entity.health

	health_resource.health += health_recovered
