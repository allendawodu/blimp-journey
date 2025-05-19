extends Node

const VISIBILITY_DISPLAY: PackedScene = preload("res://src/world/levels/07_scorched_complex/logic/stealth/player_visibility/visibility_display.tscn")
const HIDDEN_GRACE_PERIOD: float = 0.2  # 200ms grace period

var is_player_visible: bool
var num_pursuing_ghosts: int:
	set(value):
		num_pursuing_ghosts = max(value, 0)

var _hidden_grace_timer: float

@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	var visibility_display: TextureRect = VISIBILITY_DISPLAY.instantiate()
	visibility_display.player_visibility = self
	owner.get_node("UI").add_child(visibility_display)


func _process(delta: float) -> void:
	var in_crouch_hidden_area: bool = $CrouchHidden.has_overlapping_bodies()
	var is_crouching: bool = player.get_node("StateChart/Root/Movement/Grounded/Crouch").active
	var in_regular_hidden_area: bool = $Hidden.has_overlapping_bodies()
	
	# If player was recently in a hidden area, maintain the hidden state during transitions
	if in_regular_hidden_area:
		_hidden_grace_timer = HIDDEN_GRACE_PERIOD
	elif _hidden_grace_timer > 0:
		_hidden_grace_timer -= delta
	
	# Player is invisible if they're crouching in a crouch hidden area OR in a regular hidden area
	# OR during the grace period after leaving a hidden area
	is_player_visible = not ((in_crouch_hidden_area and is_crouching) or in_regular_hidden_area or _hidden_grace_timer > 0)
