@tool
extends AtomicState

@export var speed: float = 100
@export var seek_distance: float = 1000

var initial_position: Vector2

@onready var _target: CharacterBody2D = get_owner()


func _ready() -> void:
	super()

	initial_position = _target.global_position
	%PlayerChecker.target_position = Vector2(seek_distance, 0)


func _on_state_entered() -> void:
	await get_tree().create_timer(_target.walk_time).timeout

	if active:
		_chart.send_event("wait")


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	%PlayerChecker.target_position = Vector2(seek_distance, 0) * get_parent().direction

	if %PlayerChecker.is_colliding() and _target.get_node("%PlayerVisibility").is_player_visible:
		_chart.send_event("pursue")


func _on_state_physics_processing(delta: float) -> void:
	get_parent().move(speed)
	

func _on_state_exited() -> void:
	pass
