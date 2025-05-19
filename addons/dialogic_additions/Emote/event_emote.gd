@tool
extends DialogicEvent
class_name DialogicEmoteEvent

enum Animations {TRAVESTY}

var animation: Animations = Animations.TRAVESTY
var who: String = ""
var repeat: int = 0


func _execute() -> void:
	var args: Dictionary = {
		"animation": animation,
		"who": who,
		"repeat": repeat,
	}
	args.make_read_only()

	EventBus.emote_event_started.emit(args)

	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Emote"
	set_default_color("Color6")
	event_category = "Visuals"

#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "emote"


func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
		"anim": {"property": "animation", "default": Animations.TRAVESTY, "suggestions": _enum_to_suggestions.bind(Animations.keys(), Animations.values())},
		"who": {"property": "who", "default": ""},
		"repeat": {"property": "repeat", "default": 0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("Emit emote signal")
	add_header_edit("animation", ValueType.FIXED_OPTIONS, {"options": _enum_to_options(Animations.keys(), Animations.values())})
	add_header_edit("who", ValueType.SINGLELINE_TEXT, {"left_text": "Who:"})
	add_body_edit("repeat", ValueType.NUMBER, {"left_text": "Repeat:"})

#endregion
