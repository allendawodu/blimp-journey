extends AudioStreamPlayer

@onready var timer: Timer = %CombatTimer


func _process(delta: float) -> void:
	if not timer.is_stopped() and not playing:
		play()
	elif timer.is_stopped() and playing:
		stop()
