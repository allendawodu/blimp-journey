extends Node2D

const BOULDER: PackedScene = preload("res://src/world/levels/06_dragons_claw/logic/boulder/boulder.tscn")


func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)


func disable() -> void:
	$Timer.stop()


func _on_timer_timeout() -> void:
	var new_boulder = BOULDER.instantiate()
	new_boulder.global_position = global_position
	get_parent().add_child(new_boulder)
