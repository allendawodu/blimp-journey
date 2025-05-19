extends Sprite2D


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal_event)


func _on_dialogic_signal_event(event: Variant) -> void:
	if event == "shake_tomb":
		var shake_addon: PCamShake = get_tree().get_first_node_in_group("procam").addons[2]
		if shake_addon:
			shake_addon.shake()
		else:
			printerr("Shake addon not found in group 'procam'")
	elif event == "teleport_player":
		get_tree().get_first_node_in_group("level").change_scene("burial_chamber")
		get_child(0).queue_free()
