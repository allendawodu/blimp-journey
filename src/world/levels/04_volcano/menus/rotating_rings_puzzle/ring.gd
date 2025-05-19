class_name Ring04
extends TextureButton

signal correct_angle

const MARGIN: float = PI / 16

@export var rotation_snap_step: float = PI / 3

var ring_rotation: float: get = _get_normalized_rotation
var texture: Texture2D:
	set(value):
		$TextureRect.texture = value

		# For some reason, this code has to be all the way up here
		var bitmap: BitMap = BitMap.new()
		bitmap.create_from_image_alpha(value.get_image())
		texture_click_mask = bitmap

var _initial_angle: float
var _initial_mouse_angle: float
var _is_mouse_down: bool


func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

	# Randomize the rotation to a snapping angle
	$TextureRect.pivot_offset = size / 2
	$TextureRect.rotation = _snap_rotation(randf_range(-PI, PI))


func _process(delta: float) -> void:
	if _is_mouse_down:
		var mouse_angle: float = (global_position + size / 2).angle_to_point(get_global_mouse_position())
		var new_rotation: float = _initial_angle + (mouse_angle - _initial_mouse_angle)
		$TextureRect.rotation = _snap_rotation(new_rotation)


func _on_button_down() -> void:
	_initial_mouse_angle = (global_position + size / 2).angle_to_point(get_global_mouse_position())
	_initial_angle = $TextureRect.rotation
	_is_mouse_down = true


func _on_button_up() -> void:
	_is_mouse_down = false
	
	print("Ring angle: ", rad_to_deg(_get_normalized_rotation()))


## Get an angle between [0, 2PI)
func _get_normalized_rotation() -> float:
	var normalized_rotation = fposmod($TextureRect.rotation, 2*PI)
	if normalized_rotation < 0:
		normalized_rotation += 2*PI
	if abs(normalized_rotation - 2*PI) < PI/180:
		normalized_rotation = 0
	return normalized_rotation


func _snap_rotation(current_rotation: float) -> float:
	return round(current_rotation / rotation_snap_step) * rotation_snap_step
