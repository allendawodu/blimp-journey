extends AtomicState

var _initial_position: Vector2

@onready var _target: CharacterBody2D = get_owner()


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	_initial_position = _target.global_position



func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	var attractor: Vector2 = _initial_position -_target.global_position
	_target.velocity = _target.velocity.lerp(attractor, 0.1)
	
	# Clamp only the magnitude of the velocity vector
	if _target.velocity.length() > _target.max_speed:
		_target.velocity = _target.velocity.normalized() * _target.max_speed


func _on_state_exited() -> void:
	pass

