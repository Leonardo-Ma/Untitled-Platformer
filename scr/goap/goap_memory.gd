## Interface class
## This is attached to goap controller node
## Controls the npc specific blackboard
@abstract class_name GoapMemory
extends Node

var _actor: Node = null
var _blackboard: Dictionary = {}

# To override
@abstract func init(actor: Node) -> void

# To override
@abstract func update_blackboard() -> void


func get_blackboard() -> Dictionary:
	return _blackboard
