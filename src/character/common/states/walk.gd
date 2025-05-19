class_name WalkState
extends AtomicState

const MOUSE_LENGTH_MAX: float = 1024

@export_range(0, 1) var acceleration: float = 0.1
@export var walk_speed_curve: Curve = preload("res://src/character/common/walk_speed_curve.tres")

var max_speed: float
var direction: int

@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementState = %Movement
@onready var _pathfinding: PathfindingState = %Pathfinding


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if _pathfinding.is_pathfinding:
		_movement.is_mouse_down = true

		var should_slow_for_jump = _pathfinding._path.size() > 1 and _pathfinding.current_point.local_position.y > _pathfinding._path[0].local_position.y
		var is_on_same_level = _pathfinding.previous_point and _pathfinding.previous_point.local_position.y == _pathfinding.current_point.local_position.y
		
		if is_on_same_level and not _pathfinding.is_current_point_last and not should_slow_for_jump:
			_movement.vector_to_mouse.x = roundi(signf(_pathfinding.current_point.global_position.x - _target.global_position.x)) * 512
		else:
			_movement.vector_to_mouse.x = _pathfinding.current_point.global_position.x - _target.global_position.x
		_movement.vector_to_mouse.y = 0


func _on_state_physics_processing(delta: float) -> void:
	if _pathfinding.is_pathfinding:
		_set_direction_and_speed()
	
	_movement.horizontal_movement(max_speed * direction, acceleration)


func _on_state_exited() -> void:
	pass


func _set_direction_and_speed() -> void:
	direction = roundi(_movement.vector_to_mouse.sign().x)
	max_speed = walk_speed_curve.sample_baked(absf(_movement.vector_to_mouse.x) / MOUSE_LENGTH_MAX)
