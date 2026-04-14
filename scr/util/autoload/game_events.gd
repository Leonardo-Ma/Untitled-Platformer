# https://refactoring.guru/design-patterns/observer
extends Node

@warning_ignore("unused_signal")
signal player_spawned(player: Node)
@warning_ignore("unused_signal")
signal counter_collectible_collected(identifier: StringName, amount: int, icon: Texture2D)
@warning_ignore("unused_signal")
signal status_buff_collectible_collected(status_effect: StatusEffect, icon: Texture2D)

var procedural_seed: int = 0
