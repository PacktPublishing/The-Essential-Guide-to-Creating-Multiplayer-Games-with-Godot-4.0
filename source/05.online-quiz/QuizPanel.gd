extends ColorRect

signal answered(is_answer_correct)


@export_file var questions_database = "res://05.online-quiz/QuizQuestions.json"

@onready var answer_container = $Answers
@onready var question_label = $QuestionLabel

var questions = {}
var available_questions = []
var correct_answer = 0

func _ready():
	var questions_as_text = FileAccess.open(questions_database, FileAccess.READ).get_as_text()
	questions = JSON.parse_string(questions_as_text)
	for question in questions:
		available_questions.append(question)
	connect_answer_buttons()
	lock_answers()


func lock_answers():
	for answer in answer_container.get_children():
		answer.disabled = true


func unlock_answers():
	for answer in answer_container.get_children():
		answer.disabled = false


@rpc("call_local")
func update_winner(winner_name):
	question_label.text = "%s won the round!!" % winner_name
	lock_answers()


@rpc("call_local")
func player_missed(loser_name):
	question_label.text = "%s missed the question!!" % loser_name
	lock_answers()


@rpc("any_peer", "call_local")
func update_question(new_question_index):
	var question = available_questions.pop_at(new_question_index)
	if not question == null:
		question_label.text = questions[question]['text']
		correct_answer = questions[question]['correct_answer_index']
		for i in range(0, 4):
			var alternative = questions[question]['alternatives'][i]
			answer_container.get_child(i).text = alternative
		unlock_answers()
	else:
		for answer in answer_container.get_children():
			question_label.text = "No more questions"
		lock_answers()


func connect_answer_buttons():
	for button in answer_container.get_children():
		button.pressed.connect(_on_answer_button_pressed.bind(button.get_index()))


func evaluate_answer(answer_index):
	var is_answer_correct = answer_index == correct_answer
	answered.emit(is_answer_correct)


func _on_answer_button_pressed(button_index):
	evaluate_answer(button_index)
