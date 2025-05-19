extends ItemMenu


func _ready() -> void:
	super()

	%ApplicationButton.pressed.connect(_on_application_button_pressed)

	for page_button: PageButton in find_children("PageButton"):
		page_button.clicked.connect(_on_page_button_clicked)


func _on_page_button_clicked(page_to_show: Control) -> void:
	for page: Control in %Pages.get_children():
		page.hide()
	
	page_to_show.show()


func _on_application_button_pressed() -> void:
	Inventory.add_item("application")
	%ApplicationButton.queue_free()
