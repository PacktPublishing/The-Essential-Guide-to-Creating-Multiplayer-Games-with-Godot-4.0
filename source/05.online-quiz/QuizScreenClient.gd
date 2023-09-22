extends Control


func _ready():
	await(get_tree().create_timer(0.1).timeout)
	rpc_id(get_multiplayer_authority(), "get_player_name", AuthenticationCredentials.user)


func _on_quiz_panel_answered(is_answer_correct):
	if is_answer_correct:
		rpc_id(
			get_multiplayer_authority(),
				"answered",
				AuthenticationCredentials.user
			)
	else:
		rpc_id(
			get_multiplayer_authority(),
				"missed",
				AuthenticationCredentials.user
			)


@rpc
func answered(user):
	pass


@rpc
func missed(user):
	pass


@rpc("any_peer", "call_remote")
func get_player_name(user):
	pass


@rpc("authority", "call_remote")
func set_player_name(player_name):
	$Label.text = "Player: %s" % player_name
