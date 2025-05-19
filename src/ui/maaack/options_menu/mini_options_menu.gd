extends MiniOptionsMenu


func _ready() -> void:
	super()

	# This exists to force everyone to use the same fullscreen setting
	# TODO: Remove this and the entire ready method after a few updates (e.g., 1.2.0)
	AppSettings.set_fullscreen_enabled(false, get_window())


func _on_air_control_control_setting_changed(value:Variant) -> void:
	AppSettings.set_air_control(value)
