extends RigidBody2D

@export var dialogue_index = 0

@onready var label_animator = $Interface/Label/AnimationPlayer
@onready var animator = $AnimationPlayer
@onready var animation_list = label_animator.get_animation_list()
@onready var exclamation = $Interface/ExclamationBalloon
@onready var label = $Interface/Label


func _on_interactive_area_2d_interaction_available():
	exclamation.visible = true
	exclamation.play("in")


func _on_interactive_area_2d_interacted():
	if exclamation.visible:
		exclamation.play("out")
	if label.scale.x == 1.0:
		animator.play_backwards("pop_label")
		await(animator.animation_finished)
		queue_free()
	if dialogue_index == 0:
		exclamation.visible = false
		animator.play("pop_label")
		await animator.animation_finished
	elif dialogue_index >= animation_list.size() - 1:
		exclamation.visible
		exclamation.play("out")
	label_animator.play(animation_list[dialogue_index])
	dialogue_index += 1
	dialogue_index = wrapi(dialogue_index, 0, animation_list.size() -1)
	animator.play("display_text")


func _on_interactive_area_2d_interaction_unavailable():
	if exclamation.visible:
		exclamation.play("out")
