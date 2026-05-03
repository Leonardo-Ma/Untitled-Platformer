@icon("res://icons/16x16/potion.png")
class_name StatusEffect
extends Resource

enum StackMode {
	NONE,  # Cannot stack, application is ignored if present
	STACK,  # Adds a new stack (up to max_stacks), keeps duration
	REPLACE,  # Refreshes duration to maximum
	ADD_DURATION,  # Extends existing time
}
enum StatusType { BUFF, DEBUFF, NEUTRAL }

@export var id: StringName = &""
@export var name: String = ""
@export var type: StatusType = StatusType.NEUTRAL
@export var tags: Array[StringName] = []

@export_group("Behavior")
## Duration in seconds. Use -1.0 for infinite durations (e.g., passives, equipment).
@export var duration: float = -1.0
@export var stack_mode: StackMode = StackMode.REPLACE
@export var max_stacks: int = 1
## Interval in seconds for the on_tick event to trigger (improves performance over per-frame updates).
@export var tick_interval: float = 1.0

#@export_group("Modifiers")
#@export var modifiers: Array[StatModifier] = []


## --- Virtual Hooks ---
func on_apply(_target: Node) -> void:
	pass


func on_remove(_target: Node) -> void:
	pass


func on_tick(_target: Node, _delta: float) -> void:
	pass


func on_event(_target: Node, _event_name: StringName, _data: Dictionary) -> void:
	pass


func is_infinite() -> bool:
	return duration < 0.0
