extends RigidBody2D

var knockback: Vector2 = Vector2(1024, -512):
	set(value):
		$KnockbackArea.knockback = value


func _ready() -> void:
	$LifetimerTimer.timeout.connect(_on_lifetime_timer_timeout)


func _on_lifetime_timer_timeout() -> void:
	queue_free()
