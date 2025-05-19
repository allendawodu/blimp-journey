@tool
extends DialogicEvent
class_name DialogicFlipEvent

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

var who: String
var direction: Direction = Direction.RIGHT
var should_wait: bool = true

var _uuid: String


func _execute() -> void:
	_uuid = Nanoid.generate(7)

	var args: Dictionary = {
		"who": who,
		"direction": direction,
		"uuid": _uuid,
	}

	args.make_read_only()

	EventBus.flip_event_started.emit(args)

	if should_wait:
		dialogic.current_state = dialogic.States.WAITING

		if dialogic.has_subsystem("Text"):
			dialogic.Text.update_dialog_text('', true)
			dialogic.Text.hide_textbox()
		
		EventBus.flip_event_ended.connect(_on_flip_event_ended)
	else:
		finish()


func _on_flip_event_ended(uuid: String) -> void:
	if uuid != _uuid:
		return
	
	EventBus.flip_event_ended.disconnect(_on_flip_event_ended)
	
	dialogic.current_state = dialogic.States.IDLE
	
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Flip"
	set_default_color("Color8")
	event_category = "Visuals"



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "flip"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
		"who": {"property": "who", "default": ""},
		"direction": {"property": "direction", "default": Direction.RIGHT, "suggestions": _enum_to_suggestions.bind(Direction.keys(), Direction.values())},
		"wait": {"property": "should_wait", "default": true},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	# Add a label to the editor
	add_header_label("Flip character")

	# Add a text field for the character name
	add_header_edit("who", ValueType.SINGLELINE_TEXT, {"left_text": "Who:"})

	# Add a dropdown for the direction
	add_header_edit("direction", ValueType.FIXED_OPTIONS, {"options": _enum_to_options(Direction.keys(), Direction.values())})

	add_body_edit("wait", ValueType.BOOL, {"left_text": "Wait:"})

#endregion
