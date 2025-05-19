extends CrouchState

const UNCROUCH_ANGLE_MIN: float = PI / 8
const UNCROUCH_ANGLE_MAX: float = 7 * PI / 8


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	super()


func _on_state_unhandled_input(event: InputEvent) -> void:
	super(event)
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	super(delta)

	# The crouch angle here is different from the actual crouch angle so as to not switch states when the cursor is at the angle edge
	if _movement.is_mouse_down and not Maid.is_within(_movement.vector_to_mouse.angle(), UNCROUCH_ANGLE_MIN, UNCROUCH_ANGLE_MAX):
		_chart.send_event("move")


func _on_state_physics_processing(delta: float) -> void:
	super(delta)


func _on_state_exited() -> void:
	super()

