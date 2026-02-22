extends Label3D

@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var goap_controller: RedMageMemory = $"../GoapController"
@onready var labelText : String

func _process(_delta: float) -> void:
	var is_damaged : String = "Not damaged"
	
	if animation_tree.get("parameters/is_damaged/active"):
		is_damaged = "damaged"
	labelText = is_damaged + " \n "
	labelText += str(owner.health.health) + "\n"
	
	labelText += "GOAP:\n"
	#for values in goap_controller.get_blackboard().values():
		#labelText += str(values) + "\n"
		
	labelText += "Current goal: "
	if owner.agent._current_goal: 
		labelText += str(owner.agent._current_goal.name) + "\n"
		
	if owner.agent._current_goal:
		labelText += "Current goal: " + owner.agent._current_goal.get_custom_class_name()
	
	self.text = labelText 
