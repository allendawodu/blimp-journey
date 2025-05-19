extends PathFollow2D

const GAME_EVENT: String = "06_escape_sequence_started"
const PLAYER_RESET_POSITION: Vector2 = Vector2(5475, 4518)


@onready var timer: Timer = $Timer
@onready var player: Player
@onready var shake_addon: PCamShake


func _ready() -> void:
	EventBus.event_list_updated.connect(_on_event_list_updated)
	Dialogic.timeline_started.connect(timer.set_paused.bind(true))
	Dialogic.timeline_ended.connect(timer.set_paused.bind(false))
	$Area2D.body_entered.connect(_on_body_entered)

	await get_tree().create_timer(1).timeout

	shake_addon = get_tree().get_first_node_in_group("procam").addons[2]
	player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if timer.is_stopped():
		return
	
	progress_ratio = (timer.wait_time - timer.time_left) / timer.wait_time

	var distance_to_player = abs(player.global_position.y - global_position.y)
	shake_addon.intensity = clamp(remap(distance_to_player, 0, 1500, 5, 0.1), 0.1, 5)


func _on_event_list_updated(events: Array[String]) -> void:
	if GAME_EVENT in events:
		timer.start()
	if "06_artifact_taken" in events:
		shake_addon.shake()


func _on_body_entered(other: Node2D) -> void:
	if other is not Player:
		return
	
	if timer.is_stopped():
		# Player fell in by accident
		other.global_position = Vector2(4787, 4787)
	else:
		timer.stop()
		progress_ratio = 0
		other.global_position = PLAYER_RESET_POSITION

		await get_tree().create_timer(1).timeout
		
		timer.start()
