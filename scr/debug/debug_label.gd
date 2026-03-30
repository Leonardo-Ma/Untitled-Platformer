extends Label

var event_text: String

@onready var player: CharacterBody3D = %Player


# TODO Maybe change this to multi line string?
func _process(_delta: float) -> void:
	if not self.visible:
		return

	self.text = "State: " + PlayerGlobals.player_state
	self.text += "FPS: %s\n" % Engine.get_frames_per_second()
	self.text += "Move Speed: %.1f\n" % PlayerGlobals.player_speed if PlayerGlobals.player else ""
	self.text += "Position: %.1v\n" % PlayerGlobals.player.global_position if PlayerGlobals.player else ""
	if PlayerGlobals.player_health:
		self.text += "Player health: %.2f\n" % PlayerGlobals.player_health.health
		self.text += "Invulnerable: %s\n" % ("YES" if PlayerGlobals.player_health.invulnerable else "NO")
	self.text += event_text + "\n"


func _unhandled_key_input(event: InputEvent) -> void:
	event_text = event.as_text()
