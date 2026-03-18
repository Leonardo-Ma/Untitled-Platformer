extends StaticBody3D

signal toggle_inventory(external_inventory_owner: Node)
#@onready var chest_wood: Node3D = $Chest

@export var inventory_data: InventoryData

func player_interact() -> void:
	# TODO play open chest animation
	toggle_inventory.emit(self)
