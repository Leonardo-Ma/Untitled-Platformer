## HSlider bound to a SoundManager category bus. Set category in the Inspector.
extends HSlider

const DB_MAX: float = 6.0

@export_category("Audio")
@export var category: SoundManager.SoundCategory


func _ready() -> void:
	assert(category != SoundManager.SoundCategory.UNASSIGNED, "VolumeSlider: category not set in " + name)
	min_value = 0.0
	max_value = 1.0
	step = 0.01
	value = db_to_linear(SoundManager.get_category_volume(category))
	value_changed.connect(_on_volume_changed)


func _on_volume_changed(new_value: float) -> void:
	SoundManager.set_category_volume(category, linear_to_db(new_value) + DB_MAX)
