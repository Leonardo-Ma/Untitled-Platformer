extends TextEdit


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_attributes"):
		self.visible = not self.visible
	self.text = (
		"\t\tMain Attributes:"
		+ "\nstrenght :"
		+ str(Attributes.strenght)
		+ "\nconstitution :"
		+ str(Attributes.constitution)
		+ "\nperception :"
		+ str(Attributes.perception)
		+ "\ndexterity :"
		+ str(Attributes.dexterity)
		+ "\nintelligence :"
		+ str(Attributes.intelligence)
		+ "\nspirit :"
		+ str(Attributes.spirit)
		+ "\ncharisma :"
		+ str(Attributes.charisma)
	)
