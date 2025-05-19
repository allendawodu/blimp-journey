class_name Puck
extends RigidBody2D
## Abstract class.

static var colors: Array[Color] = [
	Color.RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.GREEN,
	Color.BLUE,
	Color.INDIGO,
	Color.VIOLET,
	Color.BLACK,
]

@export_range(1, 5) var movement_multiplier: float = 1.5

@onready var color: Color = colors[get_index()]


func _ready() -> void:
	%CooldownTimer.timeout.connect(_on_cooldown_timer_timeout)

	$Sprite2D.modulate = color


func _on_cooldown_timer_timeout() -> void:
	pass
