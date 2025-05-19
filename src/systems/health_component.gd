@tool
class_name HealthComponent
extends Node

signal damaged

@export var target: Node
@export var max_health: float = 100

@onready var health: float = max_health:
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			kill()

var _is_dead: bool


func _ready() -> void:
	if target == null:
		target = get_parent()


func damage(amount: float) -> void:
	health -= amount
	damaged.emit()


func heal(amount: float) -> void:
	health += amount


func kill() -> void:
	if _is_dead:
		return

	_is_dead = true

	if target.has_method("kill"):
		target.kill()
	else:
		target.queue_free()
