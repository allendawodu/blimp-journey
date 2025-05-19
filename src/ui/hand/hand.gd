extends Control

const CARD: PackedScene = preload("res://src/ui/hand/card.tscn")
const CARD_VISUAL: PackedScene = preload("res://src/ui/hand/card_visual.tscn")

@export_range(0, 1000) var distance_between_cards: float = 100
@export_range(0, 1920) var max_width: float = 1000

@onready var cards: Control = $Cards
@onready var visuals: Control = $Visuals


func _ready() -> void:
	Inventory.updated.connect(_on_inventory_updated)

	EventBus.about_to_pause.connect(_on_about_to_pause)
	EventBus.about_to_resume.connect(_on_about_to_resume)

	# DEBUG
	# for item: String in Inventory.available_items.keys():
	# 	create_card(item)


func _process(delta: float) -> void:
	update_card_positions()


func update_card_positions() -> void:
	if cards.get_child_count() == 0:
		return

	# Confine cards within max_width
	cards.position = Vector2((cards.get_child_count() - 1) * -distance_between_cards / 2 - 64, 0)
	var first_card: Card = cards.get_child(0)
	var last_card: Card = cards.get_child(-1)
	# FIXME: Still shrinks a little
	if last_card.position.x - first_card.position.x > max_width and not first_card.drag_component.is_dragging and not last_card.drag_component.is_dragging:
		distance_between_cards = lerpf(distance_between_cards, 0.0, 0.01)

	# Position cards
	for i: int in cards.get_child_count():
		var card: Card = cards.get_child(i)

		if card.drag_component.is_dragging:
			# TODO: Add offset to account for Control's non-centeredness
			if card.get_index() != 0 and card.position.x < cards.get_child(i - 1).position.x:
				cards.move_child(card, i - 1)
			elif card.get_index() != cards.get_child_count() - 1 and card.position.x > cards.get_child(i + 1).position.x:
				cards.move_child(card, i + 1)
		else:
			card.position = Vector2(i * distance_between_cards, -150)


func create_card(item: String, amount: int = 1):
	var data: Item = Inventory.available_items[item]
	
	# I'm keeping this here because I like the idea of hidden inventory items
	# They're in a way, like game events
	# However, I need to implement the logic for it, something like: if data is ItemHidden
	# if data.is_hidden:
	# 	return

	var new_card: Card = CARD.instantiate()
	new_card.name = item
	new_card.data = data
	new_card.data.amount = amount
	cards.add_child(new_card)

	var new_card_visual: CardVisual = CARD_VISUAL.instantiate()
	new_card_visual.target = new_card
	visuals.add_child(new_card_visual)


func _on_inventory_updated(item: String, amount: int) -> void:
	var card: Card = cards.get_node_or_null(item)
	if is_instance_valid(card):
		if amount <= 0:
			card.queue_free()
		else:
			card.data.amount = amount
			
			if is_instance_valid(card.popup):
				card.popup.update_label()
	else:
		create_card(item, amount)


func _on_about_to_pause(initiator: String) -> void:
	if initiator != "pause_handler":
		hide()


func _on_about_to_resume(initiator: String) -> void:
	if initiator != "pause_handler":
		show()
