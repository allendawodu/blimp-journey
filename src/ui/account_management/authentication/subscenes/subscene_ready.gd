extends Subscene


func _ready() -> void:
	$PlayButton.pressed.connect(owner.switch_subscene.bind("notice"))
	$LogoutButton.pressed.connect(_on_logout_button_pressed)


func activate() -> void:
	pass


func _on_logout_button_pressed() -> void:
	Firebase.Auth.logout()
	owner.switch_subscene("fresh")
