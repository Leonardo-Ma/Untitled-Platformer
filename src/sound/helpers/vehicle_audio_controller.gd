## Drives engine and skid loops for a vehicle from speed and wheel slip
class_name VehicleAudioController
extends Node

const SKID_START_SOUNDS: Array[AudioStream] = [preload("uid://cdcvdombioj0x")]  # skid.ogg
const SKID_INTENSITY_THRESHOLD: float = 0.6
const SKID_RETRIGGER_COOLDOWN: float = 0.4

@export var max_reference_speed: float = 30.0
@export var lateral_slip_threshold: float = 3.0
@export var lateral_slip_max: float = 12.0

var _engine_loop: LoopingAudioEmitter
var _skid_loop: LoopingAudioEmitter
var _was_skidding: bool = false
var _skid_cooldown: float = 0.0

@onready var _vehicle: VehicleBody3D = owner as VehicleBody3D


func _ready() -> void:
	assert(_vehicle != null, "VehicleAudioController owner must be VehicleBody3D in " + name)
	_engine_loop = _get_emitter("EngineLoop")
	_skid_loop = _get_emitter("SkidLoop")


func _physics_process(delta: float) -> void:
	if _skid_cooldown > 0.0:
		_skid_cooldown -= delta

	var speed_ratio: float = clampf(_vehicle.linear_velocity.length() / max_reference_speed, 0.0, 1.0)
	_engine_loop.update_intensity(speed_ratio)

	var lateral_speed: float = absf(_vehicle.linear_velocity.dot(_vehicle.global_transform.basis.x))
	var slip_ratio: float = clampf((lateral_speed - lateral_slip_threshold) / (lateral_slip_max - lateral_slip_threshold), 0.0, 1.0)
	_skid_loop.update_intensity(slip_ratio)

	var is_skidding: bool = slip_ratio > SKID_INTENSITY_THRESHOLD
	if is_skidding and not _was_skidding and _skid_cooldown <= 0.0:
		SoundManager.play_sound(SKID_START_SOUNDS.pick_random(), SoundManager.SoundCategory.VEHICLE, _vehicle.global_position)
		_skid_cooldown = SKID_RETRIGGER_COOLDOWN
	_was_skidding = is_skidding


func _get_emitter(node_name: String) -> LoopingAudioEmitter:
	var emitter: LoopingAudioEmitter = get_node(node_name) as LoopingAudioEmitter
	assert(emitter != null, "VehicleAudioController: %s missing in %s" % [node_name, name])
	return emitter
