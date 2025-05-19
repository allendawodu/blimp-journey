class_name GroundedStatePlayer
extends GroundedState

const CROUCH_ANGLE_MIN: float = 3 * PI / 16
const CROUCH_ANGLE_MAX: float = 13 * PI / 16
const CHARACTER_WALK_BOUNDS: float = 60

var is_mouse_in_crouch_angle: bool

@onready var _movement: MovementStatePlayer = %Movement
@onready var _pathfinding: PathfindingState = %Pathfinding
@onready var _platform_check_area: PlatformChecker = %PlatformCheckArea


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	super()


func _on_state_unhandled_input(event: InputEvent) -> void:
	super(event)
	
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	is_mouse_in_crouch_angle = Maid.is_within(_movement.vector_to_mouse.angle(), CROUCH_ANGLE_MIN, CROUCH_ANGLE_MAX)
	
	if _movement.is_mouse_down:
		if _movement.is_mouse_in_jump_zone:
			_chart.send_event("jump")
		elif is_mouse_in_crouch_angle and not _platform_check_area.is_on_platform:
			_chart.send_event("crouch")
	else:
		if not _pathfinding.is_pathfinding:
			_chart.send_event("stop")


func _on_state_physics_processing(delta: float) -> void:
	super(delta)


func _on_state_exited() -> void:
	super()
