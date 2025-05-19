extends Area2D

@export var variable_name: String
@export var teleport_to: Vector2 = Vector2.ZERO


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(other: Node2D) -> void:
	if other is not Player:
		return

	if variable_name.is_empty():
		printerr("[Tutorial] variable_name is empty")
		return
	
	Dialogic.VAR["05"][variable_name] += 1
	
	other.velocity = Vector2.ZERO
	other._chart.send_event("ground")
	other.global_position = teleport_to
	other._chart.send_event("fall")
