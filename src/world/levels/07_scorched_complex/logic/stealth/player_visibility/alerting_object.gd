@tool
extends Area2D

@export_range(0, 4096, 1) var alert_radius: float = 700:
	set(value):
		value = max(value, 0)
		$CollisionShape2D.shape.radius = value
		alert_radius = value

var nearby_ghosts: Array[CharacterBody2D]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func alert() -> void:
	for ghost in nearby_ghosts:
		if is_instance_valid(ghost):
			ghost.alert()


func _on_body_entered(other: Node) -> void:
	if "GHOST" in other:
		nearby_ghosts.append(other)


func _on_body_exited(other: Node) -> void:
	if "GHOST" in other:
		nearby_ghosts.erase(other)
