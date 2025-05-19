class_name CrouchState
extends AtomicState

@export var friction: float = 0.05

@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementState = %Movement


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	_movement.horizontal_movement(0.0, friction)


func _on_state_exited() -> void:
	pass
