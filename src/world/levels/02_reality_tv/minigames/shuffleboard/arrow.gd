extends Line2D

@export var _target: PuckPlayer

@onready var _arrow_head: Polygon2D = $ArrowHead


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(delta: float) -> void:
	# Set position and rotation
	# Angle the arrow away from the player
	global_position = get_global_mouse_position()
	_arrow_head.global_rotation = _target.vector_to_mouse.angle()

	if _target.can_move:
		modulate = Color.WHITE
	else:	
		modulate = Color(1, 1, 1, 0.5)
