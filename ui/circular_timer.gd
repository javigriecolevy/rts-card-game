extends Control
class_name CircularTimer

@export var timer: TextureProgressBar
@export var display: Label

var max_value: float = 1.0
var current_value: float = 1.0

func set_progress(value: float):
	current_value = clamp(value, 0.0, 1.0)
	timer.value = current_value * 100
