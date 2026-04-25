## @tutorial(Godot 4 - RPG Inventory System From Scratch DevLogLogan): https://youtu.be/V79YabQZC1s?si=050Ix8SRjkIwotWi&t=170
## Stores items information
## [img]res://documentation/inventory/inventory_component.png[/img]
class_name ItemData
extends Resource

@export var name: String = ""
@export_multiline var description: String = ""
@export var stack_size: int = 1
@export var texture: AtlasTexture


func is_stackable() -> bool:
	return self.stack_size != 1
