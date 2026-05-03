class_name StatusCollectible
extends CollectibleData

@export_category("Buff Mechanics")
@export var status_effect: StatusEffect


func apply_effect(player: PlayerEntity) -> void:
	assert(status_effect != null, "Status buff collectible " + str(identifier) + " missing effect resource.")

	var entity: PlayerEntity = player as PlayerEntity
	var status_manager: StatusManager = entity.status_manager

	assert(status_manager.has_method("apply_status"), "StatusManager does not have apply_status method")
	status_manager.apply_status(status_effect)

	GameEvents.status_buff_collected.emit(status_effect, icon)
