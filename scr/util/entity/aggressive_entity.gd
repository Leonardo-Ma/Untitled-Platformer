# TODO Consider extending a base (non-aggressive) entity?
# subclass sandbox https://www.youtube.com/watch?v=oIrvZDDWxhU&t=50s - GDQuest Five Must Have Code Patterns for Your Godot Game
## Generic abstract class for entities that take damage and attack
## Refer to subclass sandbox https://gameprogrammingpatterns.com/subclass-sandbox.html
@abstract class_name AggressiveEntity
extends CharacterBody3D

@warning_ignore("unused_signal")
signal melee_attacked

const DAMAGE_SOUNDS: Array[AudioStream] = [
	preload("res://scr/sound/combat/chequered_ink/punch.wav"),
	preload("res://scr/sound/combat/chequered_ink/punch_2.wav"),
	preload("res://scr/sound/combat/chequered_ink/punch_3.wav")
]

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
var _damage_material: StandardMaterial3D
var _damage_tween: Tween
var _prev_health: int = 0

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
	assert(attack and attack.damage > 0 and attack.type != null, "Attack property incorrect for " + self.name)
	assert(stats, "Stats property incorrect for " + self.name)
	assert(health and health.health > 0, "Health property incorrect for " + self.name)
	assert(movement, "Movement incorrect for " + self.name)

	# Damage visual feedback
	_setup_damage_material()

	_prev_health = health.health
	health.died.connect(_on_death)
	health.damaged.connect(_on_damaged)
	health.health_changed.connect(_on_health_changed)
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
@abstract func _entity_ready() -> void

## Returns whether this entity requires a GOAP agent. Overridden by Player class.
@abstract func _requires_goap() -> bool


# TODO Disable navigation for GOAP, disable player controller
# Maybe transform into abstract method to force override?
# Player already overrides this
func _on_death() -> void:
	print_debug(str(self.name) + " is dead, Jim!")

	if _damage_tween and _damage_tween.is_valid():
		_damage_tween.kill()

	if goap_agent != null:
		print_debug("Disabling GOAP agent ", goap_agent.name)
		goap_agent.set_process(false)
	else:
		print_debug("GOAP agent not found")

	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)

	var death_tween: Tween = create_tween()

	death_tween.tween_interval(2.0)
	death_tween.tween_property(self, "scale", Vector3(0.001, 0.001, 0.001), 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(5.0).timeout
	self.queue_free()


func register_goap_agent(agent: GoapAgent) -> void:
	print_debug("Registering GOAP agent: ", agent.name)
	goap_agent = agent


#region Visual damage effect
func _setup_damage_material() -> void:
	_damage_material = StandardMaterial3D.new()
	_damage_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_damage_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_damage_material.albedo_color = Color(1.0, 1.0, 1.0, 0.0)

	for mesh: MeshInstance3D in _get_all_mesh_instances(self):
		mesh.material_overlay = _damage_material


func _on_damaged(_attack: Attack) -> void:
	if _damage_tween and _damage_tween.is_valid():
		_damage_tween.kill()

	SoundManager.play_combat_sound(DAMAGE_SOUNDS.pick_random(), Vector2(global_position.x, global_position.z), 1)

	_damage_material.albedo_color = Color(1.0, 1.0, 1.0, 0.5)
	_damage_tween = create_tween()
	_damage_tween.tween_property(_damage_material, "albedo_color:a", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_health_changed(new_health: int) -> void:
	if new_health > _prev_health:
		if _damage_tween and _damage_tween.is_valid():
			_damage_tween.kill()
		# Flash green on heal (pulse)
		_damage_material.albedo_color = Color(0.3, 1.0, 0.3, 0.4)
		_damage_tween = create_tween()
		_damage_tween.tween_property(_damage_material, "albedo_color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_prev_health = new_health


func _get_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			result.append(child)
		result.append_array(_get_all_mesh_instances(child))
	return result


#endregion


## Timer creation callback for Health resource (dependency injection)
func _create_timer(duration: float, callback: Callable) -> void:
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self):  # Entity alive?
		callback.call()
