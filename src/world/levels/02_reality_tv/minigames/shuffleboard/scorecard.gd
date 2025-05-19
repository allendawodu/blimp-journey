class_name Scorecard
extends PanelContainer

var rank: int
var target: Puck


func _process(delta: float) -> void:
	rank = get_index() + 1
