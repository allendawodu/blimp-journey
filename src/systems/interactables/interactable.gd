@tool
class_name Interactable
extends Area2D
## Abstract class.

@export var target: Node2D
@export var should_disable_prompt: bool
## Where the prompt should appear relative to the interactable.
## Default works for NPCs but not much else.
@export var prompt_offset: Vector2 = Vector2(0, -256)
## Where the player should move relative to the interactable.
@export var player_interact_offset: Vector2

var _prompt_texture: Texture2D = preload("res://src/ui/icons/priority_high.png")
var _prompt: Sprite2D


func _enter_tree() -> void:
	# Set the collision layer to `interactable`
	set_collision_layer_value(1, false)
	set_collision_layer_value(4, true)

	if Engine.is_editor_hint():
		return

	if not should_disable_prompt:
		_prompt = Sprite2D.new()
		_prompt.position = prompt_offset
		_prompt.texture = _prompt_texture
		_prompt.scale = Vector2(0.25, 0.25)
		_prompt.visible = false
		add_child(_prompt)


func _ready() -> void:
	if Engine.is_editor_hint():
		if not is_instance_valid(target):
			target = get_parent()
		return
	
	Dialogic.timeline_started.connect(_on_dialogic_timeline_started)
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)

	mouse_entered.connect(_on_target_mouse_entered)
	mouse_exited.connect(_on_target_mouse_exited)


## Override.
func interact() -> void:
	pass


func _on_target_mouse_entered() -> void:
	EventBus.interactable_mouse_entered.emit(self)
	if _prompt and not should_disable_prompt:
		_prompt.show()


func _on_target_mouse_exited() -> void:
	EventBus.interactable_mouse_exited.emit(self)
	if _prompt and not should_disable_prompt:
		# TODO: I eventually want this prompt to fade in and out
		_prompt.hide()


func _on_dialogic_timeline_started() -> void:
	input_pickable = false
	
	if _prompt:
		_prompt.hide()


func _on_dialogic_timeline_ended() -> void:
	input_pickable = true
