extends Node2D


func _ready() -> void:
	$Area2D.body_entered.connect(on_body_entered)


func on_body_entered(other: Node) -> void:
	if other is not Player:
		return
	
	show()
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
	$Area2D.set_deferred("monitoring", false)
