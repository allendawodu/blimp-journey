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
	if not is_zero_approx(_target.velocity.x):
		var face_origin: int = -sign(_target.global_position.x)
		var face_target: int = sign(_target.velocity.x)

		direction = face_target if %Pursue.active else face_origin

		if %Visuals.scale.x != direction:
			%Visuals.scale.x = direction


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	pass

