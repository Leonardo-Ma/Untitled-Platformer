## Teleports player between linked portals after crossing portal plane
## Uses a plane-based detection system and handles cooldowns to prevent teleport loops
class_name TeleportPortal
extends Area3D

const TELEPORT_SOUNDS: Array[AudioStream] = [
	preload("uid://kw3i7ckrkmv8"),  # teleport.wav
]
@export var linked_portal: TeleportPortal
@export var cooldown_duration_seconds: float = 3.0

var is_disabled: bool = false
var _cooldown_timer: float = 0.0

## Tracks players inside the portal and their side of the portal plane (positive/negative)
var _tracked_players: Dictionary[PlayerEntity, float] = {}
## Prevents rapid back-and-forth teleportation by blocking players on cooldown
var _cooldown_players: Dictionary[PlayerEntity, bool] = {}

@onready var exit_marker: Marker3D = %ExitMarker
@onready var enabled_mesh: MeshInstance3D = %EnabledMesh
@onready var disabled_mesh: MeshInstance3D = %DisabledMesh


func _ready() -> void:
	assert(linked_portal != null, "Linked portal missing in " + name)
	assert(exit_marker != null, "ExitMarker missing in " + name)
	assert(enabled_mesh != null, "EnabledMesh missing in " + name)
	assert(disabled_mesh != null, "DisabledMesh missing in " + name)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_mesh_visibility()
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	## Handle cooldown timer
	if _cooldown_timer > 0.0:
		_cooldown_timer -= _delta
		if _cooldown_timer <= 0.0:
			set_disabled(false)

	if _tracked_players.is_empty():
		return

	## Cache the players array to avoid repeated `.keys()` calls
	var players: Array[PlayerEntity] = _tracked_players.keys()

	for player: PlayerEntity in players:
		if not is_instance_valid(player):
			_tracked_players.erase(player)
			continue

		var previous_side: float = _tracked_players[player]
		var current_side: float = _portal_side(player.global_position)

		## Teleport when crossing from positive to negative side (if not on cooldown)
		if previous_side > 0.0 and current_side <= 0.0:
			if not _cooldown_players.has(player) and not is_disabled:
				linked_portal._cooldown_players[player] = true
				linked_portal.set_disabled(true)
				linked_portal._cooldown_timer = cooldown_duration_seconds

				SoundManager.play_sound(TELEPORT_SOUNDS.pick_random(), SoundManager.SoundCategory.SFX, player.global_position)
				await player.begin_portal_transition(self, linked_portal)

		_tracked_players[player] = current_side


func _on_body_entered(body: Node3D) -> void:
	if body is not PlayerEntity:
		return

	var player: PlayerEntity = body

	if _cooldown_players.has(player):
		return

	_tracked_players[player] = _portal_side(player.global_position)


func _on_body_exited(body: Node3D) -> void:
	if body is not PlayerEntity:
		return

	var player: PlayerEntity = body

	_tracked_players.erase(player)
	_cooldown_players.erase(player)


## What side the portal is on
## Positive = front (entry side), Negative = back (exit side)
func _portal_side(position: Vector3) -> float:
	return global_transform.basis.z.dot(position - global_position)


func get_exit_transform(player_transform: Transform3D) -> Transform3D:
	var local_transform: Transform3D = global_transform.affine_inverse() * player_transform
	var destination_transform: Transform3D = linked_portal.global_transform * local_transform

	destination_transform.origin = exit_marker.global_position

	return destination_transform


## Adjusts velocity to match the linked portal's orientation
func transform_velocity(velocity: Vector3) -> Vector3:
	return linked_portal.global_basis * global_basis.inverse() * velocity


## Finds a collision-free exit position by stepping outward if needed
func find_safe_exit(player_shape: Shape3D, desired_transform: Transform3D) -> Transform3D:
	assert(player_shape != null, "Player collision shape missing in " + name)

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = player_shape
	query.transform = desired_transform
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	if space_state.intersect_shape(query, 1).is_empty():
		return desired_transform

	## Step outward in small increments to avoid collisions
	var step: Vector3 = exit_marker.global_basis.z.normalized() * 0.25
	var safe_transform: Transform3D = desired_transform

	for i: int in 8:
		safe_transform.origin += step
		query.transform = safe_transform

		if space_state.intersect_shape(query, 1).is_empty():
			return safe_transform

	return desired_transform


## Updates visibility of both enabled and disabled meshes based on portal state
func _update_mesh_visibility() -> void:
	enabled_mesh.visible = not is_disabled
	disabled_mesh.visible = is_disabled


## Public method to toggle the portal's disabled state
func set_disabled(value: bool) -> void:
	is_disabled = value
	_update_mesh_visibility()
