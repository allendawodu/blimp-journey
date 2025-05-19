extends Node

@export var disable_with_game_event: String
## Leave empty to default to disabling all children.
@export var obstacles: Array[Node]


func _ready() -> void:
	EventBus.event_list_updated.connect(_on_event_list_updated)

	if obstacles.is_empty():
		obstacles = get_children()
	
	# Update based on events from other scenes
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		_on_event_list_updated(level.completed_events)


func disable_all(what: Array[Node]) -> void:
	for obstacle: Node in what:
		if obstacle.has_method("disable"):
			obstacle.disable()


func _on_event_list_updated(events: Array[String]) -> void:
	if not disable_with_game_event.is_empty() and disable_with_game_event in events:
		disable_all(obstacles)
