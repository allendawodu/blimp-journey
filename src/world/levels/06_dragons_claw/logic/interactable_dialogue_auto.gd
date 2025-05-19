extends InteractableDialogue

@export var free_on_usage: bool


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	body.get_node("%Movement").is_mouse_down = false
	interact()
	
	if free_on_usage:
		queue_free()
