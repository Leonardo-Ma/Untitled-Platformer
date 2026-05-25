extends Area3D


func _ready() -> void:
	body_entered.connect(_on_player_leave_tutorial)


func _on_player_leave_tutorial(body: Node3D) -> void:
	if body is PlayerEntity:
		owner.free.call_deferred()
