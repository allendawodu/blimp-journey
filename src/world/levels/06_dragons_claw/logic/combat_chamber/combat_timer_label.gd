extends Label

@export var timer: Timer


func _process(delta: float) -> void:
	visible = not timer.is_stopped()
	text = str(roundi(timer.time_left))
