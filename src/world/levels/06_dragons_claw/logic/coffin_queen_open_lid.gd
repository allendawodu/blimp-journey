extends Sprite2D

func _ready() -> void:
	EventBus.event_list_updated.connect(_on_event_list_updated)


func _on_event_list_updated(events: Array[String]) -> void:
	if events.back() == "06_artifact_taken":
		position.x -= 100
