extends TextEdit

@onready var player: CharacterBody3D = $"../../../Player"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_attributes"):
		self.visible = not self.visible

	if not self.visible:
		return

	# TODO Improve this, should be dynamic
	self.text = (
		"\t\tMain Attributes:"
		+ "\nstrength :"
		+ str(player.stats.get_stat(StatTypes.Type.STRENGTH))
		+ "\nconstitution :"
		+ str(player.stats.get_stat(StatTypes.Type.CONSTITUTION))
		+ "\nperception :"
		+ str(player.stats.get_stat(StatTypes.Type.PERCEPTION))
		+ "\ndexterity :"
		+ str(player.stats.get_stat(StatTypes.Type.DEXTERITY))
		+ "\nintelligence :"
		+ str(player.stats.get_stat(StatTypes.Type.INTELLIGENCE))
		+ "\nspirit :"
		+ str(player.stats.get_stat(StatTypes.Type.SPIRIT))
		+ "\ncharisma :"
		+ str(player.stats.get_stat(StatTypes.Type.CHARISMA))
	)
