extends Control


@export_file("*.json") var database_file = "res://02.sending-and-receiving-data/FakeDatabase.json"
@export var turn_delay_in_seconds = 5.0

@onready var database = JSON.parse_string(FileAccess.open(database_file,FileAccess.READ).get_as_text())
@onready var quiz_panel = $QuizPanel
@onready var timer = $Timer
@onready var wait_label = $WaitLabel


func _ready():
	timer.start(3.0)
	await(timer.timeout)
	generate_new_question()


@rpc("any_peer")
func answered(user):
	quiz_panel.rpc("update_winner", database[user]["name"])
	timer.start(turn_delay_in_seconds)
	wait_label.rpc("wait", turn_delay_in_seconds)


@rpc("any_peer")
func missed(user):
	quiz_panel.rpc("player_missed", database[user]["name"])
	timer.start(turn_delay_in_seconds)
	wait_label.rpc("wait", turn_delay_in_seconds)


func _on_timer_timeout():
	generate_new_question()


func generate_new_question():
	var max_index = quiz_panel.available_questions.size() -1
	var question_index = randi_range(0, max_index)
	quiz_panel.rpc("update_question", question_index)
	quiz_panel.update_question(question_index)
