class_name WalkStatePlayer
extends WalkState

@onready var _grounded: GroundedState = %Grounded


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


func _on_state_physics_processing(delta: float) -> void:
	if absf(_movement.vector_to_mouse.x) > _grounded.CHARACTER_WALK_BOUNDS or _pathfinding.is_pathfinding:
		_set_direction_and_speed()
	# Prevents the character from jittering when the mouse can quickly flip signs (near `mouse_x == 0`)
	elif direction != roundi(_movement.vector_to_mouse.sign().x) and not _pathfinding.is_pathfinding:
		_chart.send_event("stop")
	
	_movement.horizontal_movement(max_speed * direction, acceleration)


func _on_state_exited() -> void:
	super()

