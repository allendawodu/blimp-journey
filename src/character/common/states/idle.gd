class_name IdleState
extends AtomicState

@export_range(0, 1) var friction: float = 0.2

var _came_from_airborne: bool

@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementState = %Movement
@onready var _ledge_rays: Node2D = %AntiLedgeSlip


func _ready() -> void:
	super()

	%Airborne/OnGround.taken.connect(_on_airborne_on_ground_taken)


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if _movement.is_mouse_down:
		_chart.send_event("move")


func _on_state_physics_processing(delta: float) -> void:
	_movement.horizontal_movement(0.0, friction)

	_anti_ledge_slip()

	
func _on_state_exited() -> void:
	# Reset state
	_came_from_airborne = false


## Add variable friction if the player character is going to slip off the edge
func _anti_ledge_slip() -> void:
	if not _came_from_airborne:
		return

	# NOTE: I could also use the velocity of the player to determine which ray to check
	var ray_l: RayCast2D = _ledge_rays.get_child(0)
	var ray_r: RayCast2D = _ledge_rays.get_child(1)
	
	# Ignore collisions that aren't at the edge of a series of tiles
	# FIXME: Rays only collide with platform tiles, not the ground 
	if ray_l.is_colliding() and not is_zero_approx(ray_l.get_collision_point().x - ray_l.global_position.x):
		var ledge_friction: float = remap(ray_l.get_collision_point().x - ray_l.global_position.x, 0, 90, 0, 1)
		_movement.horizontal_movement(0.0, ledge_friction)
	if ray_r.is_colliding() and not is_zero_approx(ray_r.global_position.x - ray_r.get_collision_point().x):
		var ledge_friction: float = remap(ray_r.global_position.x - ray_r.get_collision_point().x, 0, 90, 0, 1)
		_movement.horizontal_movement(0.0, ledge_friction)


func _on_airborne_on_ground_taken() -> void:
	_came_from_airborne = true
