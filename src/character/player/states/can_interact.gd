class_name CanInteractState
extends AtomicState

var current_interactable: Interactable
var is_interaction_possible: bool
var saved_interactable: Interactable

@onready var _target: CharacterBody2D = get_owner()
@onready var _pathfinding: PathfindingState	= %Pathfinding


func _ready() -> void:
	super()

	EventBus.interactable_mouse_entered.connect(_on_interactable_mouse_entered)
	EventBus.interactable_mouse_exited.connect(_on_interactable_mouse_exited)


func _on_state_entered() -> void:
	# After pathfinding to the target, interact with it
	if is_instance_valid(saved_interactable) and _pathfinding.has_reached_end_of_path:
		if saved_interactable is not InteractableCollectible:
			saved_interactable.interact()
		saved_interactable = null


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return
	
	# Pathfind to the interactable upon clicking it
	if Maid.is_left_click(event) and is_interaction_possible:
		go_to_interactable(current_interactable)
		get_viewport().set_input_as_handled()


func _on_state_processing(delta: float) -> void:
	is_interaction_possible = is_instance_valid(current_interactable)


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	is_interaction_possible = false


func go_to_interactable(interactable: Interactable) -> void:
	saved_interactable = interactable
	_pathfinding.go_to_target(saved_interactable)
	_chart.send_event("pathfind")
	EventBus.pathfind_started.emit(saved_interactable)


func _on_interactable_mouse_entered(other: Interactable) -> void:
	current_interactable = other


func _on_interactable_mouse_exited(other: Interactable) -> void:
	if current_interactable == other:
		current_interactable = null
