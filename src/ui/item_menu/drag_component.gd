@tool
class_name DragComponent
extends TextureButton

signal drag_started
signal drag_ended

@export var target: Control

var is_dragging: bool
var _drag_offset: Vector2


func _ready() -> void:
	if Engine.is_editor_hint():
		if not is_instance_valid(target):
			target = get_parent()
		return
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_dragging:
		target.global_position = get_global_mouse_position() - _drag_offset


func create_click_mask(texture_for_click_mask: Texture2D) -> void:
	var bitmap: BitMap = BitMap.new()
	bitmap.create_from_image_alpha(texture_for_click_mask.get_image())
	texture_click_mask = bitmap


func _on_button_down() -> void:
	is_dragging = true
	_drag_offset = get_global_mouse_position() - target.global_position
	drag_started.emit()


func _on_button_up() -> void:
	is_dragging = false
	_drag_offset = Vector2.ZERO
	drag_ended.emit()
