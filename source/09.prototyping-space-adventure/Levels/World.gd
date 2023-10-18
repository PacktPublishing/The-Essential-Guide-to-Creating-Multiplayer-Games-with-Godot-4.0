extends Node

@onready var asteroid_spawner = $Asteroids
@onready var player_spawner = $Players

var player_users = {}


func _ready():
	if not multiplayer.is_server():
		var server_connection = multiplayer.multiplayer_peer.get_peer(1)
		var latency = server_connection.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / (1000 * 2)
		await get_tree().create_timer(latency).timeout
		rpc_id(1, "sync_world")
		rpc_id(1, "create_spaceship", AuthenticationCredentials.user)
	else:
		var callable = Callable(self, "get_received_data")
		Performance.add_custom_monitor("Network/Received Data", callable)
		callable = Callable(self, "get_sent_data")
		Performance.add_custom_monitor("Network/Sent Data", callable)

		for i in 30:
			asteroid_spawner.spawn()


func get_received_data():
	var enet_connection = multiplayer.multiplayer_peer.host
	var data_received = enet_connection.pop_statistic(ENetConnection.HOST_TOTAL_RECEIVED_DATA)
	return data_received


func get_sent_data():
	var enet_connection = multiplayer.multiplayer_peer.host
	var data_sent = enet_connection.pop_statistic(ENetConnection.HOST_TOTAL_SENT_DATA)
	return data_sent


@rpc("any_peer", "call_remote")
func create_spaceship(user):
	var player_id = multiplayer.get_remote_sender_id()
	var spaceship = preload("res://09.prototyping-space-adventure/Actors/Player/Player2D.tscn").instantiate()
	spaceship.name = str(player_id)
	player_users[spaceship.name] = user
	$Players.add_child(spaceship)
#	await(get_tree().create_timer(0.1).timeout)
	spaceship.rpc("setup_multiplayer", player_id)
	spaceship.rpc("load_spaceship", user)


@rpc("any_peer", "call_local")
func sync_world():
	var player_id = multiplayer.get_remote_sender_id()

	get_tree().call_group("Sync", "set_visibility_for", player_id, true)
	get_tree().call_group("Sync", "update_visibility", player_id)


func _on_players_multiplayer_spawner_spawned(node):
	var player_id = int(str(node.name))
	node.rpc("setup_multiplayer", player_id)
	if not multiplayer.is_server():
		rpc_id(1, "sync_spaceship", player_id)


@rpc("any_peer", "call_local")
func sync_spaceship(player_id):
	var requester = multiplayer.get_remote_sender_id()
	var node = get_node("Players/%s" % player_id)
	var user = player_users[node.name]
	node.rpc_id(requester, "load_spaceship", user)
