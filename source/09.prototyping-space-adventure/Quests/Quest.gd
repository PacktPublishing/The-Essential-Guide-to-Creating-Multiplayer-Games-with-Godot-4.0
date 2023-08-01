extends Node

signal updated(quest_id, new_amount)
signal finished(quest_id)

@export var id = "asteroid_1"
@export var title = "Quest Title"
@export var description = "Insert Quest description here"
@export var target_amount = 1

var current_amount = 0 : set = set_current_amount
var completed = false


func set_current_amount(new_value):
	current_amount = new_value
	current_amount = clamp(current_amount, 0, target_amount)
	updated.emit(id, current_amount)
	if current_amount >= target_amount:
		finished.emit(id)
