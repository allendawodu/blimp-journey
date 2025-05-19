extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(other: Node2D) -> void:
	if other is Player:
		Dialogic.signal_event.emit("death_by_falling")
