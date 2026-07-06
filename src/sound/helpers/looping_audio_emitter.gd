## Continuous 3D audio loop with intensity driven volume and pitch [br]
## Attach as child of Node3D (VehicleAudioController script) [br]
## call update_intensity() every physics frame
class_name LoopingAudioEmitter
extends AudioStreamPlayer3D

@export var min_pitch: float = 0.8
@export var max_pitch: float = 1.8
@export var min_volume_db: float = -80.0
@export var max_volume_db: float = 0.0
@export var fade_speed: float = 4.0

var _target_intensity: float = 0.0
var _current_intensity: float = 0.0


func _ready() -> void:
	stream.loop = true
	volume_db = min_volume_db
	pitch_scale = min_pitch
	play()


func _process(delta: float) -> void:
	if is_equal_approx(_current_intensity, _target_intensity):
		return
	_current_intensity = move_toward(_current_intensity, _target_intensity, fade_speed * delta)
	volume_db = lerp(min_volume_db, max_volume_db, _current_intensity)
	pitch_scale = lerp(min_pitch, max_pitch, _current_intensity)


## Clamp intensity
func update_intensity(intensity: float) -> void:
	_target_intensity = clampf(intensity, 0.0, 1.0)
