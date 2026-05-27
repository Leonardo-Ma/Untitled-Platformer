## Template for all skills
@abstract class_name BaseSkill
extends Node

@warning_ignore("unused_signal")
signal cooldown_started(duration: float)
@warning_ignore("unused_signal")
signal cooldown_finished
@warning_ignore("unused_signal")
signal cooldown_soft_started(duration: float)
@warning_ignore("unused_signal")
signal charges_updated(charges: int)
@warning_ignore("unused_signal")
signal toggled(active: bool)

enum HUDMode {
	COOLDOWN,  ## Progress bar drains over a duration; blocks input while active
	COOLDOWN_SOFT,  ## Progress bar drains but does NOT grey out the slot
	CHARGES,  ## Numeric charge counter; slot dims at zero
	TOGGLE,  ## Slot pulses green while active
	NONE,  ## Icon only, no state display
}

## Injected by SkillsController immediately after add_child()
var definition: SkillDefinition
var skills_controller: SkillsController


func get_hud_mode() -> HUDMode:
	return HUDMode.NONE


## Called every physics frame by SkillsController
## To override
func process_input() -> void:
	pass


## When the player lands, optional override
func on_landed() -> void:
	pass
