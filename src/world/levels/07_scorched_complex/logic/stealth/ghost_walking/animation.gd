extends CompoundState

var direction: int = 1

var _knockback_amount: float

@onready var _target: CharacterBody2D = get_owner()


func _ready() -> void:
	super()

	_knockback_amount = %KnockbackArea.knockback.x


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if not is_zero_approx(_target.velocity.x):
		direction = sign(_target.velocity.x)

		if %Visuals.scale.x != direction:
			%Visuals.scale.x = direction
		
		%KnockbackArea.knockback.x = direction * _knockback_amount
	
	if %KnockbackArea.has_overlapping_bodies():
		_chart.send_event("swat")


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	pass

