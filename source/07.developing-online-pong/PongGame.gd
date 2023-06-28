extends Node


@export var goal_score = 15

@onready var player_1_paddle = $Paddle
@onready var player_2_paddle = $Paddle2
@onready var ball = $Ball
@onready var player_1_score = $ScoreArea
@onready var player_2_score = $ScoreArea2
@onready var winner_display = $Interface/WinnerDisplay
@onready var winner_label = $Interface/WinnerDisplay/Label


func _ready():
	randomize()
	await(get_tree().create_timer(0.1).timeout)
	if multiplayer.get_peers().size() > 0:
		if is_multiplayer_authority():
			var player_1 = multiplayer.get_peers()[0]
			var player_2 = multiplayer.get_peers()[1]
			player_1_paddle.rpc("setup_multiplayer", player_1)
			player_2_paddle.rpc("setup_multiplayer", player_2)
	ball.move()


func _on_score_area_scored(score):
	if player_1_score.score >= goal_score:
		display_winner("Player Two")
	elif player_2_score.score >= goal_score:
		display_winner("Player One")
	else:
		ball.reset()


func display_winner(winner):
	player_1_paddle.set_physics_process(false)
	player_2_paddle.set_physics_process(false)
	winner_display.show()
	winner_label.text = "%s won!!" % winner


func _on_button_pressed():
	get_tree().reload_current_scene()
