class_name SkillsController
extends Node

var is_sliding: bool = false
var base_fov: float = 0.0
var modules: Array[PlayerSkillModule] = []

@onready var entity: CharacterBody3D = owner
@onready var movement_controller: MovementController = %MovementController
@onready var camera_controller: Node3D = %CamRoot
@onready var health: Health = owner.health
@onready var camera: Camera3D = null


func _ready() -> void:
	if not entity.skills:
		return

	if camera_controller.has_node("SpringArm3D/Camera3D"):
		camera = camera_controller.get_node("SpringArm3D/Camera3D")
		base_fov = camera.fov

	_initialize_modules()

	# Hook into MovementController signals to reset aerial limits
	movement_controller.landed.connect(_on_landed)


func process_skills(body: CharacterBody3D, delta: float) -> void:
	var skills: PlayerSkills = entity.skills
	if not skills:
		return

	for module: PlayerSkillModule in modules:
		module.process_timers(skills, delta)
		module.process_passive(body, skills, delta)
		module.handle_input(body, skills)
		module.apply_logic(body, skills)


func _initialize_modules() -> void:
	modules.append(PlayerMultiJumpSkill.new(self))
	modules.append(PlayerGroundDashSkill.new(self))
	modules.append(PlayerAirDashSkill.new(self))
	modules.append(PlayerTeleportSkill.new(self))
	modules.append(PlayerFeatherFallSkill.new(self))


func _on_landed() -> void:
	for module: PlayerSkillModule in modules:
		module.on_landed()
