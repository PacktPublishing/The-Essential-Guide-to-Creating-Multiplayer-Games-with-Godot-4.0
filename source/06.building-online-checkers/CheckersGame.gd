extends Node


@onready var hud = $HUD
@onready var winner_label = $HUD/Label


@rpc("any_peer", "call_local")
func update_winner(winner):
	winner_label.text = "%s won the match!" % winner
	hud.show()


@rpc("any_peer", "call_local")
func rematch():
	get_tree().reload_current_scene()


func _on_rematch_button_pressed():
	rpc("rematch")


func _on_checker_board_player_won(winner):
	rpc("update_winner", winner)
