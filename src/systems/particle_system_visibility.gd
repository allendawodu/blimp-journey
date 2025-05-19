@tool
class_name ParticleSystemVisibility
extends Node2D

const MAX: float = 999999

@export var always_visible: bool: set = set_always_visible
@export var visibility_rect_size: Vector2: set = set_visibility_rect_size


func _get_configuration_warnings() -> PackedStringArray:
	if get_parent() is not GPUParticles2D:
		return ["Parent must be a GPUParticles2D or CPUParticles2D"]
	return []


func set_always_visible(value: bool) -> void:
	if not Engine.is_editor_hint():
		return
	
	always_visible = value
	if always_visible:
		get_parent().visibility_rect = Rect2(-MAX/2, -MAX/2, MAX, MAX)


func set_visibility_rect_size(value: Vector2) -> void:
	if not Engine.is_editor_hint():
		return
	
	visibility_rect_size = value
	if not always_visible:
		get_parent().visibility_rect = Rect2(position - visibility_rect_size/2, visibility_rect_size)
