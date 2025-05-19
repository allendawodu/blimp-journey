@tool
class_name BehaviorRun
extends Behavior
## Make sure to place this near the floor so that the character can actually reach the target.

@export var should_disappear_at_target: bool = true
@export var should_disable_interaction: bool = true

## Behavior event signal has been received.
## Prevents conflicting behaviors from activating each other.
var _is_active: bool
var _uuid: String


func _ready() -> void:
	super()

	if Engine.is_editor_hint():
		var old_global_position: Vector2 = global_position
		top_level = true
		global_position = old_global_position


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if _is_active and target.pathfinding.has_reached_end_of_path:
		EventBus.behavior_event_ended.emit(_uuid)
		_is_active = false

		if should_disappear_at_target:
			target.queue_free()


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 10, Color.WHITE, false)


func _on_behavior_event_started(args: Dictionary) -> void:
	if not _does_event_match(args):
		return
		
	_is_active = true
	_uuid = args.uuid
	# Prevent the player from messing up this character's pathfinding with their user input/actions
	target.ignore_user_and_pathfind()

	# Normally, you set the position, then pathfind
	# But this has to go after, probably because 2 events need to be sent first
	target.pathfinding.go_to_position(global_position)

	if should_disable_interaction:
		var interactable: Interactable = target.find_children("Interactable*", "Interactable", false, false).front()
		if is_instance_valid(interactable):
			interactable.queue_free()


func _on_event_list_updated(event_list: Array[String]) -> void:
	if not corresponding_game_event.is_empty() \
		and event_list.has(corresponding_game_event) \
		and should_disappear_at_target:
			target.queue_free()
