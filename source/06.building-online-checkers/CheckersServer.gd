extends Control

const PORT = 9999

@export var database_file_path = "res://02.sending-and-receiving-data/FakeDatabase.json"
@export_file("*.tscn") var next_screen_scene_path = "res://06.building-online-checkers/CheckerBoard.tscn"

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
		rpc("clear_logged_players")
		for logged_user in logged_users.keys():
			rpc("add_logged_player", database[logged_user]['name'])


@rpc("any_peer", "call_remote")
func start_game():
	rpc("start_game")
	get_tree().change_scene_to_file(next_screen_scene_path)


@rpc
func authentication_failed(error_message):
	pass


@rpc
func authentication_succeed(session_token):
	pass


@rpc
func add_logged_player(player_name):
	pass


@rpc
func clear_logged_players():
	pass
