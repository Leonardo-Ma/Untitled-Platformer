# TODO Comment or document the exact key to the side of each entry
class_name PlaystationMap
extends GamepadMap

const _BUTTONS: Dictionary = {
	# Buttons
	JoyButton.JOY_BUTTON_A: preload("uid://bky233226p78x"),
	JoyButton.JOY_BUTTON_B: preload("uid://c16jn1pgb0gmf"),
	JoyButton.JOY_BUTTON_X: preload("uid://bulgo3y4xxoxa"),
	JoyButton.JOY_BUTTON_Y: preload("uid://bs88hy0k64aiq"),
	# Shoulder
	JoyButton.JOY_BUTTON_LEFT_SHOULDER: preload("uid://b41wr5xhif10u"),
	JoyButton.JOY_BUTTON_RIGHT_SHOULDER: preload("uid://juhx1nfoy4t7"),
	# Stick press
	JoyButton.JOY_BUTTON_LEFT_STICK: preload("uid://c3p5g57hgsf5k"),
	JoyButton.JOY_BUTTON_RIGHT_STICK: preload("uid://bmp5xf2epv4ij"),
	# Misc
	JoyButton.JOY_BUTTON_BACK: preload("uid://b8f1v05fs4lw1"),
	JoyButton.JOY_BUTTON_START: preload("uid://ccbv7v7ayacwj"),
	# Dpad
	JoyButton.JOY_BUTTON_DPAD_UP: preload("uid://cny02a2x75xa6"),
	JoyButton.JOY_BUTTON_DPAD_DOWN: preload("uid://bywu3lh1l8ci6"),
	JoyButton.JOY_BUTTON_DPAD_LEFT: preload("uid://b8xbq8o6u6wbf"),
	JoyButton.JOY_BUTTON_DPAD_RIGHT: preload("uid://cipfqkfteovgw"),
}

const _AXES: Dictionary = {
	JoyAxis.JOY_AXIS_TRIGGER_LEFT: preload("uid://fv54oc8li7ql"),
	JoyAxis.JOY_AXIS_TRIGGER_RIGHT: preload("uid://d2kmi1yrbny0v"),
}


func get_button_icon(button: JoyButton) -> Texture2D:
	return _BUTTONS.get(button, null)


func get_axis_icon(axis: JoyAxis, _direction: int) -> Texture2D:
	return _AXES.get(axis, null)
