extends Area2D

@export var teleport_to: Vector2 = Vector2.ZERO

var player: Player


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	if is_zero_approx(player.velocity.y):
		player.velocity = Vector2.ZERO
		player._chart.send_event("ground")
		player.global_position = teleport_to
		player._chart.send_event("fall")


func _on_body_entered(other: Node2D) -> void:
	if other is not Player:
		return
	
	player = other


func _on_body_exited(other: Node2D) -> void:
	if other is not Player:
		return
	
	player = null
