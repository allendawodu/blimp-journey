class_name PathfindPossibleStateHijacker
extends Node
## This hijacker exists due to an engine bug that doesn't allow a script
## to be attached to PathfindPossible.
## Code here what you want PathfindPossible to do.

## Ignore reasons to prevent user input/actions from inhibiting pathfinding.
var should_ignore_reasons: bool

## It just counts the number of reasons why the NPC can't pathfind
## (rather than setting multiple variables).
## When equal to 0, pathfinding is possible.
var _cannot_pathfind_num_reasons: int:
	set(value):
		if value < 0:
			printerr(owner, "'s reasons for not pathfinding is negative.")
		_cannot_pathfind_num_reasons = max(0, value)

@onready var _target: CharacterBody2D = get_owner()


func _ready() -> void:
	get_parent().state_entered.connect(_on_state_entered)
	get_parent().state_unhandled_input.connect(_on_state_unhandled_input)
	get_parent().state_processing.connect(_on_state_processing)
	get_parent().state_physics_processing.connect(_on_state_physics_processing)
	get_parent().state_exited.connect(_on_state_exited)

	EventBus.interactable_mouse_entered.connect(_on_interactable_mouse_entered)
	EventBus.interactable_mouse_exited.connect(_on_interactable_mouse_exited)
	EventBus.pathfind_started.connect(_on_pathfind_started)
	EventBus.pathfind_aborted.connect(_on_pathfind_aborted)


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if should_ignore_reasons or _cannot_pathfind_num_reasons == 0:
		get_parent()._chart.send_event("can_pathfind")
	else:
		get_parent()._chart.send_event("no_pathfind")


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	pass


func _on_interactable_mouse_entered(other: Interactable) -> void:
	if other.get_parent() != owner:
		return
	
	_cannot_pathfind_num_reasons += 1


func _on_interactable_mouse_exited(other: Interactable) -> void:
	if other.get_parent() != owner:
		return

	_cannot_pathfind_num_reasons -= 1


func _on_pathfind_started(to: Interactable) -> void:
	if to.get_parent() != owner:
		return
	
	_cannot_pathfind_num_reasons += 1

	if not Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
		Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)


func _on_pathfind_aborted(to: Interactable) -> void:
	if to.get_parent() != owner:
		return
	
	_cannot_pathfind_num_reasons -= 1

	if Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_dialogic_timeline_ended)


func _on_dialogic_timeline_ended() -> void:
	_cannot_pathfind_num_reasons = 0
