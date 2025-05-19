extends AtomicState

@onready var _target: NPC = get_owner()
@onready var _pathfinding: PathfindingState = %Pathfinding
@onready var _pathfind_timer: Timer = %PathfindTimer

@onready var _initial_x: float = _target.global_position.x


func _ready() -> void:
	super()

	_pathfind_timer.timeout.connect(_on_pathfind_timer_timeout)
	
	_restart_timer()


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	pass


func _on_pathfind_timer_timeout() -> void:
	_restart_timer()
	# Wandering
	_pathfinding.go_to_position(Vector2(_initial_x + _target.wander_distance_max * randf_range(-1, 1), _target.global_position.y))
	_chart.send_event("pathfind")


func _restart_timer() -> void:
	# Only wander if the wander distance is >0
	if not is_zero_approx(_target.wander_distance_max):
		_pathfind_timer.start(randf_range(_target.wander_delay_min, _target.wander_delay_max))
	else:
		_pathfind_timer.stop()
