## HSlider bound to a SoundManager category bus. Set category in the Inspector.
extends HSlider

const DB_MIN: float = -60.0
const DB_MAX: float = 0.0

@export var category: SoundManager.SoundCategory


func _ready() -> void:
	assert(category != SoundManager.SoundCategory.UNASSIGNED, "VolumeSlider: category not set in " + name)
	min_value = DB_MIN
	max_value = DB_MAX
	value = SoundManager.get_category_volume(category)
	value_changed.connect(_on_volume_changed)


func _on_volume_changed(new_value: float) -> void:
	SoundManager.set_category_volume(category, new_value)
