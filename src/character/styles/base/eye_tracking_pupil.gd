@tool
class_name EyeTrackingPupil
extends StylePart

@export var radius: float = 5
@export var pupil_speed: float = 0.2
@export var should_track_mouse_position: bool = true

@onready var pupil: Node2D = get_child(0)
@onready var animation_state: CompoundState = %Animation


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if should_track_mouse_position:
		_set_target_position(get_global_mouse_position())


func set_target_position(target: Vector2) -> void:
	should_track_mouse_position = false
	_set_target_position(target, false)


func track_mouse_position() -> void:
	should_track_mouse_position = true


func _set_target_position(target: Vector2, should_lerp: bool = true) -> void:
	# Don't move the pupil if the mouse is over the eye
	if pupil.global_position.distance_to(target) < radius / 2:
		return
	
	var direction_to_target: Vector2 = pupil.global_position.direction_to(target)
	direction_to_target.x *= animation_state.direction
	pupil.position = pupil.position.lerp(direction_to_target * radius, pupil_speed if should_lerp else 1.0)
