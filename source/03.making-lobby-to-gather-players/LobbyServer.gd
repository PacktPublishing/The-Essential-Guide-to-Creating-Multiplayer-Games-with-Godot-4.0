extends Control

const PORT = 9999

@export var database_file_path = "res://02.sending-and-receiving-data/FakeDatabase.json"

var peer = ENetMultiplayerPeer.new()
var database = {}
var logged_users = {}


func _ready():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	load_database()


func load_database(path_to_database_file = database_file_path):
	var file = FileAccess.open(path_to_database_file, FileAccess.READ)
	var file_content = file.get_as_text()
	database = JSON.parse_string(file_content)


@rpc("call_remote")
func add_avatar(avatar_name, texture_path):
	pass


@rpc("call_remote")
func clear_avatars():
	pass


@rpc("any_peer", "call_remote")
func retrieve_avatar(user, session_token):
	var peer_id = multiplayer.get_remote_sender_id()
	
	if not user in logged_users:
		return
	if session_token == logged_users[user]:
		rpc("clear_avatars")
		for logged_user in logged_users:
			var avatar_name = database[logged_user]['name']
			var avatar_texture_path = database[logged_user]['avatar']
			rpc("add_avatar", avatar_name, avatar_texture_path)


@rpc("any_peer", "call_remote")
func authenticate_player(user, password):
	var peer_id = multiplayer.get_remote_sender_id()
	
	if not user in database:
		rpc_id(peer_id, "authentication_failed", "User doesn't exist")
	elif database[user]['password'] == password:
		var token = randi()
		logged_users[user] = token
		rpc_id(peer_id, "authentication_succeed", token)


@rpc("call_remote")
func authentication_failed(error_message):
	pass


@rpc("call_remote")
func authentication_succeed(session_token):
	pass
