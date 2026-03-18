## Generic abstract class for entities that take damage and attack
@abstract class_name AgressiveEntity
extends CharacterBody3D

signal melee_attacked()

@export var attack : Attack
@export var stats : EntityStats
@export var health : Health

var _goap_agent: GoapAgent = null

# TODO Consider @onready collision layer and mask (Maybe in a parent Entity class?)
@onready var hitbox: Hitbox = $"Hitbox"
@onready var hurtbox: Hurtbox = $"Hurtbox"

func _ready() -> void:
	assert(hitbox, "Hitbox incorrect for " + self.name)
	assert(hurtbox, "Hurtbox incorrect for " + self.name)
	assert(attack and attack.power > 0 and attack.type != null, "Attack property incorrect for " + self.name)
	assert(stats, "Stats property incorrect for " + self.name)
	assert(health and health.health > 0, "Health property incorrect for " + self.name)
	
	health.died.connect(_on_death)
	# Inject timer creation capability into health resource - Dependency Injection
	health.initialize_timer_callback(_create_timer)

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
