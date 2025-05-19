class_name KnockbackArea
extends Area2D

@export var knockback: Vector2 = Vector2(512, -1024)
## If true, the target's velocity won't affect the knockback direction.
@export var should_override_direction: bool


func _enter_tree() -> void:
	set_collision_layer_value(1, false)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		body.knockback(knockback, should_override_direction)
