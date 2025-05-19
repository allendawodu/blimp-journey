extends TextureRect

@export var texture_hidden: Texture2D
@export var texture_visible: Texture2D
@export var texture_panic: Texture2D


var player_visibility: Node


func _ready() -> void:
	var level: Level = get_tree().get_first_node_in_group("level")
	if level and level.scene.scene_name == "roof":
		hide()


func _process(delta: float) -> void:
	if is_instance_valid(player_visibility):
		if player_visibility.num_pursuing_ghosts > 0:
			texture = texture_panic
		else:
			texture = texture_visible if player_visibility.is_player_visible else texture_hidden
