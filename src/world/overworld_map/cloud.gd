class_name Cloud
extends Sprite2D

const OFFSET: float = 600

@export_range(0, 1) var speed_shake: float = 0.001
@export_range(0, 1) var speed_reset: float = 0.01

@onready var start_position: Vector2 = position


func _process(delta: float) -> void:
	if $Area2D.has_overlapping_areas():
		position = position.lerp(position + Vector2(randf_range(-OFFSET, OFFSET), randf_range(-OFFSET, OFFSET)), speed_shake)
	else:
		position = position.lerp(start_position, speed_reset)
