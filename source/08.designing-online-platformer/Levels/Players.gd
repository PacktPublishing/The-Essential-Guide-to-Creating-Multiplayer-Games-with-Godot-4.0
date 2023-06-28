extends Marker2D

@export var players_scene = preload("res://08.designing-online-platformer/Actors/Player/Player2D.tscn")


func _ready():
	await(get_tree().physics_frame)
	if multiplayer.get_peers().size() < 1:
		for i in Input.get_connected_joypads():
			var player = add_player()
			player.setup_controller(i)
		return
	if is_multiplayer_authority():
		for i in range(0, multiplayer.get_peers().size()):
			var player = add_player()
			var player_id = multiplayer.get_peers()[i]
			player.name = str(player_id)
			player.rpc("setup_multiplayer", player_id)


func add_player():
	var player = players_scene.instantiate()
	add_child(player)
	return player


func _on_multiplayer_spawner_spawned(node):
	await(get_tree().physics_frame)
	node.rpc("setup_multiplayer", node.name)
