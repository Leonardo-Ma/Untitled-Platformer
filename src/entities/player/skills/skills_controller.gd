class_name SkillsController
extends Node

var is_sliding: bool = false
var base_fov: float = 0.0
var active_skills: Array[ActivePlayerSkill] = []

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

	_initialize_active_skills()

	# Hook into MovementController signals to reset aerial limits
	movement_controller.landed.connect(_on_landed)


#region Visual effect


func spawn_ghost_trail(duration: float = 0.5, color: Color = Color(0.8, 1.0, 1.5, 0.4)) -> void:
	var vfx: Node = get_node("%VFXController")
	vfx.spawn_ghost_trail(duration, color)


#endregion


func process_skills(body: CharacterBody3D, delta: float) -> void:
	var skills: PlayerSkills = entity.skills
	if not skills:
		return

	for active_skill: ActivePlayerSkill in active_skills:
		active_skill.process_timers(skills, delta)
		active_skill.process_passive(body, skills, delta)
		active_skill.handle_input(body, skills)
		active_skill.apply_logic(body, skills)


func _initialize_active_skills() -> void:
	active_skills.append(PlayerMultiJumpSkill.new(self))
	active_skills.append(PlayerGroundDashSkill.new(self))
	active_skills.append(PlayerAirDashSkill.new(self))
	active_skills.append(PlayerTeleportSkill.new(self))
	active_skills.append(PlayerFeatherFallSkill.new(self))


func _on_landed() -> void:
	for active_skill: ActivePlayerSkill in active_skills:
		active_skill.on_landed()
