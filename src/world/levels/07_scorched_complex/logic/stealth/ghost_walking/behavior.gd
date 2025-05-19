extends CompoundState

@export var smoothing: float = 0.1

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
	_target.velocity.y = 100 * delta
	_target.move_and_slide.call_deferred()


func _on_state_exited() -> void:
	pass


func move(speed: float) -> void:
	_target.velocity.x = lerpf(_target.velocity.x, speed * direction * 60 * get_physics_process_delta_time(), smoothing)
