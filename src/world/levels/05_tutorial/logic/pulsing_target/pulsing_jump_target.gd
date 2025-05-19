extends Sprite2D

@export var pulsing_speed: float = 3

var time: float
var initial_offset: float = randi()


func _process(delta: float) -> void:
	time += delta
	self_modulate.a = 0.4 * sin(pulsing_speed * time + initial_offset) + 0.6
