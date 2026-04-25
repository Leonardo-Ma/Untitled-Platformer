## AI's memory of an entity it has perceived
class_name KnownEntityData
extends Resource

var entity: Node3D
var last_known_position: Vector3
var last_detection_time: float
var detection_count: int = 0
var confidence: float = 0.0


func _init(entity_ref: Node3D, position: Vector3, confidence_val: float) -> void:
	entity = entity_ref
	last_known_position = position
	last_detection_time = Time.get_ticks_msec() / 1000.0
	confidence = confidence_val
	detection_count = 1


func update(position: Vector3, confidence_val: float) -> void:
	last_known_position = position
	last_detection_time = Time.get_ticks_msec() / 1000.0
	confidence = max(confidence, confidence_val)
	detection_count += 1


func is_valid(current_time: float, memory_duration: float) -> bool:
	return current_time - last_detection_time <= memory_duration
