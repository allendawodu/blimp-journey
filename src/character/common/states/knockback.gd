class_name KnockbackState
extends AtomicState

const DEFAULT_KNOCKBACK: Vector2 = Vector2(512, -1024)

var knockback: Vector2 = DEFAULT_KNOCKBACK
## If true, the target's velocity won't affect the knockback direction.
var should_override_direction: bool

@onready var _target: CharacterBody2D = get_owner()
@onready var _airborne: AirborneState = %Airborne


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	# Disable air control while in knockback
	_airborne.should_disable_air_control = true

	# Apply knockback
	if not should_override_direction:
		knockback = Vector2(-signf(_target.velocity.x) * knockback.x, knockback.y)
	
	_target.velocity = knockback


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	knockback = DEFAULT_KNOCKBACK
	should_override_direction = false
