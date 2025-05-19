extends Area2D

@export var event: String


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(other: Node2D) -> void:
	if other is not Player:
		return

	if event.is_empty():
		printerr("[Tutorial] event is empty")
		return
	
	SaverLoader.complete_event(event)
	queue_free()
