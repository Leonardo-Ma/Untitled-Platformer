## Teleports player between linked portals after crossing portal plane
class_name TeleportPortal
extends Area3D

@export var linked_portal: TeleportPortal

var _tracked_players: Dictionary[PlayerEntity, float] = {}
var _cooldown_players: Dictionary[PlayerEntity, bool] = {}

@onready var exit_marker: Marker3D = %ExitMarker


func _ready() -> void:
	assert(linked_portal != null, "Linked portal missing in " + name)
	assert(exit_marker != null, "ExitMarker missing in " + name)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	var players: Array[PlayerEntity] = _tracked_players.keys()

	for player: PlayerEntity in players:
		if not is_instance_valid(player):
			_tracked_players.erase(player)
			continue

		var previous_side: float = _tracked_players[player]
		var current_side: float = _portal_side(player.global_position)

		if previous_side > 0.0 and current_side <= 0.0:
			if not _cooldown_players.has(player):
				linked_portal._cooldown_players[player] = true
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


func _portal_side(position: Vector3) -> float:
	return global_transform.basis.z.dot(position - global_position)


func get_exit_transform(player_transform: Transform3D) -> Transform3D:
	var local_transform: Transform3D = global_transform.affine_inverse() * player_transform
	var destination_transform: Transform3D = linked_portal.global_transform * local_transform

	destination_transform.origin = exit_marker.global_position

	return destination_transform


func transform_velocity(velocity: Vector3) -> Vector3:
	return linked_portal.global_basis * global_basis.inverse() * velocity


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

	var step: Vector3 = exit_marker.global_basis.z.normalized() * 0.25
	var safe_transform: Transform3D = desired_transform

	for i: int in 8:
		safe_transform.origin += step
		query.transform = safe_transform

		if space_state.intersect_shape(query, 1).is_empty():
			return safe_transform

	return desired_transform
