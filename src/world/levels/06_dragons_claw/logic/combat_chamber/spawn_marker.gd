@tool
extends Marker2D

@export var arrow_length: float = 100
@export var head_size: float = 10


func _draw() -> void:
	# Draw arrow
    if Engine.is_editor_hint():
        # Draw the main line
        draw_line(Vector2.ZERO, Vector2.RIGHT * arrow_length, Color.WHITE)
        
        # Draw the arrow head using two simple lines
        var arrow_tip = Vector2.RIGHT * arrow_length
        var head_point1 = arrow_tip - Vector2(head_size, head_size)
        var head_point2 = arrow_tip - Vector2(head_size, -head_size)
        
        draw_line(arrow_tip, head_point1, Color.WHITE)
        draw_line(arrow_tip, head_point2, Color.WHITE)

