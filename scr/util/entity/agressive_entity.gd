## Generic abstract class for entities that take damage and attack
@abstract class_name AgressiveEntity
extends CharacterBody3D

@warning_ignore("unused_signal")
signal melee_attacked

@export var attack: Attack
@export var health: Health
@export var movement: Movement
@export var stats: EntityStats

var _goap_agent: GoapAgent = null

# TODO Consider @onready collision layer and mask (Maybe in a parent Entity class?)
@onready var hitbox: Hitbox = %Hitbox
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var status_manager: StatusManager = %StatusManager


## Inherited artifacts should override _entity_ready instead of this
func _ready() -> void:
	assert(hitbox, "Hitbox incorrect for " + self.name)
	assert(hurtbox, "Hurtbox incorrect for " + self.name)
	assert(status_manager, "Status Manager node missing for " + self.name)
	assert(attack and attack.power > 0 and attack.type != null, "Attack property incorrect for " + self.name)
	assert(stats, "Stats property incorrect for " + self.name)
	assert(health and health.health > 0, "Health property incorrect for " + self.name)
	assert(movement, "Movement incorrect for " + self.name)

	health.died.connect(_on_death)
	# Inject timer creation capability into health resource - Dependency Injection
	health.initialize_timer_callback(_create_timer)

	_entity_ready()

	if _requires_goap():
		assert(_goap_agent != null, "NPCs must have GoapAgent." + self.name)


## Virtual method for subclasses to override instead of _ready()
## This ensures the parent class logic is always executed exactly where needed via Template Method pattern.
func _entity_ready() -> void:
	pass


## Returns whether this entity requires a GOAP agent. Overridden by Player class.
func _requires_goap() -> bool:
	return true


func _on_death() -> void:
	print_debug(str(self.name) + " is dead, Jim!")

	if _goap_agent != null:
		print_debug("Disabling GOAP agent ", _goap_agent.name)
		_goap_agent.set_process(false)
	else:
		print_debug("GOAP agent not found")

	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)

	await get_tree().create_timer(10.0).timeout
	self.queue_free()


func register_goap_agent(agent: GoapAgent) -> void:
	print_debug("Registering GOAP agent: ", agent.name)
	_goap_agent = agent


## Timer creation callback for Health resource (dependency injection)
func _create_timer(duration: float, callback: Callable) -> void:
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self):  # Entity alive?
		callback.call()
