## Loads and applies settings on startup
## All read and write passes here
extends Node

const _CONFIG_PATH: String = "user://settings.cfg"

const _SECTION_VIDEO: String = "video"
const _SECTION_AUDIO: String = "audio"
const _SECTION_UI: String = "ui"

var resolution: Vector2i = Vector2i(1920, 1080)
var window_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_WINDOWED

var volume_global: float = 1.0
var volume_music: float = 1.0
var volume_effects: float = 1.0
var volume_ui: float = 1.0

var hud_visible: bool = true

var environment: Environment = preload("uid://dsshmu8vrps28")
var brightness: float = 1.0
var contrast: float = 1.0
var saturation: float = 1.0
var vsync_mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_DISABLED

var _config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	_load()
	_apply()


func save() -> void:
	_config.set_value(_SECTION_VIDEO, "resolution", resolution)
	_config.set_value(_SECTION_VIDEO, "window_mode", window_mode)
	_config.set_value(_SECTION_AUDIO, "volume_global", volume_global)
	_config.set_value(_SECTION_AUDIO, "volume_music", volume_music)
	_config.set_value(_SECTION_AUDIO, "volume_effects", volume_effects)
	_config.set_value(_SECTION_AUDIO, "volume_ui", volume_ui)
	_config.set_value(_SECTION_UI, "hud_visible", hud_visible)
	_config.set_value(_SECTION_VIDEO, "brightness", brightness)
	_config.set_value(_SECTION_VIDEO, "contrast", contrast)
	_config.set_value(_SECTION_VIDEO, "saturation", saturation)
	_config.set_value(_SECTION_VIDEO, "vsync_mode", vsync_mode)
	_config.save(_CONFIG_PATH)


func _load() -> void:
	if _config.load(_CONFIG_PATH) != OK:
		resolution = get_window().size
		return
	resolution = _config.get_value(_SECTION_VIDEO, "resolution", get_window().size)
	window_mode = _config.get_value(_SECTION_VIDEO, "window_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	volume_global = _config.get_value(_SECTION_AUDIO, "volume_global", 1.0)
	volume_music = _config.get_value(_SECTION_AUDIO, "volume_music", 1.0)
	volume_effects = _config.get_value(_SECTION_AUDIO, "volume_effects", 1.0)
	volume_ui = _config.get_value(_SECTION_AUDIO, "volume_ui", 1.0)
	hud_visible = _config.get_value(_SECTION_UI, "hud_visible", true)
	brightness = _config.get_value(_SECTION_VIDEO, "brightness", 1.0)
	contrast = _config.get_value(_SECTION_VIDEO, "contrast", 1.0)
	saturation = _config.get_value(_SECTION_VIDEO, "saturation", 1.0)
	vsync_mode = _config.get_value(_SECTION_VIDEO, "vsync_mode", DisplayServer.VSYNC_DISABLED)


func _apply() -> void:
	DisplayServer.window_set_mode(window_mode)
	if window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		get_window().size = resolution
	SoundManager.set_category_volume(SoundManager.SoundCategory.GLOBAL, linear_to_db(volume_global))
	SoundManager.set_category_volume(SoundManager.SoundCategory.MUSIC, linear_to_db(volume_music))
	SoundManager.set_category_volume(SoundManager.SoundCategory.SFX, linear_to_db(volume_effects))
	SoundManager.set_category_volume(SoundManager.SoundCategory.UI, linear_to_db(volume_ui))
	environment.adjustment_brightness = brightness
	environment.adjustment_contrast = contrast
	environment.adjustment_saturation = saturation
	DisplayServer.window_set_vsync_mode(vsync_mode)
