extends AtomicState

@onready var _target: CharacterBody2D = get_owner()
@onready var _pathfinding: PathfindingStatePlayer = %Pathfinding


func _ready() -> void:
	super()


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# TODO: Create these via go_to_target and clean them up when used
		var target: Node2D = Node2D.new()
		target.global_position = _target.get_global_mouse_position()
		target.top_level = true
		add_child(target)
		_pathfinding.go_to_target(target)
		_chart.send_event("pathfind")


func _on_state_processing(delta: float) -> void:
	pass


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	pass

