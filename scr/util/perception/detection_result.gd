## Structure holding the result of a single detection check
class_name DetectionResult
extends RefCounted

var is_detected: bool = false
var confidence: float = 0.0
var type: int = 0
var detected_position: Vector3 = Vector3.ZERO
var detected_entity: Node3D = null
