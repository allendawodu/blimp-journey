extends Label


func _process(delta: float) -> void:
	var enemies_left: int = %Ghosts.get_child_count()
	if enemies_left == 1:
		text = "1 ENEMY LEFT!"
	elif enemies_left == 0:
		text = "ALL ENEMIES CLEARED!"
	else:
		text = "%d ENEMIES LEFT!" % enemies_left
