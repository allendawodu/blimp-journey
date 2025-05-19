@tool
class_name Character
extends CharacterBody2D

@export var style: Style

@onready var body: Body = %Body
@onready var pathfinding: PathfindingState = %Pathfinding
@onready var path_builder: PathBuilder = get_node_or_null("%PathBuilder")
@onready var _chart: StateChart = %StateChart


func _ready() -> void:
	set_style(style)


## Prevent user input/actions from inhibiting pathfinding.
func ignore_user_and_pathfind() -> void:
	_chart.send_event("can_pathfind")
	_chart.send_event("pathfind")


func knockback(impulse: Vector2, override: bool = false) -> void:
	%Knockback.knockback = impulse
	%Knockback.should_override_direction = override
	_chart.send_event("knockback")


## Returns a duplicate of the style.
func get_style() -> Style:
	return body.get_style()


func set_style(new_style: Style) -> void:
	body.set_style(new_style)
