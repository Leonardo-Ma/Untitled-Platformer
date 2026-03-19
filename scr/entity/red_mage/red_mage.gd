class_name RedMage
extends AgressiveEntity

@export var ai_config: AIConfig

@onready var navigation_controller: Node = $NavigationController

@onready var agent: GoapAgent = GoapAgent.new()
@onready var goap_controller: RedMageMemory = $GoapController


func _ready() -> void:
	# BUG If this doesn't call parent's ready, it doesn't connect signals properly
	super._ready()
	assert(ai_config, "GOAP Not properly configured for " + self.name)
	var goals: Array[GoapGoal] = ai_config.create_goals()
	var actions: Array[GoapAction] = ai_config.create_actions()
	agent.init(self, goals, goap_controller, actions)

	add_child(agent)

	register_goap_agent(agent)
	# Disable navigation as goap will enable it when tracking
	navigation_controller.set_physics_process(false)
