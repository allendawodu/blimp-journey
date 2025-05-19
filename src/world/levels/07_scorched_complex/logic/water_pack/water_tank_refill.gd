extends GPUParticles2D


@onready var player: Player = get_tree().get_first_node_in_group("player")

	
func _process(delta: float) -> void:
	if is_instance_valid(player) and $Area2D.overlaps_body(player):
		var water_pack = player.get_node_or_null("WaterPack")
		if is_instance_valid(water_pack):
			water_pack.refill_tank()
