@tool
class_name BehaviorTeleport
extends Behavior


func _ready() -> void:
	super()

	type = Types.TELEPORT

	if Engine.is_editor_hint():
		var old_global_position: Vector2 = global_position
		top_level = true
		global_position = old_global_position


func _draw() -> void:
	if Engine.is_editor_hint():
		var line_length: float = 10.0

		# Line from top-left to bottom-right
		draw_line(
			Vector2(-line_length, -line_length), 
			Vector2(line_length, line_length), 
			Color.WHITE
		)
		# Line from top-right to bottom-left
		draw_line(
			Vector2(line_length, -line_length), 
			Vector2(-line_length, line_length), 
			Color.WHITE
		)


func _on_behavior_event_started(args: Dictionary) -> void:
	if not _does_event_match(args):
		return
	
	target.global_position = global_position
	await get_tree().create_timer(0.5).timeout
	EventBus.behavior_event_ended.emit(args.uuid)
