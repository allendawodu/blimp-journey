extends Node2D

@onready var timer: Timer = %CombatTimer


func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	visible = not timer.is_stopped()
	$Area2D.monitoring = not timer.is_stopped()


func _on_body_entered(body: Node) -> void:
	if body is not Player:
		return
	
	var player: Player = body as Player

	get_tree().call_group("dragon_spirits", "queue_free")
	player.global_position = Vector2.ZERO
	timer.start()
