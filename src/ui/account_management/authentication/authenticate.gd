extends Control

const COLLECTION_ID: String = "saves"
const OPTIONS_MENU_MINI: PackedScene = preload("res://src/ui/maaack/overlaid_menus/mini_options_overlaid_menu.tscn")
const CREDITS: PackedScene = preload("res://src/ui/maaack/credits/credits.tscn")

@export var next_scene: PackedScene
@export var subscenes: Dictionary


func _ready() -> void:
	Firebase.Auth.auth_request.connect(_on_firebase_auth_auth_request)
	
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%InfoButton.pressed.connect(_on_info_button_pressed)

	%VersionLabel.text = "v%s" % ProjectSettings.get_setting("application/config/version")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# DEBUG
	# Firebase.set_emulated()

	attempt_login()


func attempt_login() -> void:
	if Firebase.Auth.is_logged_in():
		set_uid()
		switch_subscene("ready")
		return

	if Firebase.Auth.check_auth_file():
		# Check if the save data can even be retrieved from the server
		message_user("Retrieving save file...")
		var collection: FirestoreCollection = await Firebase.Firestore.collection(COLLECTION_ID)
		var document: FirestoreDocument = await collection.get_doc(Firebase.Auth.auth.localid)
		
		if document:
			set_uid()
			message_user()
			switch_subscene("ready")
		else:
			message_user("Save file not found.")
			Firebase.Auth.logout()
			switch_subscene("fresh")
	else:
		switch_subscene("fresh")


func switch_subscene(to: String) -> void:
	message_user()

	if subscenes.has(to):
		%Subscenes.get_children().map(func(child):
			child.hide()
			child.deactivate()
		)
		get_node(subscenes[to]).activate()
		get_node(subscenes[to]).show()
	else:
		printerr("[Authenticate] Subscene not found: %s" % to)


func message_user(message: String = "") -> void:
	%MessageLabel.text = message


func switch_to_next_scene() -> void:
	message_user("Loading...")

	# Gives time for the loading message to appear
	await get_tree().create_timer(0.1).timeout
	
	Loading.load_scene("res://src/world/overworld_map/overworld_map.tscn", true)


func set_uid() -> void:
	%UIDLabel.text = "UID: %s" % Firebase.Auth.auth.localid


func _on_settings_button_pressed() -> void:
	var options_scene = OPTIONS_MENU_MINI.instantiate()
	add_child(options_scene)


func _on_info_button_pressed() -> void:
	pass


func _on_firebase_auth_auth_request(code: Variant, result: Variant) -> void:
	if result is String and result == "USER_NOT_FOUND":
		Firebase.Auth.remove_auth()
		switch_subscene("login")
		message_user("Save file not found.")
