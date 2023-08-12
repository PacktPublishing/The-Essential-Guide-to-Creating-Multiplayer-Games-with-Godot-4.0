extends Node

const PORT = 9999
const ADDRESS = "127.0.0.1"

@export var database_file_path = "res://02.sending-and-receiving-data/FakeDatabase.json"

var peer = ENetMultiplayerPeer.new()
var database = {}
var logged_users = {}


func _ready():
	if multiplayer.is_server():
		peer.create_server(PORT)
		multiplayer.multiplayer_peer = peer
		load_database()
	else:
		peer.create_client(ADDRESS, PORT)
		multiplayer.multiplayer_peer = peer


func load_database(path_to_database_file = database_file_path):
	var file = FileAccess.open(path_to_database_file, FileAccess.READ)
	var file_content = file.get_as_text()
	database = JSON.parse_string(file_content)


@rpc("any_peer", "call_remote")
func authenticate_player(user, password):
	var peer_id = multiplayer.get_remote_sender_id()
	
	if not user in database:
		rpc_id(peer_id, "authentication_failed", "User doesn't exist")
	elif not database[user]['password'] == password:
		rpc_id(peer_id, "authentication_failed", "Password doesn't match")
	elif user in logged_users:
		rpc_id(peer_id, "authentication_failed", "User is already logged")
	elif database[user]['password'] == password:
		var token = randi()
		logged_users[user] = token
		rpc_id(peer_id, "authentication_succeed", token)


@rpc("any_peer", "call_remote")
func start_game():
	var peer_id = multiplayer.get_remote_sender_id()
	rpc_id(peer_id, "start_game")


@rpc
func authentication_failed(error_message):
	pass


@rpc
func authentication_succeed(session_token):
	pass
