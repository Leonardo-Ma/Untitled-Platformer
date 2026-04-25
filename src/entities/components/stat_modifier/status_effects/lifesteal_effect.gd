class_name LifestealEffect
extends StatusEffect

@export_range(0.0, 1.0) var heal_percentage: float = 0.2  ## 20% of damage dealt is returned as health


func on_event(target: Node, event_name: StringName, data: Dictionary) -> void:
	# We listen for an event called "on_damage_dealt"
	if event_name == &"on_damage_dealt":
		var damage_amount: float = data.get("damage", 0.0)
		if damage_amount <= 0.0:
			return

		var heal_amount: float = damage_amount * heal_percentage

		var target_health = _get_health_resource(target)
		if target_health != null:
			target_health.health += int(heal_amount)


func _get_health_resource(target: Node) -> Resource:
	# Utility to find the Health resource on the target
	if "health" in target and target.health is Resource:  # Health is a Resource
		return target.health

	# TODO Add assert
	# If the target is a StatusManager, check its parent
	if target is StatusManager and "health" in target.get_parent():
		var parent = target.get_parent()
		if parent.health is Resource:
			return parent.health

	return null
