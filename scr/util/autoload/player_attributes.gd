extends Node

## Primary Player Attributes
@onready var strenght: float = 0  ## Melee damage | Carrying capacity
@onready var constitution: float = 0  ## Defense | HP Regen | Debuff resistance
@onready var perception: float = 0  ## Ranged accuracy | Ranged attack distance
@onready var dexterity: float = 0  ## Dodge change | Attack speed | Block speed | Reload speed
@onready var intelligence: float = 0  ## Crafting bonus | Science learning rate
@onready var spirit: float = 0  ## Magic power
@onready var charisma: float = 0  ##

## Athletics Attributes
@onready var athletics: float = 0  ## Player speed
@onready var swimming: float = 0  ## Swim speed
@onready var riding: float = 0  ## Mount speed
@onready var flying: float = 0  ## Flying speed | Spirit drain

## Misc Attributes
@onready var leadership: float = 0  ## Squad capacity | Recruiting chance
@onready var scouting: float = 0  ## Larger map view

## Science Attributes
@onready var medicine: float = 0  ## Better healing with items | Slightly higher hp regen
@onready var engineering: float = 0  ## Unlock buildings | Repairing buildings rate

## Merchant Attributes
@onready var trading: float = 0  ## Better prices when buying or selling
@onready var persuassion: float = 0  ## Chance of persuassion or intimidation

## Thievery Attributes
@onready var assassination: float = 0  ## Chance to kidnap or break free
@onready var lockpingping: float = 0  ## Ability to pick stronger locks
@onready var stealth: float = 0  ## Chance of being discovered | Crouched walk speed
@onready var thievery: float = 0  ## Chance of stealing items | Increased value of stolen items

## Melee weapon attributes
@onready var unarmed: float = 0
@onready var sword: float = 0
@onready var greatsword: float = 0
@onready var polearm: float = 0

## Ranged Weapon Attributes
@onready var bow: float = 0
@onready var crossbow: float = 0
@onready var throwing: float = 0
@onready var turrets: float = 0

## Crafting Attributes
@onready var cooking: float = 0
@onready var mining: float = 0
@onready var farming: float = 0
@onready var smithing: float = 0
@onready var fishing: float = 0
@onready var trapping: float = 0
@onready var foraging: float = 0
