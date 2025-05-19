extends Node2D

@export var quest_index: int = -1
@export var connections: Array[Array]


func _ready() -> void:
	EventBus.clouds_cleared.connect(_on_clouds_cleared)
	%QuestDropdown.item_selected.connect(_on_quest_dropdown_item_selected)

	generate_quest_line()
	# Hide the quest line if it isn't selected
	visible = %QuestDropdown.selected == quest_index and quest_index != -1


func generate_quest_line() -> void:
	for connection: Array in connections:
		if connection.size() != 2:
			printerr("Connection can only occur between 2 levels. Skipping...")
			continue
		
		var level_1: LevelButton = get_node(connection[0])
		var level_2: LevelButton = get_node(connection[1])

		# Create line
		var new_line: Line2D = Line2D.new()
		new_line.add_point(level_1.global_position)
		new_line.add_point(level_2.global_position)

		# Create gradient for line
		var new_gradient: Gradient = Gradient.new()
		new_gradient.set_color(0, Color.WHITE if level_1.region == -1 else Color.TRANSPARENT)
		new_gradient.set_color(1, Color.WHITE if level_2.region == -1 else Color.TRANSPARENT)
		new_line.gradient = new_gradient

		add_child(new_line)


func _on_clouds_cleared(p_region: int) -> void:
	# Wait for the level buttons to update their region value first
	generate_quest_line.call_deferred()


func _on_quest_dropdown_item_selected(index: int) -> void:
	visible = index == quest_index
