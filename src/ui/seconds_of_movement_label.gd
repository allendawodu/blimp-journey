extends Label

@export var target: Player


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_label_pressed(KEY_P):
		visible = true


func _process(delta: float) -> void:
	if not visible:
		text = str(snapped(target.time_spent_moving, 1))
