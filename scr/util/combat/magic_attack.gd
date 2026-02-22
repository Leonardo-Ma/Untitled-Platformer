# TODO Create parent general magic attack class
## This is used to force the use of inherited animation player and to free after finished
class_name GroundedEarthAttack
extends Node
 
@export var attack: Attack
@onready var animation_tree: AnimationTree = $AnimationTree
# Took me 2 days to understand this :(
# https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html#statemachine-travel
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _ready() -> void:
	assert(animation_tree, "Animation tree not defined by " + self.name)
	assert(attack and attack.power > 0 and attack.type != null, "Attack property incorrect for " + self.name)

func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	if state_machine.get_current_node() == "End":
		queue_free()
