extends Node2D


@export var speed = 500.0
@export var up_action = "move_up"
@export var down_action = "move_down"

@onready var body = $CharacterBody2D


@rpc("call_local")
func setup_multiplayer(player_id):
	set_multiplayer_authority(player_id)
	if not is_multiplayer_authority():
		set_physics_process(false)
		set_process_unhandled_input(false)


func _physics_process(delta):
	body.move_and_slide()


func _unhandled_input(event):
	if event.is_action_pressed(up_action):
		body.velocity.y = -speed
	elif event.is_action_released(up_action):
		if Input.is_action_pressed(down_action):
			body.velocity.y = speed
		else:
			body.velocity.y = 0.0
	if event.is_action_pressed(down_action):
		body.velocity.y = speed
	elif event.is_action_released(down_action):
		if Input.is_action_pressed(up_action):
			body.velocity.y = -speed
		else:
			body.velocity.y = 0.0
