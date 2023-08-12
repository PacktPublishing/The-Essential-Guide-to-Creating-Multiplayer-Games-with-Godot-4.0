extends Node2D

@export var thrust_action = "move_up"
@export var turn_left_action = "move_left"
@export var turn_right_action = "move_right"
@export var shoot_action = "shoot"


@onready var spaceship = $Spaceship
@onready var weapon = $Spaceship/Weapon2D
@onready var camera = $Camera2D


@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	var self_id = multiplayer.get_unique_id()
	var is_player = self_id == player_id
	set_process(is_player)
	set_physics_process(is_player)
	camera.enabled = is_player
	if is_player:
		camera.make_current()
	set_multiplayer_authority(player_id)


func _process(delta):
	if Input.is_action_pressed(shoot_action):
		weapon.rpc("fire")


func _physics_process(delta):
	if Input.is_action_pressed(thrust_action):
		spaceship.thrust()
	if Input.is_action_pressed(turn_left_action):
		spaceship.turn(-1)
	elif Input.is_action_pressed(turn_right_action):
		spaceship.turn(1)
