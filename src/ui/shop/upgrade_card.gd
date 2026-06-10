## Single stat upgrade card
## Stat binding configured per-card by exports, and runtime upgrade is injected by the shop
extends PanelContainer

signal upgrade_requested(card: PanelContainer)

@export_category("Stat Binding")
@export var stat_name: String = "Stat name label"
@export var unit: String = "unit suffix"
## Amount added to the stat per upgrade
@export var step: float = 1.0
@export var cost: int = 0
## The resource property name to read/write on the injected target object
@export var stat_property: StringName = &""

## Injected at runtime by the shop after the player spawns
var target_object: Object

@onready var _stat_label: Label = %stat_label
@onready var _value_label: Label = %value_label
@onready var _preview_label: Label = %preview_label
@onready var _upgrade_btn: Button = %upgrade_btn


func _ready() -> void:
	_upgrade_btn.pressed.connect(_on_upgrade_button_pressed)
	_stat_label.text = stat_name
	_refresh_display()


## Injects the runtime resource that owns stat_property
func bind_target(object: Object) -> void:
	target_object = object
	_refresh_display()


func get_stat_value() -> float:
	if target_object and stat_property:
		return float(target_object.get(stat_property))
	return 0.0


func apply_upgrade(new_cost: int) -> void:
	if target_object and stat_property:
		target_object.set(stat_property, get_stat_value() + step)
	cost = new_cost
	_refresh_display()


func set_affordable(can_afford: bool) -> void:
	_upgrade_btn.disabled = not can_afford


func _refresh_display() -> void:
	var current: float = get_stat_value()
	_value_label.text = _format_value(current) + " " + unit
	_preview_label.text = _format_value(current) + " → " + _format_value(current + step)
	_upgrade_btn.text = str(cost) + "  Upgrade"


func _format_value(v: float) -> String:
	if v == int(v):
		return str(int(v))
	return "%.1f" % v


func _on_upgrade_button_pressed() -> void:
	upgrade_requested.emit(self)
