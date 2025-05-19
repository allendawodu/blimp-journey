extends Subscene


func _ready() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/ResendButton.pressed.connect(_on_resend_button_pressed)
	$MarginContainer/VBoxContainer/HBoxContainer/ConfirmationButton.pressed.connect(_on_confirmation_button_pressed)
	$MarginContainer/VBoxContainer/BackButton.pressed.connect(owner.switch_subscene.bind("signup"))


func activate() -> void:
	Firebase.Auth.userdata_received.connect(_on_firebase_auth_userdata_received)
	Firebase.Auth.login_failed.connect(_on_firebase_auth_login_failed)
	Firebase.Auth.auth_request.connect(_on_firebase_auth_auth_request)


func deactivate() -> void:
	if Firebase.Auth.userdata_received.is_connected(_on_firebase_auth_userdata_received):
		Firebase.Auth.userdata_received.disconnect(_on_firebase_auth_userdata_received)
	if Firebase.Auth.login_failed.is_connected(_on_firebase_auth_login_failed):
		Firebase.Auth.login_failed.disconnect(_on_firebase_auth_login_failed)
	if Firebase.Auth.auth_request.is_connected(_on_firebase_auth_auth_request):
		Firebase.Auth.auth_request.disconnect(_on_firebase_auth_auth_request)


func _on_resend_button_pressed() -> void:
	owner.message_user("Sending verification email...")
	Firebase.Auth.send_account_verification_email()


func _on_confirmation_button_pressed() -> void:
	owner.message_user("Checking email verification...")
	Firebase.Auth.get_user_data()


func _on_firebase_auth_userdata_received(user_data: FirebaseUserData) -> void:
	if user_data.email_verified:
		owner.switch_subscene("notice")
	else:
		owner.message_user("Email not verified. Please check your email for the verification link.")


func _on_firebase_auth_login_failed(code: Variant, message: String) -> void:
	owner.message_user("Server error: %s" % message)


func _on_firebase_auth_auth_request(code: Variant, result: Variant) -> void:
	if code == 1 and result.has("kind") and result.kind == Firebase.Auth.RESPONSE_EMAIL_VERIFICATION:
		$MarginContainer/VBoxContainer/EmailLabel.text = result.email
		owner.message_user("Email verification sent.")


func _on_line_edit_text_changed(new_text: String) -> void:
	$MarginContainer/VBoxContainer/EmailLabel.text = new_text
