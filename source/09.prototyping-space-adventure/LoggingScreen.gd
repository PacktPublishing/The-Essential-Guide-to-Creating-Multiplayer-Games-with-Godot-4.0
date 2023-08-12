extends Node

const ADDRESS = "127.0.0.1"
const PORT = 9999

@export_file("*.tscn") var next_scene

@onready var user_line_edit = $UserLineEdit
@onready var password_line_edit = $PasswordLineEdit
@onready var error_label = $ErrorLabel
@onready var login_button = $LoginButton
@onready var start_button = $StartButton

var peer = ENetMultiplayerPeer.new()


func _ready():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
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
	var user = user_line_edit.text
	var password = password_line_edit.text

	rpc_id(1, "authenticate_player", user, password)


@rpc
func authenticate_player(user, password):
	pass


@rpc
func authentication_failed(error_message):
	error_label.text = error_message


@rpc
func authentication_succeed(session_token):
	error_label.text = "Login successful!!"
	AuthenticationCredentials.user = user_line_edit.text
	AuthenticationCredentials.session_token = session_token
	user_line_edit.hide()
	password_line_edit.hide()
	login_button.hide()
	start_button.show()
	start_button.grab_focus()


func _on_StartButton_pressed():
	rpc_id(1, "start_game")


@rpc("authority", "call_local")
func start_game():
	get_tree().change_scene_to_file(next_scene)
