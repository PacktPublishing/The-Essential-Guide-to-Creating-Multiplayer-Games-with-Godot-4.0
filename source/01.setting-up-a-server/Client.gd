extends Node

const ADDRESS = "127.0.0.1"
const PORT = 9999

var peer = ENetMultiplayerPeer.new()


func _ready():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_connected_to_server():
	print("Connection stablished!")
