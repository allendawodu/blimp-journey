class_name AirborneState
extends CompoundState

@export var terminal_velocity: float = 4096
@export_range(0, 1) var drag: float = 0.5
@export var air_control_curve: Curve = preload("res://src/character/common/walk_speed_curve.tres")

var should_disable_air_control: bool

var _gravity: float
var _direction: int
var _max_speed: float
var _is_first_frame: bool
var _came_from_jump: bool

@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementState = %Movement
@onready var _jump: JumpState = %Jump
@onready var _pathfinding: PathfindingState = %Pathfinding


func _ready() -> void:
	super()

	%PreJump/OnNone.taken.connect(_on_pre_jump_on_none_taken)

	# Precalculate gravity using a projectile motion formula (g = 2h/t^2_apex)
	_gravity = 2 * _jump.jump_height_max / pow(_jump.time_to_apex, 2)


func _on_state_entered() -> void:
	_is_first_frame = true


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	# Give the target time to leave the ground by skipping the first physics frame
	if _target.is_on_floor() and not _is_first_frame:
		should_disable_air_control = false
		_chart.send_event("ground")

	if not should_disable_air_control:
		# Calculate horizontal movement in air
		if (AppSettings.is_drag_only_air_control_enabled() or _movement.is_mouse_down) or (_came_from_jump and _is_first_frame):
			_direction = roundi(_movement.vector_to_mouse.sign().x)		
			_max_speed = air_control_curve.sample_baked(absf(_movement.vector_to_mouse.x) / 1024)
		
		if (AppSettings.is_drag_only_air_control_enabled() or _movement.is_mouse_down) or _came_from_jump:
			# Apply air control
			_movement.horizontal_movement(_max_speed * _direction, drag)
		else:
			# Conserve the momentum they came into the state with and gradually come to a stop
			_movement.horizontal_movement(0, 0.01)

	# Apply gravity
	# The character won't jump high enough if gravity is applied on the first frame
	if not _is_first_frame:
		# Convert gravity from seconds to frames
		_target.velocity.y += _gravity * delta
		_target.velocity.y = minf(_target.velocity.y, terminal_velocity)
	
	_is_first_frame = false


func _on_state_exited() -> void:
	# Reset the state
	_came_from_jump = false
	_max_speed = 0
	should_disable_air_control = false


func _on_pre_jump_on_none_taken() -> void:
	_came_from_jump = true
