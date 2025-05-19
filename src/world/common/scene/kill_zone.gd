extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(other: Node2D) -> void:
	if other.has_method("kill"):
		other.kill()
	else:
		printerr(other.name, " just fell past the kill zone. Freeing object...")
		other.queue_free()
