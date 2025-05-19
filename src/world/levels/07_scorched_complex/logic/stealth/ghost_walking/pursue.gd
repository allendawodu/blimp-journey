extends AtomicState

@export var speed: float = 300

@onready var _target: CharacterBody2D = get_owner()
@onready var _player: Player = get_tree().get_first_node_in_group("player")
@onready var _level: Level = get_tree().get_first_node_in_group("level")
@onready var _player_visibility: Node = _target.get_node("%PlayerVisibility")


func _ready() -> void:
	super()

	_target.tree_exiting.connect(_on_state_exited)


func _on_state_entered() -> void:
	_player_visibility.num_pursuing_ghosts += 1


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	get_parent().direction = signf(_player.global_position.x - _target.global_position.x)
	get_parent().move(speed)

	var distance_to_player: float = _player.global_position.distance_to(_target.global_position)
	if distance_to_player < 100:
		if _player_visibility.is_player_visible:
			Dialogic.end_timeline.call_deferred()
			Dialogic.VAR["07"]["num_screams"] += 1
			
			if _level and _level.scene.scene_name == "roof":
				_player.get_node("HealthComponent").damage(30)
				_chart.send_event("wait")
			else:
				Dialogic.signal_event.emit("death_by_walking_ghost")
				_toggle_processing(false)  # Prevent reloading the scene multiple times
		else:
			_chart.send_event("wait")


func _on_state_exited() -> void:
	_player_visibility.num_pursuing_ghosts -= 1
