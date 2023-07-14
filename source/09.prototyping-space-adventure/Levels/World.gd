extends Node2D


func _ready():
	if is_multiplayer_authority():
		for i in 1:
			var asteroid = $Asteroids.spawn()
			asteroid.position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(-100, 100)
	else:
		await(get_tree().create_timer(0.1).timeout)
		rpc_id(1, "create_spaceship")


@rpc("any_peer", "call_remote")
func create_spaceship():
	var player_id = multiplayer.get_remote_sender_id()
	var spaceship = $Players.spawn()
	spaceship.name = str(player_id)
	spaceship.set_multiplayer_authority(player_id)
	$Players.add_child(spaceship)
	await(get_tree().create_timer(0.1).timeout)
	spaceship.rpc("setup_multiplayer", player_id)
