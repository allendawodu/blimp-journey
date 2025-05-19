extends RigidBody2D

var damage: float = 100


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	await get_tree().create_timer(0.05).timeout

	$WaterVisual.show()


func _on_body_entered(other: Node) -> void:
	$WaterVisual.hide()
	$WaterImpactSplash.emitting = true

	if is_instance_valid(other) and "GHOST" in other:
		other.health_component.damage(damage)
	
	await $WaterImpactSplash.finished
	queue_free()
