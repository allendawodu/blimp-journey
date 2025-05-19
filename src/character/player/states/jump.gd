class_name JumpStatePlayer
extends JumpState

const PRECISION_JUMP: PackedScene = preload("res://src/character/player/precision_jump/precision_jump.tscn")

## Debug variable.
var _initial_y: float


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	super()
	
	# Calculate the jump (y-axis) velocity
	if not _pathfinding.is_pathfinding:
		_target.velocity.y = _calculate_jump_velocity_y(_target.get_global_mouse_position())

		if not _movement.is_mouse_down:
			var precision_jump: PrecisionJump = PRECISION_JUMP.instantiate()
			precision_jump.target = _target as Player
			precision_jump.global_position = _target.get_global_mouse_position()
			precision_jump.top_level = true
			_target.add_child(precision_jump)

	# DEBUG
	# _initial_y = _target.global_position.y


func _on_state_unhandled_input(event: InputEvent) -> void:
	super(event)
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	super(delta)


func _on_state_physics_processing(delta: float) -> void:
	super(delta)


func _on_state_exited() -> void:
	super()

	# DEBUG
	# prints("Jump height:", _target.global_position.y - _initial_y)
