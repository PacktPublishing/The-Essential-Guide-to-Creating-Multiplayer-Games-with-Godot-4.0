extends Node


func _ready():
	if not is_multiplayer_authority():
		await(get_tree().create_timer(0.1).timeout)
		rpc_id(1, "create_spaceship")
		rpc_id(1, "sync_world")
	else:
		for i in 30:
			var asteroid = $Asteroids.spawn()
			asteroid.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(-300, 300)


# Server
@rpc("any_peer", "call_remote")
func create_spaceship():
	var player_id = multiplayer.get_remote_sender_id()
	var spaceship = preload("res://09.prototyping-space-adventure/Actors/Player/Player2D.tscn").instantiate()
	spaceship.name = str(player_id)
	$Players.add_child(spaceship)
	await(get_tree().create_timer(0.1).timeout)
	spaceship.rpc("setup_multiplayer", player_id)


# Server
@rpc("any_peer", "call_local")
func sync_world():
	var player_id = multiplayer.get_remote_sender_id()
	get_tree().call_group("sync", "set_visibility_for", player_id, true)
	Quests.rpc_id(player_id, "retrieve_quests")


# Call locally when the MultiplayerSpawner creates a new Node
func _on_player_spawner_spawned(node):
	if node.has_method("setup_multiplayer"):
		node.rpc("setup_multiplayer", int(str(node.name)))
