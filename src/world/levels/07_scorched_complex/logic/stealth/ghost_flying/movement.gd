extends CompoundState

var direction: int = 1

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
	_target.move_and_slide.call_deferred()


func _on_state_exited() -> void:
	pass

