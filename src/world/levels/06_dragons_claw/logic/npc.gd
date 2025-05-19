extends NPC

var player: Player
var previous_player_position: Vector2


func _ready() -> void:
	super()

	Dialogic.signal_event.connect(_on_dialogic_signal_event)

	$ReRePathfindTimer.timeout.connect(_on_rerepathfind_timer_timeout)

	# Hide covered body parts
	%Body/Torso.self_modulate = Color.TRANSPARENT
	%Body/LegR.self_modulate = Color.TRANSPARENT
	%Body/LegL.self_modulate = Color.TRANSPARENT
	
	var level: Level = get_tree().get_first_node_in_group("level")
	
	# DEBUG
	# Dialogic.VAR["06"]["is_following_player"] = true
	# _on_dialogic_signal_event("pathfind_to_player")
	# if level:
	# 	level.completed_events.append("06_combat_ended")
	
	if level and level.completed_events.has("06_combat_ended"):
		Dialogic.VAR["06"]["is_following_player"] = true
		$ReRePathfindTimer.start()
		show()

	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")
	
	await get_tree().process_frame

	if is_instance_valid(player) and Dialogic.VAR["06"]["is_following_player"]:
		global_position = player.global_position + Vector2(100, 0)

	if level:
		if level.scene.scene_name == "queens_chamber" and not level.completed_events.has("06_combat_ended"):
			queue_free()
		elif level.completed_events.has("06_escape_sequence_completed"):
			queue_free()


func pathfind_to_player() -> void:
	if not Dialogic.VAR["06"]["is_following_player"]:
		$ReRePathfindTimer.stop()
		return
	
	player = get_tree().get_first_node_in_group("player")
	
	if not is_instance_valid(player):
		return
	
	if global_position.distance_to(player.global_position) > 200:
		var direction_to_player = (player.global_position - global_position).normalized()
		var target_position = player.global_position - direction_to_player * 100
		
		previous_player_position = player.global_position
		
		%Pathfinding.go_to_position(target_position)

		# Prevents the NPC from looking like its glitching when following the player
		if %Pathfinding._path.size() > 2:
			%Pathfinding._next_point_in_path()
			%Pathfinding._next_point_in_path()
		
		_chart.send_event("pathfind")


func _on_rerepathfind_timer_timeout() -> void:
	if not is_instance_valid(player):
		return
	
	# Teleport to player if too far away
	if global_position.distance_to(player.global_position) > 2000:
		global_position = player.global_position
	elif not previous_player_position.is_equal_approx(player.global_position):
		pathfind_to_player()


func _on_dialogic_signal_event(event: Variant) -> void:
	if event == "pathfind_to_player":
		pathfind_to_player()
		$ReRePathfindTimer.start()
