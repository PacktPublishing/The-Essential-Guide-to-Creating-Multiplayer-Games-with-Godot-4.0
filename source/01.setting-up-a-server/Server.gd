extends Node

const PORT = 9999

var peer = ENetMultiplayerPeer.new()


func _ready():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(peer_id):
	print("%s just connected!" % peer_id)
