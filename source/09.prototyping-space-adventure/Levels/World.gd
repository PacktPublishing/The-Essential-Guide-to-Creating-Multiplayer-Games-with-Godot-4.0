extends Node

@onready var asteroid_spawner = $Asteroids
@onready var player_spawner = $Players

func _ready():
	for i in 30:
		asteroid_spawner.spawn()
	create_spaceship()


func create_spaceship():
	player_spawner.spawn()
