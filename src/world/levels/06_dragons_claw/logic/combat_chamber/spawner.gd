extends Node

const DRAGON_SPIRIT: PackedScene = preload("res://src/world/levels/06_dragons_claw/logic/combat_chamber/dragon_spirit.tscn")

@export var spawn_data: Array[DragonSpawnData06]
@export var characters: Array[Character]

@onready var timer: Timer = %CombatTimer


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)


func _process(delta: float) -> void:
	if timer.is_stopped():
		return
	
	# var time_elapsed: float = timer.wait_time - timer.time_left

	# # Iterate backwards because I need to delete elements from the array
	# for i: int in range(spawn_data.size() - 1, -1, -1):
	# 	var data: DragonSpawnData06 = spawn_data[i]
	# 	if time_elapsed >= data.time:
	# 		spawn_dragon(data)
	# 		spawn_data.remove_at(i)

	# DEBUG
	for i: int in get_child_count():
		if randf() < 0.1 * delta:
			var dragon = DRAGON_SPIRIT.instantiate()
			var spawn_marker: Marker2D = get_child(i)
			dragon.global_position = spawn_marker.global_position
			dragon.speed = 1000
			dragon.length = 1024
			dragon.direction = Vector2.RIGHT.rotated(spawn_marker.global_rotation)
			get_parent().add_child(dragon)


func spawn_dragon(data: DragonSpawnData06) -> void:
	var dragon = DRAGON_SPIRIT.instantiate()
	var spawn_marker: Marker2D = get_child(data.spawn_marker_index)

	dragon.global_position = spawn_marker.global_position
	dragon.speed = data.speed
	dragon.length = data.length
	dragon.direction = Vector2.RIGHT.rotated(spawn_marker.global_rotation)
	
	get_parent().add_child(dragon)


func _on_timer_timeout() -> void:
	get_tree().call_group("dragon_spirits", "queue_free")

	# Start dialogue
	var text_bubble_markers: Array[TextBubbleMarker]
	for character: Character in characters:
		text_bubble_markers.append(character.get_node("TextBubbleMarker"))
		
	Dialogic.quick_start("tomb", "guide_saved", text_bubble_markers)
