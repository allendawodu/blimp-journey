class_name Exclamation
extends Label

var time: float


func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)


func _process(delta: float) -> void:
	time += delta
	scale = Vector2.ONE * (0.33 * sin(5 * time) + 1.25)


func _on_timer_timeout() -> void:
	queue_free()
