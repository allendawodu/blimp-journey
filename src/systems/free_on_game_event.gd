@tool
class_name FreeOnGameEvent
extends Node

@export var game_event: String:
	set(value):
		game_event = value
		update_configuration_warnings()
@export var target: Node


func _ready() -> void:
	if Engine.is_editor_hint():
		if not is_instance_valid(target):
			target = get_parent()
		return
	
	EventBus.event_list_updated.connect(_on_event_list_updated)
	
	# Check for events from other scenes
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		_on_event_list_updated(level.completed_events)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if game_event.is_empty():
		warnings.append("No game event has been set.")
	
	return warnings


func _on_event_list_updated(events: Array[String]) -> void:
	if not game_event.is_empty() \
		and game_event in events \
		and is_instance_valid(target):
			target.queue_free()
