class_name PuckPlayer
extends Puck

const MOVING_THRESHOLD: float = 10

var vector_to_mouse: Vector2
var can_move: bool


func _unhandled_input(event: InputEvent) -> void:
	if can_move and Maid.is_left_click(event):
		can_move = false
		%CooldownTimer.start()
		linear_velocity = vector_to_mouse * movement_multiplier


func _process(delta: float) -> void:
	vector_to_mouse = get_global_mouse_position() - global_position


func _physics_process(delta: float) -> void:
	if linear_velocity.length() < MOVING_THRESHOLD:
		can_move = true


func _on_cooldown_timer_timeout() -> void:
	can_move = true
