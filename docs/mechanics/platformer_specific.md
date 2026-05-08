# Platformer Specific Mechanics

#### Coyote time
- Technique that allow players to jump after a short period of time of falling a platform.
Example:
```bash
var coyote_time_duration = 0.08
var coyote_timer = 0.0

func _physics_process(delta):
    if is_on_floor():
        coyote_timer = coyote_time_duration
    else:
        coyote_timer -= delta

    if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0):
        velocity.y = jump_velocity
        coyote_timer = 0.0
```

#### Jump cutting
```bash
if not body.is_on_floor():
		coyote_timer -= delta
		in_air.emit()
		body.velocity.y -= gravity * delta

		# Jump cutting: if jump button is released while moving upwards, cut velocity
		if Input.is_action_just_released("jump") and body.velocity.y > 0.0:
			body.velocity.y *= 0.5
```
