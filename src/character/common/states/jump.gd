class_name JumpState
extends AtomicState

const PATHFIND_JUMP_OFFSET: Vector2 = Vector2(0, 24)

@export_range(0, 1) var ledge_snap_smoothing: float = 0.3
# FIXME: These two values should come from the jump height curve
@export var jump_height_max: float = 512
@export var jump_height_min: float = 256
@export var time_to_apex: float = 38 / 60.0
@export var jump_height_curve: Curve = preload("res://src/character/common/jump_height_curve.tres")

var _pathfind_jump_velocity_x: float

@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementState = %Movement
@onready var _ledge_snap_ray: RayCast2D = %LedgeSnapRay
@onready var _pathfinding: PathfindingState = %Pathfinding


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	# Calculate the jump velocity
	if _pathfinding.is_pathfinding:
		%Airborne.should_disable_air_control = true
		var target_position: Vector2 = _pathfinding.current_point.global_position + PATHFIND_JUMP_OFFSET

		_target.velocity.y = _calculate_jump_velocity_y(target_position)
		# Slightly increase the x velocity to prevent the target from missing jumps
		_pathfind_jump_velocity_x = _calculate_jump_velocity_x(target_position) * 1.01
		_target.velocity.x = _pathfind_jump_velocity_x
		_movement.vector_to_mouse.x = sign(_target.velocity.x)


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	# Preserve the x velocity when pathfinding
	if _pathfinding.is_pathfinding:
		_target.velocity.x = _pathfind_jump_velocity_x
		
	if _target.velocity.y >= 0:
		# Ledge snap
		if _ledge_snap_ray.is_colliding():
			# Make ledge snap more consistent by preventing the target from slipping
			_target.velocity.y = 0
			_target.global_position.y = lerpf(_target.global_position.y, _target.global_position.y - _ledge_snap_ray.target_position.y, ledge_snap_smoothing)
		else:
			_chart.send_event("fall")


func _on_state_exited() -> void:
	pass


## Use a projectile motion formula to calculate the y component of the jump velocity.
func _calculate_jump_velocity_y(to: Vector2) -> float:
	var height_diff = to.y - _target.global_position.y
	var jump_height: float = jump_height_curve.sample(-height_diff / 800)
	var gravity = 2 * jump_height / pow(time_to_apex, 2)
	
	return -gravity * time_to_apex


func _calculate_jump_velocity_x(to: Vector2) -> float:
	var distance_x = to.x - _target.global_position.x  # dx
	var velocity_x = distance_x / time_to_apex         # dx/t
	return velocity_x
