class_name PathfindingState
extends AtomicState

const MIN_DISTANCE_TO_POINT: float = 64

var previous_point: PathBuilder.Point
var current_point: PathBuilder.Point
var pathfind_target: Node2D
var is_pathfinding: bool
var has_reached_end_of_path: bool
var is_current_point_last: bool

var _path: Array[PathBuilder.Point]

@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementState = %Movement
@onready var _repathfind_timer: Timer = %RepathfindTimer
@onready var _platform_check_area: PlatformChecker = %PlatformCheckArea


func _ready() -> void:
	super()

	_repathfind_timer.timeout.connect(_on_repathfind_timer_timeout)


func _on_state_entered() -> void:
	if not is_instance_valid(_target.path_builder):
		push_error(owner.name, " cannot access PathBuilder.")
		_chart.send_event("stop")
		return
	
	is_pathfinding = true
	_repathfind_timer.start()


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if not is_instance_valid(current_point):
		return
	
	# Go to the next point when the character has reached the current point
	if _target.global_position.distance_to(current_point.global_position) < MIN_DISTANCE_TO_POINT and _target.is_on_floor():
		_next_point_in_path()


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	# Reset state
	previous_point = null
	current_point = null
	is_pathfinding = false
	pathfind_target = null
	_repathfind_timer.stop()
	_movement.is_mouse_down = false


## This method alone doesn't active pathfinding.
## Call `_chart.send_event("pathfind")` after this method.
func go_to_target(p_pathfind_target: Node2D = null) -> void:
	if not _is_target_valid(p_pathfind_target):
		return

	_path = _target.path_builder.get_platform_2d_path(_target.global_position, pathfind_target.global_position)

	_target.path_builder.draw_debug_path(_path)

	_next_point_in_path()


## This method alone doesn't active pathfinding.
## Call `_chart.send_event("pathfind")` after this method.
func go_to_position(position: Vector2) -> void:
	var target: Node2D = Node2D.new()
	target.global_position = position
	target.top_level = true
	add_child(target)
	go_to_target(target)


func _next_point_in_path() -> void:
	has_reached_end_of_path = false
	
	if _path.is_empty():
		has_reached_end_of_path = true
		_chart.send_event("stop")
		return
	
	previous_point = current_point
	current_point = _path.pop_front()

	is_current_point_last = _path.is_empty()

	# Here lies the logic that moves characters from point to point
	if _should_jump():
		_chart.send_event("jump")
	elif _should_drop():
		_platform_check_area.drop()
	else:
		_chart.send_event("move")


func _on_repathfind_timer_timeout() -> void:
	# Only recalculate the path if the character is stuck
	if absf(_target.velocity.x) < 10 and is_instance_valid(pathfind_target):
		previous_point = null
		current_point = null
		go_to_target()


func _is_target_valid(p_pathfind_target: Node2D) -> bool:
	if not is_instance_valid(pathfind_target) and not is_instance_valid(p_pathfind_target):
		push_error(owner.name, " has no target to go to.")
		return false
	
	if is_instance_valid(p_pathfind_target):
		pathfind_target = p_pathfind_target
	
	return true


func _should_jump() -> bool:
	return _target.is_on_floor() \
		and previous_point \
		and (previous_point.local_position.y > current_point.local_position.y \
		or _can_jump_from_left_edge_to_right_edge() \
		or _can_jump_from_right_edge_to_left_edge())


func _should_drop() -> bool:
	return previous_point \
		and current_point.properties.has(PathBuilder.Point.Property.IS_FALL_TILE) \
		and previous_point.local_position.y < current_point.local_position.y \
		and previous_point.local_position.x == current_point.local_position.x


func _can_jump_from_right_edge_to_left_edge() -> bool:
	return previous_point.properties.has(PathBuilder.Point.Property.IS_RIGHT_EDGE) and current_point.properties.has(PathBuilder.Point.Property.IS_LEFT_EDGE) \
		and previous_point.local_position.x < current_point.local_position.x \
		and previous_point.local_position.y >= current_point.local_position.y


func _can_jump_from_left_edge_to_right_edge() -> bool:
	return previous_point.properties.has(PathBuilder.Point.Property.IS_LEFT_EDGE) and current_point.properties.has(PathBuilder.Point.Property.IS_RIGHT_EDGE) \
		and previous_point.local_position.x > current_point.local_position.x \
		and previous_point.local_position.y >= current_point.local_position.y


func _can_jump_from_fall_tile_to_edge() -> bool:
	return previous_point.properties.has(PathBuilder.Point.Property.IS_FALL_TILE) \
		and current_point.has_any_property([PathBuilder.Point.Property.IS_LEFT_EDGE, PathBuilder.Point.Property.IS_RIGHT_EDGE]) \
		and previous_point.local_position.x == current_point.local_position.x
