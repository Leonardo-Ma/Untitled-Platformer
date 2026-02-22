extends Resource
## @tutorial(Godot 4 - RPG Inventory System From Scratch DevLogLogan): [url]https://youtu.be/V79YabQZC1s?si=050Ix8SRjkIwotWi&t=170[/url]
## [img]res://documentation/inventory/inventory_component.png[/img]
class_name ItemGroupData

@export var item_data: ItemData
# TODO Check this max hardcoded amount is valid for debugging purposes, should be max item_data.stack_size
@export_range(1, 999) var quantity: int = 1 : set = set_quantity

func can_merge_with(other_item_group_data: ItemGroupData) -> bool:
	return item_data == other_item_group_data.item_data \
		and item_data.is_stackable() \
		and quantity < item_data.stack_size

func can_fully_merge_with(other_item_group_data: ItemGroupData) -> bool:
	return item_data == other_item_group_data.item_data \
		and item_data.is_stackable() 
		
func can_stack_with(other_item_group_data: ItemGroupData) -> bool:
	return item_data == other_item_group_data.item_data \
		and quantity + other_item_group_data.quantity <= item_data.stack_size

func fully_merge_with(other_item_group_data: ItemGroupData) -> void:
	quantity += other_item_group_data.quantity
	
func create_single_item_group_data() -> ItemGroupData:
	var new_item_group_data := duplicate()
	new_item_group_data.quantity = 1
	quantity -= 1
	return new_item_group_data

func set_quantity(value : int) -> void:
	quantity = value
	if quantity > 1 && not item_data.is_stackable():
		quantity = 1
		push_error("%s not stackable, setting quantity to 1 " % item_data.name)
