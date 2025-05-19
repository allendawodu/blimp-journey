extends ItemMenu

@export var corresponding_items: Array[String] = [
	"06_journal_1",
	"06_journal_2",
	"06_journal_3",
]


func _ready() -> void:
	super()
	Inventory.updated.connect(_on_inventory_updated)


func _on_inventory_updated(item: String, amount: int) -> void:
	if item in corresponding_items and not Inventory.has_item("06_journal"):
		Inventory.add_item("06_journal")
