class_name Level
extends Node

signal scene_changed(new_scene: Scene)

## This is the number the level folder starts with (e.g., 02 in 02_reality_tv).
@export var level_code: int
## The scenes that are part of this level.[br]
## String (scene name) : PackedScene (scene).
@export var scenes: Dictionary

var completed_events: Array[String]
var is_changing_scene: bool

@onready var scene: Scene: get = _get_current_scene


func _enter_tree() -> void:
	Inventory.load_level_items(level_code)


func _ready() -> void:
	add_to_group("persist")
	add_to_group("level")

	EventBus.event_completed.connect(_on_event_completed)
	
	# Sort the physics picking objects and only allow the player to select the top-most one
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true

	if scenes.is_empty():
		printerr("[Level] Scenes dictionary must not be empty! Aborting...")
		return

	# Preload Dialogic to prevent stutters
	var style: DialogicStyle = load("res://src/world/dialogue/text_bubble.tres")
	style.prepare()

	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = """
	[aa=0.1]Loading...
	""".split("\n")
	Dialogic.start(timeline)

	if Firebase.Auth.is_logged_in():
		SaverLoader.load_game()
	else:
		change_scene("main_street", Vector2.ZERO, false)
		SaverLoader.complete_event("%02d_started" % level_code)


func change_scene(to: String, position: Vector2 = Vector2.ZERO, should_fade_in: bool = true) -> void:
	if is_changing_scene:
		return
	
	is_changing_scene = true
	Dialogic.end_timeline()

	if should_fade_in:
		%AnimationPlayer.play("fade_in")
		await %AnimationPlayer.animation_finished
	
	# Remove the current scene
	if is_instance_valid(scene):
		Dialogic.end_timeline()
		scene.queue_free()
	else:
		printerr("[Level] Cannot remove the current scene, it is not valid!")
	
	# Wait a frame for the scene to be freed
	await get_tree().process_frame
	
	# Load the new scene
	var new_scene: Scene
	if scenes.has(to) and scenes.get(to) is PackedScene:
		new_scene = scenes.get(to).instantiate()

		if not is_instance_valid(new_scene):
			printerr("[Level] Scene %s could not be instantiated! Going to main street." % to)
			change_scene("main_street", Vector2.ZERO, false)
			return
	else:
		printerr("[Level] PackedScene %s not found in scenes dictionary! Going to main street." % to)
		change_scene("main_street", Vector2.ZERO, false)
		return
	
	%AnimationPlayer.play("fade_out")
	
	# Add the new scene
	add_child(new_scene)
	
	# Wait a frame for the new scene to be processed
	await get_tree().process_frame
	
	# Find the player and set position with error handling
	if not position.is_zero_approx():
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = position
		else:
			printerr("[Level] Player node not found in scene %s" % to)
	
	SaverLoader.save_game()
	is_changing_scene = false

	scene_changed.emit(new_scene)

	# Check that the scene was loaded correctly
	await get_tree().create_timer(3).timeout

	if not is_instance_valid(scene):
		printerr("[Level] Scene %s loaded incorrectly. Trying again..." % to)
		change_scene(to, position, should_fade_in)
		return


func reload_current_scene(position: Vector2 = Vector2.ZERO) -> void:
	change_scene(scene.scene_name, position)


func save_data(document: FirestoreDocument) -> void:
	document.set_field("levels.current_level", "%02d" % level_code)
	document.set_field("levels.%02d.current_scene" % level_code, scene.scene_name if scene else "main_street")
	document.set_field("levels.%02d.position" % level_code, get_tree().get_first_node_in_group("player").global_position)
	document.set_field("levels.%02d.completed_events" % level_code, completed_events)

	# Save Dialogic's variables
	document.set_field("levels.%02d.dialogic" % level_code, Dialogic.VAR["%02d" % level_code].data)


func load_data(document: FirestoreDocument) -> void:
	# Load the completed events
	completed_events = Array(document.get_field("levels.%02d.completed_events" % level_code, ["%02d_started" % level_code]), TYPE_STRING, "", null)

	# Load Dialogic's variables
	Dialogic.VAR["%02d" % level_code].data = document.get_field("levels.%02d.dialogic" % level_code, {})

	# Load the current scene
	var current_scene: String = document.get_field("levels.%02d.current_scene" % level_code, "main_street")
	await change_scene(current_scene, Vector2.ZERO, false)

	# Load the player's position
	get_tree().get_first_node_in_group("player").global_position = document.get_field("levels.%02d.position" % level_code, Vector2.ZERO)


func _get_current_scene() -> Scene:
	var scene_children: Array = find_children("*", "Scene", false, false)
	return scene_children.front() if not scene_children.is_empty() else null


func _on_event_completed(event: String) -> void:
	completed_events.append(event)

	EventBus.event_list_updated.emit(completed_events)
