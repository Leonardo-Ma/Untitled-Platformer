# https://youtu.be/V79YabQZC1s?si=HGUpgvU7RAhYOMrY&t=792
extends PanelContainer

const SLOT: Resource = preload("uid://ccynrt0q7u4dm")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data: InventoryData) -> void:
	for child: Control in item_grid.get_children():
		child.queue_free()

	for item_group_data: ItemGroupData in inventory_data.item_group_datas:
		var slot: Control = SLOT.instantiate()
		item_grid.add_child(slot)

		slot.slot_clicked.connect(inventory_data.on_slot_clicked)

		if item_group_data:
			slot.set_item_group_data(item_group_data)
