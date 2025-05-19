extends Panel

const SCORECARD: PackedScene = preload("res://src/world/levels/02_reality_tv/minigames/shuffleboard/scorecard.tscn")
const SCORECARD_VISUAL: PackedScene = preload("res://src/world/levels/02_reality_tv/minigames/shuffleboard/scorecard_visual.tscn")

@onready var pucks: Node2D = %Pucks


func _ready() -> void:
	%UpdateTimer.timeout.connect(_on_update_timer_timeout)

	_create_scorecards.call_deferred()


func _on_update_timer_timeout() -> void:
	# Order the pucks based on who's closest to the goal
	var rankings: Array[Node] = pucks.get_children()
	rankings.sort_custom(_sort_by_distance_to_goal)

	for scorecard: Scorecard in %List.get_children():
		%List.move_child(scorecard, rankings.find(scorecard.target))


func _create_scorecards() -> void:
	for i: int in range(pucks.get_child_count()):
		var new_scorecard: Scorecard = SCORECARD.instantiate()
		new_scorecard.target = pucks.get_child(i)
		%List.add_child(new_scorecard)

		var new_scorecard_visual: ScorecardVisual = SCORECARD_VISUAL.instantiate()
		new_scorecard_visual.target = new_scorecard
		%Visuals.add_child(new_scorecard_visual)


func _sort_by_distance_to_goal(a: Puck, b: Puck) -> bool:
	var child_a_distance_to_goal: float = (a.global_position - PuckAI.goal).length()
	var child_b_distance_to_goal: float = (b.global_position - PuckAI.goal).length()
	return child_a_distance_to_goal < child_b_distance_to_goal
