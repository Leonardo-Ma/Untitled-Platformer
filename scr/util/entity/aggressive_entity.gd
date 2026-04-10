# TODO Consider extending a base (non-aggressive) entity?
# subclass sandbox https://www.youtube.com/watch?v=oIrvZDDWxhU&t=50s - GDQuest Five Must Have Code Patterns for Your Godot Game
## Generic abstract class for entities that take damage and attack
## Refer to subclass sandbox https://gameprogrammingpatterns.com/subclass-sandbox.html
@abstract class_name AggressiveEntity
extends CharacterBody3D

@warning_ignore("unused_signal")
signal melee_attacked

@export_category("Core")
@export var attack: Attack
@export var health: Health
@export var movement: Movement
@export var stats: EntityStats
@export var inventory_data: InventoryData

@export_category("Perception System")
@export var perception_config: PerceptionConfig
@export var target_groups: Array[String] = ["players"]
@export var debug_perception: bool = false

@export_category("AI System")
@export var ai_config: AIConfig

var goap_agent: GoapAgent = null

# TODO Consider @onready collision layer and mask (Maybe in a parent Entity class?)
@onready var hitbox: Hitbox = %Hitbox
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var status_manager: StatusManager = %StatusManager
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_controller: Node = %NavigationController
@onready var goap_controller: GoapMemory = %GoapController
@onready var perception_system: PerceptionSystem = %PerceptionSystem


## Inherited artifacts should override _entity_ready instead of this
func _ready() -> void:
	assert(hitbox, "Hitbox incorrect for " + self.name)
	assert(hurtbox, "Hurtbox incorrect for " + self.name)
	assert(status_manager, "Status Manager missing for " + self.name)
	assert(animation_player, "Animation player missing for " + self.name)
	assert(attack and attack.power > 0 and attack.type != null, "Attack property incorrect for " + self.name)
	assert(stats, "Stats property incorrect for " + self.name)
	assert(health and health.health > 0, "Health property incorrect for " + self.name)
	assert(movement, "Movement incorrect for " + self.name)

	health.died.connect(_on_death)
	# Inject timer creation capability into health resource - Dependency Injection
	health.initialize_timer_callback(_create_timer)

	_entity_ready()

	if _requires_goap():
		assert(ai_config, "GOAP Not properly configured for " + self.name)
		assert(goap_controller, "GoapController missing for " + self.name)
		assert(navigation_controller, "NavigationController missing for " + self.name)
		assert(perception_system, "Perception system missing for " + self.name)

		goap_agent = GoapAgent.new()
		var goals: Array[GoapGoal] = ai_config.create_goals()
		var actions: Array[GoapAction] = ai_config.create_actions()

		# Agent name helps with debugging
		goap_agent.name = "GoapAgent"

		goap_agent.init(self, goals, goap_controller, actions)
		add_child(goap_agent)

		register_goap_agent(goap_agent)

		# Disable navigation as goap will enable it when tracking
		navigation_controller.set_physics_process(false)

		assert(goap_agent != null, "NPCs must have GoapAgent. " + self.name)


## Virtual method for subclasses to override instead of _ready()
## This ensures the parent class logic is always executed exactly where needed via Template Method pattern.
func _entity_ready() -> void:
	pass


## Returns whether this entity requires a GOAP agent. Overridden by Player class.
func _requires_goap() -> bool:
	return true


# TODO Disable navigation for GOAP, disable player controller
# Maybe transform into abstract method? Player already overrides this
func _on_death() -> void:
	print_debug(str(self.name) + " is dead, Jim!")

	if goap_agent != null:
		print_debug("Disabling GOAP agent ", goap_agent.name)
		goap_agent.set_process(false)
	else:
		print_debug("GOAP agent not found")

	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)

	await get_tree().create_timer(10.0).timeout
	self.queue_free()


func register_goap_agent(agent: GoapAgent) -> void:
	print_debug("Registering GOAP agent: ", agent.name)
	goap_agent = agent


## Timer creation callback for Health resource (dependency injection)
func _create_timer(duration: float, callback: Callable) -> void:
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self):  # Entity alive?
		callback.call()
