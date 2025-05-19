@tool
extends DialogicEvent
class_name DialogicBehaviorEvent

var type: Behavior.Types = Behavior.Types.MOVE
var who: String = ""
var index: int = 0
var should_wait: bool = false

var _uuid: String


func _execute() -> void:
	_uuid = Nanoid.generate(7)

	var args: Dictionary = {
		"uuid" = _uuid,
		"type" = type,
		"who" = who,
		"index" = index,
	}
	args.make_read_only()

	EventBus.behavior_event_started.emit(args)

	if should_wait:
		dialogic.current_state = dialogic.States.WAITING

		if dialogic.has_subsystem("Text"):
			dialogic.Text.update_dialog_text('', true)
			dialogic.Text.hide_textbox()
		
		EventBus.behavior_event_ended.connect(_on_behavior_event_ended)
	else:
		finish()


func _on_behavior_event_ended(uuid: String) -> void:
	if uuid != _uuid:
		return
	
	EventBus.behavior_event_ended.disconnect(_on_behavior_event_ended)
	
	dialogic.current_state = dialogic.States.IDLE
	
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Behavior"
	set_default_color("Color6")
	event_category = "Logic"


#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "behavior"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
		"type": {"property": "type", "default": Behavior.Types.MOVE, "suggestions": _enum_to_suggestions.bind(Behavior.Types.keys(), Behavior.Types.values())},
		"who": {"property": "who", "default": ""},
		"index": {"property": "index", "default": 0},
		"wait": {"property": "should_wait", "default": false},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("Emit behavior signal")
	add_header_edit("types", ValueType.FIXED_OPTIONS, {"options": _enum_to_options(Behavior.Types.keys(), Behavior.Types.values())})
	add_header_edit("who", ValueType.SINGLELINE_TEXT, {"left_text": "Who:"})
	add_body_edit("index", ValueType.NUMBER, {"left_text": "Index:"})
	add_body_edit("wait", ValueType.BOOL, {"left_text": "Wait:"})

#endregion
