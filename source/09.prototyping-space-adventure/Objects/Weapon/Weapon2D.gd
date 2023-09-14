class_name Weapon2D
extends Marker2D

@export var bullet_scene: PackedScene
@export_range(0, 1, 1, "or_greater") var fire_rate = 3

@onready var spawner = $BulletSpawner2D
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer


func fire():
	animation_player.play("fire")
	spawner.spawn(bullet_scene)
	timer.start(1.0 / fire_rate)


@rpc("any_peer", "call_local")
func set_firing(firing):
	if firing:
		fire()
	else:
		timer.stop()


func _on_timer_timeout():
	fire()
