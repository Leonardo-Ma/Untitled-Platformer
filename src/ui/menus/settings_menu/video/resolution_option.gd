extends OptionButton

# Ordered by Steam survey popularity (April 2026)
# https://store.steampowered.com/hwsurvey
const RESOLUTIONS: Array[Vector2i] = [
	# 16:9
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
	# 16:10
	Vector2i(1280, 800),
	Vector2i(1920, 1200),
	Vector2i(2560, 1600),
	# Ultrawide 21:9
	Vector2i(2560, 1080),
	Vector2i(3440, 1440),
	# Super ultrawide 32:9
	Vector2i(3840, 1080),
	Vector2i(5120, 1440),
]


func _ready() -> void:
	for resolution: Vector2i in RESOLUTIONS:
		add_item("%d x %d" % [resolution.x, resolution.y])

	self.selected = _get_default_index()
	get_window().size_changed.connect(_on_window_size_changed)
	item_selected.connect(_on_resolution_changed)


func _on_window_size_changed() -> void:
	var window: Window = get_window()
	if window.mode != Window.MODE_WINDOWED:
		return
	var idx: int = RESOLUTIONS.find(window.size)
	if idx != -1:
		self.selected = idx


func _on_resolution_changed(index: int) -> void:
	var window: Window = get_window()
	var resolution: Vector2i = RESOLUTIONS[index]
	if window.mode == Window.MODE_WINDOWED:
		window.size = resolution
	_save_resolution(resolution)


func _get_default_index() -> int:
	var saved: Variant = _load_resolution()
	if saved is Vector2i:
		var idx: int = RESOLUTIONS.find(saved)
		return idx if idx != -1 else 0
	return 0


func _save_resolution(resolution: Vector2i) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("video", "resolution", resolution)
	config.save("user://settings.cfg")


func _load_resolution() -> Variant:
	var config: ConfigFile = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		return config.get_value("video", "resolution", null)
	return null
