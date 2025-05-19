extends KnockbackArea

@export var knockback_delay: float = 0.1

func _on_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(knockback_delay).timeout
	super(body)
