extends TextureRect

@export_range(0, 1, 0.01) var brush_speed: float = 0.2

@onready var drag_component: TextureButton = $DragComponent
@onready var brush_head: Node2D = $BrushHead


func _ready() -> void:
	$DragComponent.create_click_mask(texture)


func _process(delta: float) -> void:
	if $DragComponent.is_dragging:
		global_position = global_position.lerp(get_parent().global_position, brush_speed)
	else:
		global_position = global_position.lerp(Vector2(1664, 757), 0.1)
		get_parent().global_position = get_parent().global_position.lerp(Vector2(1624.0, 717.0), 0.1)
