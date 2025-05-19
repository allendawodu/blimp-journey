extends Subscene

const VISIBILITY_ON: Texture2D = preload("res://src/ui/icons/visibility.png")
const VISIBILITY_OFF: Texture2D = preload("res://src/ui/icons/visibility_off.png")


func _ready() -> void:
	$SignUpButton.pressed.connect(_on_signup_button_pressed)
	$PasswordLineEdit/TogglePasswordVisibilityButton.pressed.connect(_on_toggle_password_visibility_button_pressed)
	$EmailLineEdit.focus_exited.connect(_on_email_line_edit_focus_exited)
	$PasswordLineEdit.focus_exited.connect(_on_password_line_edit_focus_exited)
	$PasswordLineEdit.text_submitted.connect(_on_signup_button_pressed)
	$EmailLineEdit.text_changed.connect(_on_line_edit_text_changed)
	$PasswordLineEdit.text_changed.connect(_on_line_edit_text_changed)
	$LoginButton.pressed.connect(owner.switch_subscene.bind("login"))


func activate() -> void:
	Firebase.Auth.signup_succeeded.connect(_on_firebase_auth_signup_succeeded)
	Firebase.Auth.signup_failed.connect(_on_firebase_auth_signup_failed)


func deactivate() -> void:
	if Firebase.Auth.signup_succeeded.is_connected(_on_firebase_auth_signup_succeeded):
		Firebase.Auth.signup_succeeded.disconnect(_on_firebase_auth_signup_succeeded)
	if Firebase.Auth.signup_failed.is_connected(_on_firebase_auth_signup_failed):
		Firebase.Auth.signup_failed.disconnect(_on_firebase_auth_signup_failed)


func _on_signup_button_pressed() -> void:
	if not _is_email_valid() or not _is_password_valid():
		return
	
	Firebase.Auth.signup_with_email_and_password($EmailLineEdit.text, $PasswordLineEdit.text)


func _on_firebase_auth_signup_succeeded(auth: Dictionary) -> void:
	if $HBoxContainer/CheckBox.button_pressed:
		if Firebase.Auth.save_auth(auth) == false:
			owner.message_user("Couldn't save login details onto device.")
			await get_tree().create_timer(2).timeout
	
	Firebase.Auth.send_account_verification_email()
	SaverLoader.reset_save_game()

	owner.set_uid()
	owner.switch_subscene("verify")
	owner.message_user("Sending email verification...")


func _on_firebase_auth_signup_failed(code: Variant, message: String) -> void:
	match message:
		"EMAIL_EXISTS":
			_message_user("Email already in use. Login instead.")
		_:
			# TODO: Check the error code before sending the server error message
			_message_user("Server error: %d %s" % [code, message])


func _on_email_line_edit_focus_exited() -> void:
	if not _is_email_valid(true):
		$SignUpButton.disabled = true


func _on_password_line_edit_focus_exited() -> void:
	if not _is_password_valid(true):
		$SignUpButton.disabled = true


func _on_line_edit_text_changed(new_text: String) -> void:
	$SignUpButton.disabled = not _is_email_valid() or not _is_password_valid()
	_message_user()


func _is_email_valid(should_message_user: bool = false) -> bool:
	var email = $EmailLineEdit.text
	var at_index = email.find("@")
	
	if email == "":
		if should_message_user:
			_message_user("Please enter an email.")
		return false
	if at_index == -1\
		or email.count("@") > 1\
		or email.length() < 5\
		or email.find(" ") != -1:
			if should_message_user:
				_message_user("Please enter a valid email.")
			return false
	return true


func _is_password_valid(should_message_user: bool = false) -> bool:
	var password_length = $PasswordLineEdit.text.length()
	if password_length < 8:
		if should_message_user:
			_message_user("Password must be at least 8 characters.")
		return false
	if password_length > 128:
		if should_message_user:
			_message_user("Password must be less than 128 characters.")
		return false
	if $PasswordLineEdit.text == $EmailLineEdit.text:
		if should_message_user:
			_message_user("Password cannot be the same as the email.")
		return false
	return true


func _message_user(message: String = "") -> void:
	$MessageLabel.text = message


func _on_toggle_password_visibility_button_pressed() -> void:
	$PasswordLineEdit.secret = not $PasswordLineEdit.secret
	$PasswordLineEdit/TogglePasswordVisibilityButton.texture_normal = VISIBILITY_OFF if $PasswordLineEdit.secret else VISIBILITY_ON
