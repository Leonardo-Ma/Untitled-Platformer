extends Node

var visualizer_scene: PackedScene = preload("res://scr/goap/graph_builder/goap_graph_builder.tscn")
var visualizer_instance: GoapGraphBuilder = null
var visualizer_window: Window = null

const PAUSE_SOURCE: String = "goap_visualizer"

func _ready() -> void:
	# Only enable in debug builds
	if OS.is_debug_build():
		set_process_input(true)

func _input(event: InputEvent) -> void:
	# Toggle visualizer with F9 key (or any key you prefer)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		toggle_visualizer()

func toggle_visualizer() -> void:
	if visualizer_window == null:
		_create_visualizer()
	else:
		_close_visualizer()

func _create_visualizer() -> void:
	# Create a new window for the visualizer
	visualizer_window = Window.new()
	visualizer_window.title = "GOAP Graph Visualizer"
	visualizer_window.size = Vector2i(1200, 800)
	visualizer_window.position = Vector2i(100, 100)
	visualizer_window.close_requested.connect(_close_visualizer)
	
	# Instantiate the graph builder
	visualizer_instance = visualizer_scene.instantiate()
	visualizer_window.add_child(visualizer_instance)
	
	# Add window to scene tree
	get_tree().root.add_child(visualizer_window)
	visualizer_window.show()
	
	# Request pause
	PauseManager.request_pause(PAUSE_SOURCE)

func _close_visualizer() -> void:
	if visualizer_window:
		# Release pause
		PauseManager.release_pause(PAUSE_SOURCE)
		
		visualizer_window.queue_free()
		visualizer_window = null
		visualizer_instance = null
