extends Area2D

@export var knockback: Vector2 = Vector2(1024, -512)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(other: Node2D) -> void:
	if other is Boulder04:
		other.knockback = knockback
