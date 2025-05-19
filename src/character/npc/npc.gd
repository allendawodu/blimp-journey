@tool
class_name NPC
extends Character

## Set this to 0 to prevent the NPC from wandering.
@export var wander_distance_max: float = 200:
	set(value):
		wander_distance_max = value
		queue_redraw()
@export var wander_delay_min: float = 1
@export var wander_delay_max: float = 5

@onready var _pathfind_possible: PathfindPossibleStateHijacker = %PathfindPossibleHijacker


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2(-wander_distance_max, 0), Vector2(wander_distance_max, 0), Color.WHITE)


## Prevent user input/actions from inhibiting pathfinding.
func ignore_user_and_pathfind() -> void:
	super()
	_pathfind_possible.should_ignore_reasons = true
