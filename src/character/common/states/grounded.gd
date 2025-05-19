class_name GroundedState
extends CompoundState

@onready var _target: CharacterBody2D = get_owner()


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
	if not _target.is_on_floor():
		_chart.send_event("fall")


func _on_state_exited() -> void:
	pass

