class_name CardVisual
extends Node2D

@export_range(0, 1) var follow_damping: float = 0.2

var target: Card


func _ready() -> void:
	if target.data and target.data.texture:
		%ItemTexture.texture = target.data.texture


func _process(delta: float) -> void:
	if not is_instance_valid(target) or not is_instance_valid(self):
		queue_free()
		return
	
	# Don't lerp when the player is dragging
	if target.drag_component.is_dragging:
		global_position = target.global_position
	else:
		global_position = global_position.lerp(target.global_position, follow_damping)
