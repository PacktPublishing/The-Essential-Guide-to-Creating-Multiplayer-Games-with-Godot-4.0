extends Node

const PORT = 9999

@export var database_file_path = "res://02.sending-and-receiving-data/FakeDatabase.json"

var database = {}
var logged_users = {}

var server = UDPServer.new()


func _ready():
	server.listen(PORT)
	load_database(database_file_path)


func _process(delta):
	server.poll()
	if server.is_connection_available():
		var peer = server.take_connection()
		var message = JSON.parse_string(peer.get_var())
		if "authenticate_credentials" in message:
			authenticate_player(peer, message)
		elif "get_authentication_token" in message:
			get_authentication_token(peer, message)
		elif "get_avatar" in message:
			get_avatar(peer, message)


func load_database(path_to_database_file):
	var file = FileAccess.open(path_to_database_file, FileAccess.READ)
	var file_content = file.get_as_text()
	database = JSON.parse_string(file_content)


func authenticate_player(peer, message):
	var credentials = message["authenticate_credentials"]
	if "user" in credentials and "password" in credentials:
		var user = credentials['user']
		var password = credentials['password']
		if user in database.keys():
			if database[user]['password'] == password:
				var token = randi()
				var response = {'token': token, 'user': user}
				logged_users[user] = token
				peer.put_var(JSON.stringify(response))
			else:
				peer.put_var("")


func get_authentication_token(peer, message):
	var credentials = message
	if "user" in credentials:
		if credentials['token'] == logged_users[credentials['user']]:
			var token = logged_users[credentials['user']]
			var response = {'token': token, 'user': credentials['user']}
			peer.put_var(JSON.stringify(token))


func get_avatar(peer, message):
	var dictionary = message
	if "user" in dictionary:
		var user = dictionary['user']
		if dictionary['token'] == logged_users[user]:
			var avatar = database[dictionary['user']]['avatar']
			var nick_name = database[dictionary['user']]['name']
			var response = {"avatar": avatar, "name": nick_name}
			peer.put_var(JSON.stringify(response))
