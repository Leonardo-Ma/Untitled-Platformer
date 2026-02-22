## [img]res://documentation/inventory/inventory_component.png[/img]
extends Control

var grabbed_item_group_data: ItemGroupData
var external_inventory_owner: Node

@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot
@onready var external_inventory: PanelContainer = $ExternalInventory

func _physics_process(_delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)

func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)

func set_external_inventory(_external_inventory_owner: Node) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data: InventoryData = external_inventory_owner.inventory_data

	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)

	external_inventory.show()

func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data: InventoryData = external_inventory_owner.inventory_data

		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		print(external_inventory, " ", external_inventory_owner)
		external_inventory.clear_inventory_data(inventory_data)

		external_inventory.hide()
		external_inventory_owner = null

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	match [grabbed_item_group_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_item_group_data = inventory_data.grabbed_item_group_data(index)
		[_, MOUSE_BUTTON_LEFT]: # If we have something
			grabbed_item_group_data = inventory_data.drop_item_group_data(grabbed_item_group_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			pass # Use item
		[_, MOUSE_BUTTON_RIGHT]: # If we have something
			grabbed_item_group_data = inventory_data.drop_single_item_group_data(grabbed_item_group_data, index)

	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_item_group_data:
		grabbed_slot.show()
		grabbed_slot.set_item_group_data(grabbed_item_group_data)
	else:
		grabbed_slot.hide()
