extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)

@export var item_group_datas: Array[ItemGroupData]


func grabbed_item_group_data(index: int) -> ItemGroupData:
	var item_group_data: ItemGroupData = item_group_datas[index]

	if item_group_data:
		item_group_datas[index] = null
		inventory_updated.emit(self)
		return item_group_data
	else:
		return null


func drop_item_group_data(grabbed_item_group_data: ItemGroupData, index: int) -> ItemGroupData:
	var item_group_data: ItemGroupData = item_group_datas[index]
	var return_item_group_data: ItemGroupData

	if item_group_data and item_group_data.can_fully_merge_with(grabbed_item_group_data):
		if item_group_data and item_group_data.can_stack_with(grabbed_item_group_data):
			item_group_data.fully_merge_with(grabbed_item_group_data)
		else:
			var quantity_difference: int = (
				item_group_data.item_data.stack_size - item_group_data.quantity
			)
			item_group_data.quantity += quantity_difference
			grabbed_item_group_data.quantity -= quantity_difference
			return_item_group_data = grabbed_item_group_data
	else:
		item_group_datas[index] = grabbed_item_group_data
		return_item_group_data = item_group_data

	inventory_updated.emit(self)
	return return_item_group_data


func drop_single_item_group_data(
	grabbed_item_group_data: ItemGroupData, index: int
) -> ItemGroupData:
	var item_group_data: ItemGroupData = item_group_datas[index]

	if not item_group_data:
		item_group_datas[index] = grabbed_item_group_data.create_single_item_group_data()
	elif item_group_data.can_merge_with(grabbed_item_group_data):
		item_group_data.fully_merge_with(grabbed_item_group_data.create_single_item_group_data())

	inventory_updated.emit(self)

	if grabbed_item_group_data.quantity > 0:
		return grabbed_item_group_data
	else:
		return null


func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)
