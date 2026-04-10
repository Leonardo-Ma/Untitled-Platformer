## Template class for objects that receive the player_interact() raycast prompt
## Since RayCast3D detects bodies directly, this defaults to StaticBody3D for physical presence
@abstract class_name Interactable
extends StaticBody3D


# TODO Use this for inventory
## To override
func player_interact() -> void:
	assert(false, "player_interact() must be overridden in " + self.name)
