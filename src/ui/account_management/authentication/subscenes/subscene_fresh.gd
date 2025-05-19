extends Subscene


func _ready() -> void:
	$TryButton.pressed.connect(owner.switch_subscene.bind("tryout"))
	$LoginButton.pressed.connect(owner.switch_subscene.bind("login"))
	$SignUpButton.pressed.connect(owner.switch_subscene.bind("signup"))


func activate() -> void:
	pass
