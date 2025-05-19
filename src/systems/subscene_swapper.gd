class_name SubsceneSwapper
extends Node
## @deprecated: Use Swapper instead.

## event_name: String, scene: PackedScene
@export var subscenes: Dictionary[String, PackedScene]


func _ready() -> void:
	EventBus.event_list_updated.connect(_on_event_list_updated)

	# Check for events from other scenes
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		_on_event_list_updated(level.completed_events)
	else:
		# Just get the starting subscene
		if not subscenes.is_empty():
			for key: String in subscenes.keys():
				if key.ends_with("started"):
					swap_subscene(key)
					break


func swap_subscene(event: String) -> void:
	get_children().map(func(child): child.queue_free())

	if not subscenes.has(event):
		printerr("[SubsceneSwapper] No scene found for event: %s. Aborting..." % event)
		return
	
	await get_tree().process_frame
	
	var new_subscene: Node = subscenes[event].instantiate()
	add_child(new_subscene)


func _on_event_list_updated(events: Array[String]) -> void:
	var latest_event: String

	for event: String in events:
		if subscenes.has(event):
			latest_event = event
	
	if not latest_event.is_empty():
		swap_subscene(latest_event)
