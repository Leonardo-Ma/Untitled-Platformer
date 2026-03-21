# https://www.youtube.com/watch?v=f90ieBOoIYQ DashNothing - How to Make a Great Health Bar in Godot 4 | Let's Godot
extends ProgressBar

var health: float = 0.0:
	set = _set_health

@onready var timer: Timer = $Timer
@onready var damagebar: ProgressBar = $Damagebar
@onready var health_resource: Health = Globals.player_health
# BUG There's a delay between hit and healthbar (green) update


func _ready() -> void:
	health_resource.damaged.connect(_on_damaged)
	health_resource.died.connect(_on_death)

	# Initialize health bars
	health = health_resource.health
	max_value = health_resource.max_health
	damagebar.max_value = health_resource.max_health


func _set_health(new_health: float) -> void:
	var prev_health: float = health
	health = clampf(new_health, 0, max_value)
	value = health

	# Timer for damage bar animation
	if health < prev_health:
		timer.start()
	else:
		# If health increased, update damage bar immediately
		damagebar.value = health


func _on_damaged(_attack: Attack) -> void:
	health = health_resource.health


func _on_death() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	# Animate damagebar down to match current health
	damagebar.value = health
