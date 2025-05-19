class_name Boulder04
extends RigidBody2D

var knockback: Vector2 = Vector2(1024, -512):
	set(value):
		$KnockbackArea.knockback = value


func _ready() -> void:
	$LifetimerTimer.timeout.connect(_on_lifetime_timer_timeout)
	$KnockbackArea.body_entered.connect(_on_body_entered)


func _on_lifetime_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		queue_free()
