extends ProgressBar

@onready var _player: Player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	value = _player.get_node("HealthComponent").health
