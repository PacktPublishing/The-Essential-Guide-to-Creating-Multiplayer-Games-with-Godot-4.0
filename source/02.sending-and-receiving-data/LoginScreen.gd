extends Control

const ADDRESS = "127.0.0.1"
const PORT = 9999

@export_file("*.tscn") var avatar_screen_scene

@onready var user_line_edit = $UserLineEdit
@onready var password_line_edit = $PasswordLineEdit
@onready var error_label = $ErrorLabel
@onready var login_button = $LoginButton


func _ready():
	error_label.text = "Insert username and password"
	user_line_edit.grab_focus()


func _on_UserLineEdit_text_submitted(new_text):
	if not password_line_edit.text == "":
		send_credentials()
	else:
		error_label.text = "Insert password"
		password_line_edit.grab_focus()


func _on_PasswordLineEdit_text_submitted(new_text):
	if not user_line_edit.text == "":
		send_credentials()
	else:
		error_label.text = "Insert username"
		user_line_edit.grab_focus()


func _on_LoginButton_pressed():
	if user_line_edit.text == "":
		error_label.text = "Insert username"
		user_line_edit.grab_focus()
	elif password_line_edit.text == "":
		error_label.text = "Insert password"
		password_line_edit.grab_focus()
	else:
		send_credentials()


func send_credentials():
	var message = {'authenticate_credentials': {'user': user_line_edit.text, 'password': password_line_edit.text}}
	
	var packet = PacketPeerUDP.new()
	packet.connect_to_host(ADDRESS, PORT)
	packet.put_var(JSON.stringify(message))
	
	while packet.wait() == OK:
		var response = JSON.parse_string(packet.get_var())
		if "token" in response:
			AuthenticationCredentials.session_token = response['token']
			AuthenticationCredentials.user = message['authenticate_credentials']['user']
			error_label.text = "logged!!"
			get_tree().change_scene_to_file(avatar_screen_scene)
			break
		else:
			error_label.text = "login failed, check your credentials"
			break
