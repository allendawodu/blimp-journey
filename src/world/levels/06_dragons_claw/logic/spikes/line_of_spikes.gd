@tool
extends Path2D


func _ready() -> void:
	var points: PackedVector2Array = curve.tessellate_even_length(2, 100)
