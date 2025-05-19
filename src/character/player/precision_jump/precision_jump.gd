class_name PrecisionJump
extends Sprite2D

var target: Character


func _ready() -> void:
	await get_tree().create_timer(0.1).timeout

	show()


func _input(event: InputEvent) -> void:
	if is_queued_for_deletion():
		return
		
	if event is InputEventMouseMotion and AppSettings.is_drag_only_air_control_enabled():
		queue_free()
	if Maid.is_left_click(event):
		queue_free()


func _process(delta: float) -> void:
	if target.is_on_floor():
		queue_free()
