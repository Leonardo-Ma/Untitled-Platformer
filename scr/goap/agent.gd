## This integrates the actor (NPC) with goap.
## In your implementation you could have this logic
## inside your NPC script.
##
## As good practice, I suggest leaving it isolated like
## this, so it makes re-use easy and it doesn't get tied
## to unrelated implementation details (movement, collisions, etc)
class_name GoapAgent
extends Node

const GOAL_SWITCH_DELAY: float = 0.1

var _goals: Array[GoapGoal]
var _current_goal: GoapGoal
var _current_plan: Array[GoapAction]
var _current_plan_step: int = 0

# Memory has actor and blackboard
var _goap_memory: GoapMemory

# Per-entity action planner
var _action_planner: GoapActionPlanner

var _goal_switch_cooldown: float = 0.0


# For ever frame, is current goal still highest priority?
# if not request the action planner a new plan for new highest priority
func _process(delta: float) -> void:
	_goap_memory.update_blackboard()
	_goal_switch_cooldown -= delta

	var goal: GoapGoal = _get_best_goal()

	# No valid goal found, skip planning
	if goal == null:
		return

	if _current_goal == null or goal != _current_goal or goal.priority() > _current_goal.priority():
		# Add global knowledge to this blackboard
		#for s in WorldState._state:
		#_blackboard[s] = WorldState._state[s]

		_current_goal = goal
		_current_plan = _action_planner.get_plan(_current_goal, _goap_memory.get_blackboard())
		_current_plan_step = 0
		_goal_switch_cooldown = GOAL_SWITCH_DELAY

		#print_debug("Changed goal to: " + str(_current_goal.get_custom_class_name()))
	else:
		_follow_plan(_current_plan, delta, _goap_memory.get_blackboard())


func init(actor: Node, goals: Array[GoapGoal], goap_memory: GoapMemory, actions: Array[GoapAction]) -> void:
	_goap_memory = goap_memory
	_goap_memory.init(actor)
	_goals = goals

	# Create per-entity action planner
	_action_planner = GoapActionPlanner.new()
	_action_planner.set_actions(actions)

	if actions.is_empty():
		push_error("GoapAgent: No actions provided for agent" + actor.name)
	if goals.is_empty():
		push_error("GoapAgent: No goals provided for agent" + actor.name)


## Returns the highest priority goal available
func _get_best_goal() -> GoapGoal:
	var highest_priority: GoapGoal = null

	for goal: GoapGoal in _goals:
		if goal.is_valid(_goap_memory.get_blackboard()) and (highest_priority == null or goal.priority() > highest_priority.priority()):
			highest_priority = goal

	return highest_priority


## Executes the plan
## "plan" is the current list of actions, and delta is the time since last loop
##
## Every action exposes a function called perform, which will return true when
## the job is complete, so the agent can jump to the next action in the list.
func _follow_plan(plan: Array[GoapAction], delta: float, _blackboard: Dictionary) -> void:
	if plan.size() == 0:
		return
	var is_step_complete: bool = plan[_current_plan_step].perform(_goap_memory._actor, delta, _blackboard)

	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1
