class_name StatTypes

enum Type {
	# Primary
	STRENGTH,  ## Melee damage | Carrying capacity
	CONSTITUTION,  ## Defense | HP Regen | Debuff resistance
	PERCEPTION,  ## Ranged accuracy | Ranged attack distance
	DEXTERITY,  ## Dodge change | Attack speed | Block speed | Reload speed
	INTELLIGENCE,  ## Crafting bonus | Science learning rate
	SPIRIT,  ## Magic power
	CHARISMA,  ##
	# Athletics
	ATHLETICS,  ## Player speed
	SWIMMING,  ## Swim speed
	RIDING,  ## Mount speed
	FLYING,  ## Flying speed | Spirit drain
	# General Stats (Useful for base modifications)
	MAX_HEALTH,
	HEALTH_REGEN,
	# Misc
	LEADERSHIP,  ## Squad capacity | Recruiting chance
	SCOUTING,  ## Larger map view
	# Science
	MEDICINE,  ## Better healing with items | Slightly higher hp regen
	ENGINEERING,  ## Unlock buildings | Repairing buildings rate
	# Merchant
	TRADING,  ## Better prices when buying or selling
	PERSUASSION,  ## Chance of persuassion or intimidation
	# Thievery
	ASSASSINATION,  ## Chance to kidnap or break free
	LOCKPICKING,  ## Ability to pick stronger locks
	STEALTH,  ## Chance of being discovered | Crouched walk speed
	THIEVERY,  ## Chance of stealing items | Increased value of stolen items
	# Melee
	UNARMED,
	SWORD,
	GREATSWORD,
	POLEARM,
	# Ranged
	BOW,
	CROSSBOW,
	THROWING,
	TURRETS,
	# Crafting
	COOKING,
	MINING,
	FARMING,
	SMITHING,
	FISHING,
	TRAPPING,
	FORAGING
}
