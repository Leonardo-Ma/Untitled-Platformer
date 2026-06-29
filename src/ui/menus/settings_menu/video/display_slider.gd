## To a adjust display (brightness, contrast, saturation)
extends HSlider

enum DisplayProperty { BRIGHTNESS, CONTRAST, SATURATION }

const _DB_MAX: float = 1.5
const _DB_MIN: float = 0.5

@export var property: DisplayProperty


func _ready() -> void:
	assert(property != null, "DisplaySlider: property not set in " + name)
	min_value = _DB_MIN
	max_value = _DB_MAX
	value = _get_saved_value()
	value_changed.connect(_on_value_changed)


func _on_value_changed(v: float) -> void:
	match property:
		DisplayProperty.BRIGHTNESS:
			SettingsManager.brightness = v
		DisplayProperty.CONTRAST:
			SettingsManager.contrast = v
		DisplayProperty.SATURATION:
			SettingsManager.saturation = v
	SettingsManager._apply()
	SettingsManager.save()


func _get_saved_value() -> float:
	match property:
		DisplayProperty.BRIGHTNESS:
			return SettingsManager.brightness
		DisplayProperty.CONTRAST:
			return SettingsManager.contrast
		DisplayProperty.SATURATION:
			return SettingsManager.saturation
	return 1.0
