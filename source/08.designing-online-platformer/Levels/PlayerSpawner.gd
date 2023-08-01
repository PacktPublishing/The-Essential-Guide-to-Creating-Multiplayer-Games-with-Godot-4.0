extends Marker2D

@export var players_scene = preload("res://08.designing-online-platformer/Actors/Player/Player2D.tscn")


func _ready():
	await(get_tree().create_timer(0.1).timeout)
	if multiplayer.get_peers().size() < 1:
		if Input.get_connected_joypads().size() < 1:
			var player = players_scene.instantiate()
			add_child(player)
			return
		for i in Input.get_connected_joypads():
			var player = players_scene.instantiate()
			add_child(player)
			player.setup_controller(i)
		return
	if is_multiplayer_authority():
		for i in range(0, multiplayer.get_peers().size()):
			var player = players_scene.instantiate()
			var player_id = multiplayer.get_peers()[i]
			player.name = str(player_id)
			add_child(player)
			await(get_tree().create_timer(0.1).timeout)
			player.rpc("setup_multiplayer", player_id)
