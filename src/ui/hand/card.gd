class_name Card
extends Control

const CARD_POPUP: PackedScene = preload("res://src/ui/hand/card_popup.tscn")
const WORLD_PATH: String = "/root/Level"

var data: Item
var popup: CardPopup

var _should_show_popup: bool = true
var _can_be_pressed: bool

@onready var drag_component: HandDragComponent = %DragComponent
@onready var popup_position: Node2D = %PopupPosition
@onready var pressed_timer: Timer = %PressedTimer
@onready var player: Player: get = _get_player
@onready var level: Level = get_tree().get_first_node_in_group("level")


func _ready() -> void:
	drag_component.mouse_entered.connect(_on_drag_component_mouse_entered)
	drag_component.mouse_exited.connect(_on_drag_component_mouse_exited)
	drag_component.button_down.connect(_on_drag_component_button_down)
	drag_component.pressed.connect(_on_drag_component_pressed)
	
	pressed_timer.timeout.connect(_on_pressed_timer_timeout)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_should_show_popup = not event.pressed


func _process(delta: float) -> void:
	if not _should_show_popup:
		_on_drag_component_mouse_exited()


func _on_drag_component_mouse_entered() -> void:
	if _should_show_popup:
		popup = CARD_POPUP.instantiate()
		popup.data = data
		popup.position = popup_position.position
		add_child(popup)


func _on_drag_component_mouse_exited() -> void:
	if is_instance_valid(popup):
		popup.queue_free()
		popup = null


func _on_drag_component_pressed() -> void:
	if _can_be_pressed:
		## @deprecated
		# Player is using item in dialogue
		if Dialogic.current_timeline:
			# Auto advance dialogue if player keeps on clicking the card
			# CLEANUP: Extract to function
			var index_start: int = -1
			var index_end: int = -1
			for i: int in range(Dialogic.current_timeline_events.size()):
				var event: DialogicEvent = Dialogic.current_timeline_events[i]
				if event is DialogicLabelEvent and event.name == data.name:
					index_start = i
				if index_start != -1 and event is DialogicEndTimelineEvent:
					index_end = i
					break
			
			# DEBUG
			# printt(Dialogic.current_event_idx, index_start, index_end)

			if not Maid.is_within(Dialogic.current_event_idx, index_start, index_end):
				Dialogic.Jump.jump_to_label(data.name)

			Dialogic.handle_next_event()
		# Player is using the item in the world
		else:
			if data is ItemExamine:
				_examine_item()
			elif data is ItemUseable:
				_use_item()


func _examine_item() -> void:
	EventBus.item_examine_started.emit(data.name)


func _use_item() -> void:
	var interactable: Interactable = level.scene.get_node_or_null(data.interactable_node_path)
	var marker: TextBubbleMarker = player.find_children("*", "TextBubbleMarker", false, false).front()
	
	if is_instance_valid(interactable):
		# Try to use the item
		if player.attempt_item_interaction(interactable, data) == false:
			# Make the player character say something when they can't use the item.
			Dialogic.quick_start(data.timeline, data.name, [marker])
	else:
		# Make the player character say something when they can't use the item.
		Dialogic.quick_start(data.timeline, data.name, [marker])


func _on_drag_component_button_down() -> void:
	_can_be_pressed = true
	pressed_timer.start()


func _on_pressed_timer_timeout() -> void:
	_can_be_pressed = false


func _get_player() -> Player:
	return get_tree().get_first_node_in_group("player")
