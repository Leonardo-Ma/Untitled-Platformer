@icon("res://icons/16x16/script.png")
class_name StatModifier
extends Resource

# gdlint: disable=ModifierType
enum ModifierType {
	ADD,  # Flat addition (e.g., +10 Attack)
	MULTIPLY,  # Percentage multiplier applied AFTER flat additions (e.g., 1.5 for +50%)
	POST_ADD,  # Final flat additions applied after multipliers (e.g., guaranteed +5 min damage)
}

@export var target_stat: StatTypes.Type = StatTypes.Type.STRENGTH
@export var type: ModifierType = ModifierType.ADD
@export var value: float = 0.0
