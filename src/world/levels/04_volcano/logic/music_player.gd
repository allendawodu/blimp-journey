extends AudioStreamPlayer

@export var start_event: String
@export var stop_event: String


func _ready() -> void:
	EventBus.event_list_updated.connect(_on_event_list_updated)


func _on_event_list_updated(event_list: Array[String]) -> void:
	if start_event in event_list and start_event == event_list.back():
		get_stream_playback().switch_to_clip_by_name("chase")
	if stop_event in event_list and stop_event == event_list.back():
		get_stream_playback().switch_to_clip_by_name("chase_finished")
		
		# Fade out with tween
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "volume_db", -40, 10)

