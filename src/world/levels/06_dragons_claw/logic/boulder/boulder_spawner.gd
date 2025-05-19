extends Node2D

const BOULDER: PackedScene = preload("res://src/world/levels/06_dragons_claw/logic/boulder/boulder.tscn")

@export var linear_velocity: Vector2 = Vector2(2100, 0)
@export var angular_velocity: float = 10
@export var constant_force: Vector2 = Vector2(1000, 0)
@export var constant_torque: float = 100
@export var knockback: Vector2 = Vector2(1500, -512)
@export var should_override_direction: bool = true


func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)


func disable() -> void:
	$Timer.stop()


func _on_timer_timeout() -> void:
	var new_boulder = BOULDER.instantiate()
	new_boulder.global_position = global_position
	new_boulder.linear_velocity = linear_velocity
	new_boulder.angular_velocity = angular_velocity
	new_boulder.constant_force = constant_force
	new_boulder.constant_torque = constant_torque
	new_boulder.get_node("KnockbackArea").knockback = knockback
	new_boulder.get_node("KnockbackArea").should_override_direction = should_override_direction
	get_parent().add_child(new_boulder)
