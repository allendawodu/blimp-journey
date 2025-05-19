extends Node2D

const INTERACT_OFFSET: Vector2 = Vector2(100, 0)

@onready var player: Player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if is_instance_valid(player):
		# Set the offset based on the player's position
		$InteractableDialogue.player_interact_offset = INTERACT_OFFSET if player.global_position.x > global_position.x else -INTERACT_OFFSET
	else:
		# This is needed when the scene switches and the player is not in the group yet
		player = get_tree().get_first_node_in_group("player")
