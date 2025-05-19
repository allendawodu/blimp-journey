class_name PathfindingStatePlayer
extends PathfindingState


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	super()


func _on_state_unhandled_input(event: InputEvent) -> void:
	super(event)

	if get_viewport().is_input_handled():
		return
	
	if Maid.is_left_click(event):
		print("Pathfind aborted.")
		EventBus.pathfind_aborted.emit(pathfind_target)
		_chart.send_event("stop")


func _on_state_processing(delta: float) -> void:
	super(delta)


func _on_state_physics_processing(delta: float) -> void:
	super(delta)


func _on_state_exited() -> void:
	super()


func go_to_target(p_pathfind_target: Node2D = null) -> void:
	if not _is_target_valid(p_pathfind_target):
		return

	var target_offset: Vector2 = Vector2.ZERO if pathfind_target is not Interactable else pathfind_target.player_interact_offset
	_path = _target.path_builder.get_platform_2d_path(_target.global_position, pathfind_target.global_position + target_offset)

	# DEBUG
	# var text: String = "Path: "
	# for point: PathBuilder.Point in _path:
	# 	text += str(point.id) + " "
	# text += "\n---"
	# print(text)

	_target.path_builder.draw_debug_path(_path)
	_next_point_in_path()


func _next_point_in_path() -> void:
	super()

	# DEBUG
	# if previous_point:
	# 	prints(previous_point.id, "->", current_point.id)
	# else:
	# 	prints("->", current_point.id)
