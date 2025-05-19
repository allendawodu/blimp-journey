extends Node2D

const PUCK_AI: PackedScene = preload("res://src/world/levels/02_reality_tv/minigames/shuffleboard/puck_ai.tscn")

@export var num_ai: int = 7
@export var radius: float = 400


func _ready() -> void:
	for i: int in range(num_ai):
		var new_puck: PuckAI = PUCK_AI.instantiate()
		var angle: float = i * 2 * PI / (num_ai + 1)
		new_puck.position = Vector2(cos(angle), sin(angle)) * radius
		add_child(new_puck)
