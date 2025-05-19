extends Player


func _ready() -> void:
	super()
	$HealthComponent.damaged.connect(_on_health_component_damaged)


func kill() -> void:
	Dialogic.signal_event.emit("game_over")


func _on_health_component_damaged() -> void:
	print($HealthComponent.health)
