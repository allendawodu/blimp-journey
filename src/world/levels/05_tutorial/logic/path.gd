@tool
extends Path2D


func _ready() -> void:
	$Line2D.points = curve.tessellate_even_length()
