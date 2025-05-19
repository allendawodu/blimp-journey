class_name MovementStatePlayer
extends MovementState

const MOUSE_DISTANCE_MAX: float = 500
const DROP_ANGLE_MIN: float = 3 * PI / 8
const DROP_ANGLE_MAX: float = 5 * PI / 8
const JUMP_ZONE_Y: float = -216

var is_mouse_outside_character: bool = true
var is_mouse_in_jump_zone: bool
var is_mouse_in_drop_angle: bool
var is_pathfinding: bool

@onready var _platform_check_area: PlatformChecker = %PlatformCheckArea
@onready var _pathfinding: PathfindingState = %Pathfinding


func _ready() -> void:
	super()

	EventBus.about_to_resume.connect(_on_about_to_resume)

	_target.mouse_entered.connect(_on_target_mouse_entered)
	_target.mouse_exited.connect(_on_target_mouse_exited)


func _on_state_entered() -> void:
	super()


func _on_state_unhandled_input(event: InputEvent) -> void:
	super(event)
	
	if get_viewport().is_input_handled():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not _pathfinding.is_pathfinding:
		is_mouse_down = event.pressed


func _on_state_processing(delta: float) -> void:
	super(delta)

	# The mouse can change global position without moving,
	# so I need to track its position continuously
	if not _pathfinding.is_pathfinding:
		vector_to_mouse = _target.get_global_mouse_position() - _target.global_position
	
	is_mouse_in_jump_zone = vector_to_mouse.y < JUMP_ZONE_Y
	is_mouse_in_drop_angle = Maid.is_within(vector_to_mouse.angle(), DROP_ANGLE_MIN, DROP_ANGLE_MAX)

	# Drop in both grounded and airborne states
	if is_mouse_down and is_mouse_outside_character and is_mouse_in_drop_angle and _platform_check_area.is_on_platform:
		_platform_check_area.drop()


func _on_state_physics_processing(delta: float) -> void:
	super(delta)


func _on_state_exited() -> void:
	super()


func _on_target_mouse_entered() -> void:
	if not is_pathfinding:
		is_mouse_outside_character = false


func _on_target_mouse_exited() -> void:
	if not is_pathfinding:
		is_mouse_outside_character = true


func _on_about_to_resume(initiator: String) -> void:
	# Prevents bug when the mouse is down while pausing
	if not is_pathfinding:
		is_mouse_down = false
