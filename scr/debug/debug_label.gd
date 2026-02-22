extends Label

var eventText : String

# TODO Maybe change this to multi line string?
func _process(_delta : float) -> void:
	self.text = "State: " + Globals.player_state
	self.text += "FPS: %s\n" % Engine.get_frames_per_second()
	self.text += "Move Speed: %.1f\n" % Globals.player_speed if Globals.player else ""
	self.text += "Position: %.1v\n" % Globals.player.global_position if Globals.player else ""
	self.text += "Player health: %.2f\n" % Globals.player_health.health
	self.text += "Invulnerable: %s\n" % ("YES" if Globals.player_health.invulnerable else "NO")
	self.text += eventText + "\n"
	
func _unhandled_key_input(event: InputEvent) -> void:
	eventText = event.as_text()
