extends Subscene

var _login_attempts: int


func activate() -> void:
	Firebase.Auth.signup_succeeded.connect(_on_firebase_auth_signup_succeeded)
	Firebase.Auth.login_failed.connect(_on_firebase_auth_login_failed)

	owner.message_user("Generating login...")
	Firebase.Auth.login_anonymous()


func deactivate() -> void:
	if Firebase.Auth.signup_succeeded.is_connected(_on_firebase_auth_signup_succeeded):
		Firebase.Auth.signup_succeeded.disconnect(_on_firebase_auth_signup_succeeded)
	if Firebase.Auth.login_failed.is_connected(_on_firebase_auth_login_failed):
		Firebase.Auth.login_failed.disconnect(_on_firebase_auth_login_failed)


func _on_firebase_auth_signup_succeeded(auth_info: Dictionary) -> void:
	owner.message_user("Login successful.")
	owner.set_uid()
	
	await SaverLoader.reset_save_game()
	
	owner.switch_subscene("notice")


func _on_firebase_auth_login_failed(code, message: String) -> void:
	if _login_attempts >= 3:
		owner.switch_subscene("fresh")
		owner.message_user("Login failed. Error code: %s %s\nPlease try again later." % [code, message])
		return
	
	owner.message_user("Login failed. Error code: %s %s\nTrying again..." % [code, message])

	await get_tree().create_timer(2).timeout

	_login_attempts += 1
	Firebase.Auth.logout()
	Firebase.Auth.login_anonymous()
