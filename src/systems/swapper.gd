@tool
class_name Swapper
extends Node

## scene: Node, event_name: String
@export var subscenes: Dictionary[Node, String]
		

func _ready() -> void:
	if Engine.is_editor_hint():
		child_entered_tree.connect(_on_child_entered_tree)
		child_exiting_tree.connect(_on_child_exiting_tree)

		for child: Node in get_children():
			if not subscenes.has(child):
				_on_child_entered_tree(child)
		
		return
	
	EventBus.event_list_updated.connect(_on_event_list_updated)

	for subscene: Node in subscenes.keys():
		if not subscene.has_method("hide"):
			continue
		subscene.hide()

	# Check for events from other scenes
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		_on_event_list_updated(level.completed_events)
	else:
		# Just get the starting subscene
		if not subscenes.is_empty():
			for event: String in subscenes.values():
				if event.ends_with("started"):
					swap_subscene(event)
					break

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if subscenes.is_empty():
		warnings.append("Subscenes list is not populated.")
	if subscenes.size() != get_child_count():
		warnings.append("Subscenes list size does not match the number of children.")
	if subscenes.keys().any(func(subscene): return not subscene is Node2D):
		warnings.append("Subscene(s) are not of type Node2D.")
	if subscenes.keys().any(func(subscene): return not subscene in get_children()):
		warnings.append("Subscene(s) are not children of this node.")
	if subscenes.values().any(func(event): return event.is_empty()):
		warnings.append("Event name(s) are empty.")
	
	return warnings


func swap_subscene(event: String) -> void:
	if not subscenes.values().has(event):
		printerr("[Swapper] No scene found for event: %s. Aborting..." % event)
		return

	for subscene: Node in subscenes.keys():
		if not subscene.has_method("hide"):
			continue
		subscene.hide()
	
	await get_tree().process_frame
	
	var subscene_to_show: Node = subscenes.find_key(event)
	if subscene_to_show.has_method("show"):
		subscene_to_show.show()


func _on_event_list_updated(events: Array[String]) -> void:
	var latest_event: String

	for event: String in events:
		if subscenes.values().has(event):
			latest_event = event
	
	if not latest_event.is_empty():
		swap_subscene(latest_event)


func _on_child_entered_tree(child: Node) -> void:
	if Engine.is_editor_hint() and not subscenes.has(child):
		subscenes[child] = ""


func _on_child_exiting_tree(child: Node) -> void:
	# Only erase the child if we're in the editor and it's being deleted
	if Engine.is_editor_hint() and child.is_queued_for_deletion():
		subscenes.erase(child)
