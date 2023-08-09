extends Node2D

@export var thrust_action = "move_up"
@export var turn_left_action = "move_left"
@export var turn_right_action = "move_right"
@export var shoot_action = "shoot"


@onready var spaceship = $Spaceship
@onready var weapon = $Spaceship/Weapon2D
@onready var camera = $Camera2D


func _process(delta):
	if Input.is_action_pressed(shoot_action):
		weapon.fire()


func _physics_process(delta):
	if Input.is_action_pressed(thrust_action):
		spaceship.thrust()
	if Input.is_action_pressed(turn_left_action):
		spaceship.turn(-1)
	elif Input.is_action_pressed(turn_right_action):
		spaceship.turn(1)
