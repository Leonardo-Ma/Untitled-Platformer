class_name StatusCollectibleData
extends CollectibleData

@export_category("Buff Mechanics")
@export var status_effect: StatusEffect


func apply_effect(player: PlayerEntity) -> void:
	assert(status_effect != null, "Status buff collectible " + str(identifier) + " missing effect resource.")

	var p_entity: PlayerEntity = player as PlayerEntity
	var status_manager: StatusManager = p_entity.status_manager

	if not status_manager.permanent_statuses.has(status_effect):
		status_manager.permanent_statuses.append(status_effect)

	if status_manager.has_method("apply_status"):
		status_manager.apply_status(status_effect)

	GameEvents.status_buff__collectible_collected.emit(status_effect, icon)
