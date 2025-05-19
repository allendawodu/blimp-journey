class_name PuckAI
extends Puck

## Large enough number of ticks for a "practical stop".
const MAX_TICKS: float = 360

static var goal: Vector2 = Vector2(960, 540)

@export var deviation: float = 200
@export var cooldown_min: float = 0.5
@export var cooldown_max: float = 3.0

var _rng: RandomNumberGenerator


func _ready() -> void:
	super()
	%CooldownTimer.start(randf())

	_rng = RandomNumberGenerator.new()
	_rng.randomize()


func _on_cooldown_timer_timeout() -> void:
	# Select a velocity with error (skewed like a bell curve)
	var initial_velocity: Vector2 = _calculate_initial_velocity()
	var error: Vector2 = Vector2(_rng.randfn(0, deviation), _rng.randfn(0, deviation))
	movement_multiplier = randf_range(1, 1.5)
	linear_velocity = (initial_velocity + error) * movement_multiplier
	
	%CooldownTimer.start(randf_range(cooldown_min, cooldown_max))


func _calculate_initial_velocity() -> Vector2:
	var distance = (goal - global_position).length()
	var damp_factor = 1 - linear_damp / Engine.physics_ticks_per_second
	var velocity_magnitude = distance * linear_damp / (1 - pow(damp_factor, MAX_TICKS))
	return (goal - global_position).normalized() * velocity_magnitude
