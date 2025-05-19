@tool
extends Node

@export var target: Node
@export_range(0, 60, 1, "or_greater") var max_lifetime: float = 10


func _ready() -> void:
	if target == null:
		target = get_parent()
	
	if Engine.is_editor_hint():
		return
	
	await get_tree().create_timer(max_lifetime).timeout
	target.queue_free()
