extends Control


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
