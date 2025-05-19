extends Node2D

const OFFSET: Vector2 = Vector2(108, 126)


func _process(delta: float) -> void:
	global_position = global_position.lerp(get_parent().global_position + OFFSET, 0.1)
