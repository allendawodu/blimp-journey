@tool
extends Interactable

const PIPE_BANGS_TEMPLATE = "07.pipe_%d_bangs"

@export var pipe_number: int
@export var progress_textures: Array[Texture2D]


func _ready() -> void:
	super()
	
	set_texture()
	free_on_completion()


func interact() -> void:
	_set_current_bangs(_get_current_bangs() + 1)
	set_texture()

	$"../AlertingObject".alert()

	if _get_current_bangs() >= progress_textures.size() - 1:
		SaverLoader.complete_event("07_pipe_%d_fixed" % pipe_number)
		Dialogic.VAR.set_variable("07.num_pipes_fixed", Dialogic.VAR.get_variable("07.num_pipes_fixed", 0) + 1)
		free_on_completion()

		if Dialogic.VAR.get_variable("07.num_pipes_fixed", 0) >= 3:
			Dialogic.quick_start("07_apartment", "all_pipes_fixed", [get_tree().get_first_node_in_group("player").get_node("TextBubbleMarker")])


func set_texture() -> void:
	# Update the texture based on the current progress
	var progress = _get_current_bangs()
	target.texture = progress_textures[progress]


func free_on_completion() -> void:
	if _get_current_bangs() >= progress_textures.size() - 1:
		queue_free()


func _get_current_bangs() -> int:
	var current_bangs = Dialogic.VAR.get_variable(PIPE_BANGS_TEMPLATE % pipe_number, 0)
	return current_bangs if typeof(current_bangs) == TYPE_INT else current_bangs.to_int()


func _set_current_bangs(value: int) -> void:
	Dialogic.VAR.set_variable(PIPE_BANGS_TEMPLATE % pipe_number, value)
