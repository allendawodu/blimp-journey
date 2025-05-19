class_name BehaviorDrop
extends Behavior
## To have the NPC drop inventory items.

@export var item: String
@export var drop_velocity: Vector2 = Vector2(100, -1200)

var _uuid: String

@onready var item_drop: ItemDrop = find_children("*", "ItemDrop", false, false).front()


func _ready() -> void:
	super()
	
	if is_instance_valid(item_drop):
		item_drop.hide()

		# Disable collision on the interactable
		item_drop.collectible.monitoring = false
		item_drop.collectible.item_name = item

		if item and Inventory.available_items.has(item) and Inventory.available_items[item].texture:
			item_drop.sprite.texture = Inventory.available_items[item].texture
		

func drop() -> void:
	if not is_instance_valid(item_drop):
		return
	
	# Become the parent node's sibling
	item_drop.reparent(get_node("../.."))

	# Enable collision on the interactable
	item_drop.collectible.monitoring = true
	# Apply force
	item_drop.freeze = false
	item_drop.apply_impulse(drop_velocity)

	item_drop.show()

	# FIXME
	await get_tree().create_timer(0.5).timeout

	EventBus.behavior_event_ended.emit(_uuid)


func _on_behavior_event_started(args: Dictionary) -> void:
	if _does_event_match(args):
		_uuid = args.uuid
		drop()


func _on_event_list_updated(event_list: Array[String]) -> void:
	if not corresponding_game_event.is_empty() \
		and not Inventory.has_item(item) \
		and event_list.has(corresponding_game_event):
			# FIXME: The item will jump if you don't reset the velocity
			drop_velocity = Vector2.ZERO
			drop()
		
		
