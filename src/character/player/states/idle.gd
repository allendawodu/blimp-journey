extends IdleState

@export_range(0, 1) var prejump_friction: float = 0.02

@onready var _grounded: GroundedStatePlayer = %Grounded


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	super()


func _on_state_unhandled_input(event: InputEvent) -> void:
	super(event)
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if _movement.is_mouse_down and absf(_movement.vector_to_mouse.x) > _grounded.CHARACTER_WALK_BOUNDS:
		_chart.send_event("move")


func _on_state_physics_processing(delta: float) -> void:
	if _movement.is_mouse_down and _movement.is_mouse_in_jump_zone:
		_movement.horizontal_movement(0.0, prejump_friction)
	else:
		_movement.horizontal_movement(0.0, friction)

		_anti_ledge_slip()


func _on_state_exited() -> void:
	super()


func _on_airborne_on_ground_taken() -> void:
	super()
