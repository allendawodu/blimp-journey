extends Button

signal drag_started
signal drag_ended

var is_dragging: bool
var _drag_offset: Vector2

@export var target: Node


func _ready() -> void:
	button_down.connect(_on_draggable_area_button_down)
	button_up.connect(_on_draggable_area_button_up)

	if not is_instance_valid(target):
		printerr("[DragComponent] Target is not valid!")


func _process(delta: float) -> void:
	if is_dragging:
		target.global_position = get_global_mouse_position() - _drag_offset


func _on_draggable_area_button_down() -> void:
	is_dragging = true
	drag_started.emit()
	_drag_offset = get_global_mouse_position() - target.global_position


func _on_draggable_area_button_up() -> void:
	is_dragging = false
	drag_ended.emit()
