@tool
extends PCamAddon
class_name PCamMouseFollow

@export var max_offset := Vector2(300.0, 300.0)
@export_range(0, 1) var damping := 0.1
var actual_offset := Vector2.ZERO

func _init():
	stage = "pre_process"

func pre_process(camera, delta):
	if not enabled or camera._playing_cinematic:
		return

	var viewport = camera.get_viewport()
	var mouse_position = viewport.get_mouse_position() - viewport.size / 2.0
	var viewport_size = viewport.size / 2

	var desired_offset = Vector2(
		clamp(mouse_position.x / viewport_size.x, -1, 1) * max_offset.x,
		clamp(mouse_position.y / viewport_size.y, -1, 1) * max_offset.y
	)
	actual_offset = actual_offset.lerp(desired_offset, damping)

	# Add the calculated offset to the existing camera position
	camera._target_position += actual_offset
