## General configuration for the perception system, holding multiple perception types
class_name PerceptionConfig
extends Resource

@export_group("General")
@export var update_interval: float = 0.1
@export var memory_duration: float = 10.0

@export_group("Visual")
@export var visual: VisualConfig = VisualConfig.new()
