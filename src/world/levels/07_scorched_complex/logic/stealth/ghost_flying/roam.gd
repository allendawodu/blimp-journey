extends AtomicState

@export var jerkiness: float = 500
@export var attractor_strength: float = 0.1
@export var smoothing: float = 0.1

var _initial_position: Vector2

@onready var _target: CharacterBody2D = get_owner()


func _ready() -> void:
	super()

	_initial_position = _target.global_position


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if %PlayerChecker.has_overlapping_bodies() and _target.get_node("%PlayerVisibility").is_player_visible:
		_chart.send_event("pursue")


func _on_state_physics_processing(delta: float) -> void:
	var random_direction: Vector2 = Vector2(randf_range(-jerkiness, jerkiness), randf_range(-jerkiness, jerkiness))
	var attractor: Vector2 = (_target.global_position - _initial_position) * attractor_strength
	_target.velocity = _target.velocity.lerp(_target.velocity + random_direction - attractor, smoothing)
	
	# Clamp only the magnitude of the velocity vector
	if _target.velocity.length() > _target.max_speed:
		_target.velocity = _target.velocity.normalized() * _target.max_speed


func _on_state_exited() -> void:
	pass
