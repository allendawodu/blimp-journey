class_name BehaviorStyleChange
extends Behavior

@export var style_additions: Dictionary[String, Variant]
@export var style_removals: Array[String]


func _ready() -> void:
	super()

	type = Types.STYLE_CHANGE


func _on_behavior_event_started(args: Dictionary) -> void:
	if not _does_event_match(args) or not is_instance_valid(target):
		return
	
	if not target.has_method("set_style") or not target.has_method("get_style"):
		printerr("[BehaviorStyleChange] Target does not have get/set_style method.")
		return
	
	var style: Style = target.get_style()

	# Set the style_additions
	for key: String in style_additions.keys():
		style.set(key, style_additions[key])
	
	# Set the style_removals
	for key: String in style_removals:
		if key.begins_with("color_"):
			style.set(key, Color.WHITE)
		else:
			style.set(key, null)
	
	target.set_style(style)

	await get_tree().create_timer(0.5).timeout
	EventBus.behavior_event_ended.emit(args.uuid)
