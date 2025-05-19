@tool
extends DialogicEvent
class_name DialogicChangeSceneEvent

var scene_name: String
var x: float
var y: float


func _execute() -> void:
	Engine.get_main_loop().get_first_node_in_group("level").change_scene(scene_name, Vector2(x, y))
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Change Scene"
	event_category = "Other"



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "scene"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
		"name": {"property": "scene_name", "default": ""},
		"x": {"property": "x", "default": 0},
		"y": {"property": "y", "default": 0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label("Change scene")
	add_header_edit("scene_name", ValueType.SINGLELINE_TEXT, {"left_text": "Name:"})
	add_body_edit("x", ValueType.NUMBER, {"left_text": "x:", "default": 0})
	add_body_edit("y", ValueType.NUMBER, {"left_text": "y:", "default": 0})

#endregion
