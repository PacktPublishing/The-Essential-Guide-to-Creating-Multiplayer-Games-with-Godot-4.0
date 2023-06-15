extends Area2D

signal scored(score)

@export var score = 0


func _on_body_entered(body):
	score += 1
	scored.emit(score)
