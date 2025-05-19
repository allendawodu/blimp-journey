class_name Behavior
extends Node2D

enum Types {MOVE, DROP, TELEPORT, STYLE_CHANGE}

@export var type: Types
@export var target: Character
@export var index: int = 0
## Use this if you want a group of Characters to share the same behavior.
@export var name_override: String = ""
## The event that corresponds to this behavior.
## Used when loading the level.
@export var corresponding_game_event: String


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not is_instance_valid(target):
		if get_parent() is not Character:
			printerr("[Behavior] Target cannot be set.")
		else:
			target = get_parent()
	
	EventBus.behavior_event_started.connect(_on_behavior_event_started)
	EventBus.event_list_updated.connect(_on_event_list_updated)


func _on_behavior_event_started(args: Dictionary) -> void:
	pass


func _does_event_match(args: Dictionary) -> bool:
	if not is_instance_valid(target):
		return false

	return args.type == type \
		and args.index == index \
		and (name_override.is_empty() and args.who == target.name.to_snake_case() 
		or (not args.who.is_empty() and args.who == name_override))


func _on_event_list_updated(event_list: Array[String]) -> void:
	pass
