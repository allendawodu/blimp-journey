extends Sprite2D

const HORIZONTAL_OFFSET: float = 64

@export_range(0, 1) var speed: float = 0.035


func _process(delta: float) -> void:
	# Move towards mouse
	global_position = global_position.lerp(get_global_mouse_position(), speed)

	# Flip direction
	if get_global_mouse_position().x < global_position.x - HORIZONTAL_OFFSET:
		flip_h = true
	elif get_global_mouse_position().x > global_position.x + HORIZONTAL_OFFSET:
		flip_h = false
