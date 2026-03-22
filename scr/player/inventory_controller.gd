# https://youtu.be/V79YabQZC1s?si=HGUpgvU7RAhYOMrY&t=792
@icon("res://icons/16x16/ui_inventory.png")
extends Node

var inventory_interface: Control


func _ready() -> void:
	# Give the tree a moment to set up in case the UI is instantiated later or below the player
	call_deferred("_setup_inventory")


func _setup_inventory() -> void:
	inventory_interface = get_tree().get_root().find_child("InventoryInterface", true, false) as Control

	if inventory_interface == null:
		push_error("InventoryInterface not found in the scene tree.")
		return

	get_parent().toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(get_parent().inventory_data)

	for node: Node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)


func toggle_inventory_interface(external_inventory_owner: Node = null) -> void:
	if not is_instance_valid(inventory_interface):
		return

	inventory_interface.visible = not inventory_interface.visible

	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()
