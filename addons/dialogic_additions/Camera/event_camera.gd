@tool
extends DialogicEvent
class_name DialogicCameraEvent

var cinematic_id: String = ""
var index: int = 0
var should_wait: bool = true

func _execute() -> void:
	EventBus.camera_event_started.emit(cinematic_id, index)

	if should_wait:
		dialogic.current_state = dialogic.States.WAITING

		if dialogic.has_subsystem("Text"):
			dialogic.Text.update_dialog_text('', true)
			dialogic.Text.hide_textbox()
		
		await EventBus.camera_event_ended

		dialogic.current_state = dialogic.States.IDLE

	finish()

#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Camera"
	event_category = "Visuals"

#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "camera"


func get_shortcode_parameters() -> Dictionary:
	return {
		"id": {"property": "cinematic_id", "default": ""},
		"index": {"property": "index", "default": 0},
		"wait": {"property": "should_wait", "default": true},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion

#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("Set cinematic")
	add_header_edit("cinematic_id", ValueType.SINGLELINE_TEXT, {"left_text": "Cinematic ID:"})
	add_body_edit("index", ValueType.NUMBER, {"left_text": "Index:"})
	add_body_edit("wait", ValueType.BOOL, {"left_text": "Wait:"})

#endregion
