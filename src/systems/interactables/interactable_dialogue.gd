@tool
class_name InteractableDialogue
extends Interactable

@export var timeline: DialogicTimeline
## String (event name) : String (label).
@export var labels: Dictionary[String, String]
## Leaving this empty will default to the target and player's TextBubbleMarkers.
@export_node_path("TextBubbleMarker", "Interactable", "Character") var text_bubble_markers: Array[NodePath]:
	set(value):
		# Automatically get the TextBubbleMarker from Interactables and Characters
		for i: int in value.size():
			var path: String = value[i]
			if path.is_empty():
				continue
			elif not path.ends_with("/TextBubbleMarker"):
				value[i] = (path + "/TextBubbleMarker") as NodePath
		text_bubble_markers = value
				

var current_label: String = ""
var characters: Array[TextBubbleMarker]


func _ready() -> void:
	super()

	if Engine.is_editor_hint():
		if target is Character and player_interact_offset.is_zero_approx():
			player_interact_offset = Vector2(200, 0)
		return

	EventBus.event_list_updated.connect(_on_event_list_updated)
	
	# Get the value of the first label that ends with "started"
	if not labels.is_empty():
		current_label = labels.values().front()
		for key in labels.keys():
			if key.ends_with("started"):
				current_label = labels[key]
				break
	
	# Update the current label based on events from other scenes
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		_on_event_list_updated(level.completed_events)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if timeline == null:
		warnings.append("Timeline is not set.")
	if labels.is_empty():
		warnings.append("Labels list is empty.")
	
	return warnings


func interact() -> void:
	# Default if no characters are set
	if text_bubble_markers.is_empty():
		text_bubble_markers.append("../TextBubbleMarker" as NodePath)
		text_bubble_markers.append(get_tree().get_first_node_in_group("player").get_node("TextBubbleMarker").get_path())
	
	for text_bubble_marker: NodePath in text_bubble_markers:
		characters.append(get_node(text_bubble_marker))
	
	# Ensure we have a valid label
	# FIXME
	if current_label.is_empty() and not labels.is_empty():
		current_label = labels.values().front()
	
	Dialogic.quick_start(timeline, current_label, characters)

	# Make the characters face each other
	# CLEANUP
	var x_positions: Array[float] = []
	var animation_nodes: Array[Node] = []
	
	# Collect positions and visual nodes
	for node_path in text_bubble_markers:
		var parent: Node2D = get_node(node_path).get_parent()
		x_positions.append(parent.global_position.x)
		
		var animation_node = parent.get_node_or_null("%Animation")
		if animation_node:
			animation_nodes.append(animation_node)
	
	if x_positions.size() >= 2:
		# Calculate center point of all characters
		var average_x: float = 0.0
		for x_position in x_positions:
			average_x += x_position
		average_x /= x_positions.size()
		
		# Make characters face toward the center point
		for animation_node in animation_nodes:
			var character_pos = animation_node.owner.global_position.x
			# If character is to the left of center, face right (+1)
			# If character is to the right of center, face left (-1)
			animation_node.set_direction(roundi(sign(average_x - character_pos)))


func _on_event_list_updated(events: Array[String]) -> void:
	for event: String in events:
		if labels.has(event):
			current_label = labels[event]
