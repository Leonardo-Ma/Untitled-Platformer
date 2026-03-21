# TODO only execute this if debug
# TODO Add print_orphan_nodes
# TODO Consider using match
# TODO Improve readability
extends Control


func _physics_process(_delta: float) -> void:
	var animation_tree: AnimationTree = Globals.player_animation_tree
	var is_damaged: String = "Not damaged"

	if animation_tree.get("parameters/is_damaged/active"):
		is_damaged = "damaged"
	var in_air: String = animation_tree.get("parameters/in_air_state/current_state")
	var jumping: String
	var running: String
	if animation_tree.get("parameters/is_jumping/active"):
		jumping = "Jumping"
	else:
		jumping = "Not jumping"
	if animation_tree.get("parameters/is_running/blend_amount") == 1:
		running = "Running"
	else:
		running = "Not running"
	Globals.player_state = (is_damaged + " \n " + in_air + " \n " + jumping + " \n " + running + " \n ")
