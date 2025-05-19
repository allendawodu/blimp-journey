extends ProgressBar


func _process(delta: float) -> void:
	value = Dialogic.VAR.get_variable("07.tank_level", 0)
