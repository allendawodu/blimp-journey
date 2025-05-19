@tool
extends StylePart

@export var pupil: StylePart


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	global_position.y = pupil.get_child(0).global_position.y
	# The eyelid slowly shifts when the head tilts
	position.x = 0


func set_color(color: Color) -> void:
	super(color)

	get_node("../..").find_child("Eye?Outline*").self_modulate = color
