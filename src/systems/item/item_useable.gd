class_name ItemUseable
extends Item
## Clicking on this item will cause the player character to try to use the item.

@export_node_path("Interactable") var interactable_node_path: NodePath
@export_range(0, 2048, 1, "or_greater") var max_distance_to_interactable: float = 512
## Timeline that has dialogue for when the item cannot be used right now.
## Auto jumps to the label with the item's name.
@export var timeline: DialogicTimeline
