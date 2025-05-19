class_name MovementState
extends CompoundState

var vector_to_mouse: Vector2
var is_mouse_down: bool

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
	# Move the body after all states are done processing physics
	_target.move_and_slide.call_deferred()

	# Allowing pushing RigidBody2D
	# FIXME: It's not smooth and sometimes the tilemap ensnares the object
	for i in _target.get_slide_collision_count():
		var collision: KinematicCollision2D = _target.get_slide_collision(i)
		var body: Object = collision.get_collider()
		if body is RigidBody2D:
			body.apply_central_force(-collision.get_normal() * 5000 + Vector2(0, -1000))


func _on_state_exited() -> void:
	pass


func horizontal_movement(to: float, weight: float) -> void:
	_target.velocity.x = lerpf(_target.velocity.x, to, weight)
