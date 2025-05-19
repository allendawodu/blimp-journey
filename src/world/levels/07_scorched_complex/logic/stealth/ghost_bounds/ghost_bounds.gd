extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(other: Node) -> void:
	if "GHOST" in other:
		other.turn_around()
