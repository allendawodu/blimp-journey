extends AtomicState

@onready var _target: CharacterBody2D = get_owner()


func _ready() -> void:
	super()

	%Pursue/ToWait.taken.connect(_on_pursue_to_wait_taken)


func _on_state_entered() -> void:
	get_parent().direction *= -1


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	get_parent().move(0)


func _on_state_exited() -> void:
	pass


func _on_pursue_to_wait_taken() -> void:
	# Flip direction twice to make the ghost continue moving in the same direction
	# This may cause animation problems, if so, use transitions to change directions, not state_entered
	get_parent().direction *= -1
