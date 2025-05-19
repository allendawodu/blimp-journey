extends Line2D

enum AxisLock {
	HORIZONTAL,
	VERTICAL,
	NONE,
}

const CURSOR_SPIN_SPEED_DEG: float = 200 

@export_color_no_alpha var jump_color: Color
@export_color_no_alpha var drop_color: Color
@export_color_no_alpha var alt_color: Color
@export_color_no_alpha var regular_color: Color = Color.WHITE
@export_color_no_alpha var outline_color: Color = Color.BLACK
@export var length_divider: float = 8

var _is_in_dialogue: bool
var _cursors: Dictionary = {
	"interact": preload("res://src/ui/icons/priority_high.png") as Texture2D,
}

@onready var _arrow_head: Polygon2D = $ArrowHead
@onready var _custom_cursor: Sprite2D = $CustomCursor
@onready var _outline_arrow_line: Line2D = $OutlineArrowLine
@onready var _outline_arrow_head: Polygon2D = $OutlineArrowHead
@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementStatePlayer = %Movement
@onready var _grounded: GroundedStatePlayer = %Grounded
@onready var _can_interact: CanInteractState = %CanInteract
@onready var _platform_check_area: PlatformChecker = %PlatformCheckArea


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	%PreJump.state_processing.connect(_on_pre_jump_state_processing)
	%Grounded.state_processing.connect(_on_grounded_state_processing)
	%Airborne.state_processing.connect(_on_airborne_state_processing)

	%CanInteract.state_processing.connect(_on_can_interact_state_processing)
	%CanInteract.state_exited.connect(_on_interaction_ended)

	Dialogic.timeline_started.connect(_on_dialogic_timeline_started)
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)

	EventBus.about_to_pause.connect(_on_about_to_pause)
	EventBus.about_to_resume.connect(_on_about_to_resume)

	_outline_arrow_head.self_modulate = outline_color
	_outline_arrow_line.self_modulate = outline_color


func _on_grounded_state_processing(delta: float) -> void:
	if _movement.is_mouse_in_jump_zone:
		self_modulate = jump_color
		_arrow_head.self_modulate = self_modulate
		_set_arrow_transform(AxisLock.NONE)
	elif _movement.is_mouse_in_drop_angle and _platform_check_area.is_on_platform:
		self_modulate = drop_color
		_arrow_head.self_modulate = self_modulate
		_set_arrow_transform(AxisLock.VERTICAL)
	elif _grounded.is_mouse_in_crouch_angle and not _platform_check_area.is_on_platform:
		self_modulate = alt_color
		_arrow_head.self_modulate = self_modulate
		_set_arrow_transform(AxisLock.NONE)
	else:
		self_modulate = regular_color
		_arrow_head.self_modulate = self_modulate
		_set_arrow_transform(AxisLock.HORIZONTAL)
	_set_arrow_alpha()


func _on_airborne_state_processing(delta: float) -> void:
	if _movement.is_mouse_in_jump_zone:
		self_modulate = jump_color
		_arrow_head.self_modulate = self_modulate
		_set_arrow_transform(AxisLock.NONE)
	elif _movement.is_mouse_in_drop_angle:
		self_modulate = drop_color
		_arrow_head.self_modulate = self_modulate
		_set_arrow_transform(AxisLock.VERTICAL)
	else:
		self_modulate = alt_color
		_arrow_head.self_modulate = self_modulate
		_set_arrow_transform(AxisLock.HORIZONTAL)
	_set_arrow_alpha()


func _on_pre_jump_state_processing(delta: float) -> void:
	_set_arrow_transform(AxisLock.NONE)
	self_modulate = jump_color
	_arrow_head.self_modulate = self_modulate
	_set_arrow_alpha()


func _on_can_interact_state_processing(delta: float) -> void:
	if _can_interact.is_interaction_possible:
		_set_custom_cursor_visibility(_cursors.interact)
	else:
		_set_custom_cursor_visibility(null)


func _on_interaction_ended() -> void:
	_set_custom_cursor_visibility(null)


func _on_dialogic_timeline_started() -> void:
	_is_in_dialogue = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_set_custom_cursor_visibility.call_deferred(null)
	hide()


func _on_dialogic_timeline_ended() -> void:
	_is_in_dialogue = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	show()


func _on_about_to_pause(initiator: String) -> void:
	_set_arrow_visibility(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_about_to_resume(initiator: String) -> void:
	if _is_in_dialogue:
		return
	
	_set_arrow_visibility(true)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _set_arrow_transform(axis_lock: AxisLock) -> void:
	# Set position and rotation
	var mouse_angle: float = _movement.vector_to_mouse.angle()
	global_position = get_global_mouse_position()

	if axis_lock == AxisLock.HORIZONTAL:
		var direction: float = signf(Vector2.RIGHT.dot(-_movement.vector_to_mouse))
		set_point_position(1, Vector2.RIGHT * absf(_movement.vector_to_mouse.x) * direction / length_divider)
		_arrow_head.global_rotation = PI if direction > 0 else 0.0
	elif axis_lock == AxisLock.VERTICAL:
		var direction: float = signf(Vector2.DOWN.dot(-_movement.vector_to_mouse))
		set_point_position(1, Vector2.DOWN * absf(_movement.vector_to_mouse.y) * direction / length_divider)
		_arrow_head.global_rotation = -PI / 2 if direction > 0 else PI / 2
	else:
		# Angle the arrow away from the player
		set_point_position(1, -_movement.vector_to_mouse / length_divider)
		_arrow_head.global_rotation = mouse_angle
	
	# Set outline arrow
	_outline_arrow_line.set_point_position(1, get_point_position(1))
	_outline_arrow_head.global_rotation = _arrow_head.global_rotation


func _set_arrow_alpha() -> void:
	if not _movement.is_mouse_outside_character:
		modulate = Color(modulate, 0.2)
	elif not _movement.is_mouse_down:
		modulate = Color(modulate, 0.5)
	else:
		modulate = Color(modulate, 1)


func _set_arrow_visibility(should_show: bool) -> void:
	if should_show:
		self_modulate = Color.WHITE
		_arrow_head.self_modulate = Color.WHITE
		_outline_arrow_line.self_modulate = outline_color
		_outline_arrow_head.self_modulate = outline_color
		_set_arrow_alpha()
	else:
		self_modulate = Color.TRANSPARENT
		_arrow_head.self_modulate = Color.TRANSPARENT
		_outline_arrow_line.self_modulate = Color.TRANSPARENT
		_outline_arrow_head.self_modulate = Color.TRANSPARENT
		set_point_position(1, Vector2.ZERO)
		_outline_arrow_line.set_point_position(1, Vector2.ZERO)


func _set_custom_cursor_visibility(cursor: Texture2D) -> void:
	if cursor:
		_set_arrow_visibility(false)
		_custom_cursor.texture = cursor
		_custom_cursor.visible = true
	else:
		_custom_cursor.visible = false
		_custom_cursor.global_rotation = 0
		_set_arrow_visibility(true)
