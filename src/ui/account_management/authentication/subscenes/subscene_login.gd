extends Subscene

const VISIBILITY_ON: Texture2D = preload("res://src/ui/icons/visibility.png")
const VISIBILITY_OFF: Texture2D = preload("res://src/ui/icons/visibility_off.png")

func _ready() -> void:
	$LoginButton.pressed.connect(_on_login_button_pressed)
	$PasswordLineEdit/TogglePasswordVisibilityButton.pressed.connect(_on_toggle_password_visibility_button_pressed)
	$EmailLineEdit.focus_exited.connect(_on_email_line_edit_focus_exited)
	$PasswordLineEdit.focus_exited.connect(_on_password_line_edit_focus_exited)
	$PasswordLineEdit.text_submitted.connect(_on_login_button_pressed)
	$EmailLineEdit.text_changed.connect(_on_line_edit_text_changed)
	$PasswordLineEdit.text_changed.connect(_on_line_edit_text_changed)
	$SignUpButton.pressed.connect(owner.switch_subscene.bind("signup"))


func activate() -> void:
	Firebase.Auth.login_succeeded.connect(_on_firebase_auth_login_succeeded)
	Firebase.Auth.login_failed.connect(_on_firebase_auth_login_failed)
	Firebase.Auth.userdata_received.connect(_on_firebase_auth_userdata_received)
	

func deactivate() -> void:
	if Firebase.Auth.login_succeeded.is_connected(_on_firebase_auth_login_succeeded):
		Firebase.Auth.login_succeeded.disconnect(_on_firebase_auth_login_succeeded)
	if Firebase.Auth.login_failed.is_connected(_on_firebase_auth_login_failed):
		Firebase.Auth.login_failed.disconnect(_on_firebase_auth_login_failed)
	if Firebase.Auth.userdata_received.is_connected(_on_firebase_auth_userdata_received):
		Firebase.Auth.userdata_received.disconnect(_on_firebase_auth_userdata_received)


func _on_login_button_pressed() -> void:
	if not _is_email_valid() or not _is_password_valid():
		return
	
	owner.message_user("Logging in...")
	Firebase.Auth.login_with_email_and_password($EmailLineEdit.text, $PasswordLineEdit.text)


func _on_firebase_auth_login_succeeded(auth: Dictionary) -> void:
	if $HBoxContainer/CheckBox.button_pressed:
		if Firebase.Auth.save_auth(auth) == false:
			owner.message_user("Couldn't save login details onto device.")
			await get_tree().create_timer(2).timeout

	owner.set_uid()
	Firebase.Auth.get_user_data()


func _on_firebase_auth_login_failed(code: Variant, message: String) -> void:
	# TODO: Check the error code before sending the server error message
	_message_user("Server error: $s" % message)


func _on_email_line_edit_focus_exited() -> void:
	if not _is_email_valid(true):
		$LoginButton.disabled = true


func _on_password_line_edit_focus_exited() -> void:
	if not _is_password_valid(true):
		$LoginButton.disabled = true


func _on_line_edit_text_changed(new_text: String) -> void:
	$LoginButton.disabled = not _is_email_valid() or not _is_password_valid()
	_message_user()


func _is_email_valid(should_message_user: bool = false) -> bool:
	var email = $EmailLineEdit.text
	var at_index = email.find("@")
	
	if email == "":
		if should_message_user:
			_message_user("Incorrect login details.")
		return false
	if at_index == -1\
		or email.count("@") > 1\
		or email.length() < 5\
		or email.find(" ") != -1:
			if should_message_user:
				_message_user("Incorrect login details.")
			return false
	return true


func _is_password_valid(should_message_user: bool = false) -> bool:
	var password_length = $PasswordLineEdit.text.length()
	if password_length < 8:
		if should_message_user:
			_message_user("Incorrect login details.")
		return false
	if password_length > 128:
		if should_message_user:
			_message_user("Incorrect login details.")
		return false
	return true


func _message_user(message: String = "") -> void:
	$MessageLabel.text = message


func _on_toggle_password_visibility_button_pressed() -> void:
	$PasswordLineEdit.secret = not $PasswordLineEdit.secret
	$PasswordLineEdit/TogglePasswordVisibilityButton.texture_normal = VISIBILITY_OFF if $PasswordLineEdit.secret else VISIBILITY_ON


func _on_firebase_auth_userdata_received(user_data: FirebaseUserData) -> void:
	if user_data.email_verified:
		owner.switch_subscene("notice")
	else:
		await get_tree().create_timer(0.1).timeout
		Firebase.Auth.send_account_verification_email()
		owner.switch_subscene("verify")
		owner.message_user("Email not verified. Please check your email for the verification link.")
