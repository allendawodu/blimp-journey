class_name HandDragComponent
extends Button

var is_dragging: bool
var _drag_offset: Vector2

@onready var _target: Node = get_owner()


func _ready() -> void:
	button_down.connect(_on_draggable_area_button_down)
	button_up.connect(_on_draggable_area_button_up)


func _process(delta: float) -> void:
	if is_dragging:
		_target.global_position.x = get_global_mouse_position().x - _drag_offset.x


func _on_draggable_area_button_down() -> void:
	is_dragging = true
	_drag_offset = get_global_mouse_position() - _target.global_position


func _on_draggable_area_button_up() -> void:
	is_dragging = false
