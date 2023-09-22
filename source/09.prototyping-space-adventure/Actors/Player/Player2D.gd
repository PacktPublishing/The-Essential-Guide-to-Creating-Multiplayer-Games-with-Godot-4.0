extends Node2D

@export var thrust_action = "move_up"
@export var turn_left_action = "move_left"
@export var turn_right_action = "move_right"
@export var shoot_action = "shoot"


@onready var spaceship = $Spaceship
@onready var weapon = $Spaceship/Weapon2D
@onready var camera = $Camera2D

@onready var previous_position = spaceship.position
@onready var previous_rotation = spaceship.rotation


@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	var self_id = multiplayer.get_unique_id()
	var is_player = self_id == player_id
	set_process(is_player)
	set_physics_process(is_player)
	set_process_unhandled_input(is_player)
	camera.enabled = is_player
	if is_player:
		camera.make_current()
		$InterpolationTimer.start()
		$SynchronizationTimer.start()
	set_multiplayer_authority(player_id)


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		weapon.rpc("set_firing", true)
	elif event.is_action_released("shoot"):
		weapon.rpc("set_firing", false)


func _physics_process(delta):
	if Input.is_action_pressed(thrust_action):
		spaceship.thrust()
	if Input.is_action_pressed(turn_left_action):
		spaceship.turn(-1)
	elif Input.is_action_pressed(turn_right_action):
		spaceship.turn(1)


@rpc("any_peer", "call_remote")
func interpolate_position(target_position):
	var tween = create_tween()
	
	var interpolation = lerp(previous_position, target_position, 1.0)
	
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "position", interpolation, $InterpolationTimer.wait_time)
	tweener.from(previous_position)
	previous_position = target_position


@rpc("any_peer", "call_remote")
func interpolate_rotation(target_rotation):
	var tween = create_tween()
	
	var interpolation = lerp_angle(previous_rotation, target_rotation, 1.0)
	
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "rotation", interpolation, $InterpolationTimer.wait_time)
	tweener.from(previous_rotation)
	previous_rotation = target_rotation


@rpc("any_peer", "call_remote")
func synchronize_position(new_position):
	spaceship.position = new_position
	previous_position = new_position


@rpc("any_peer", "call_remote")
func synchronize_rotation(new_rotation):
	spaceship.rotation = new_rotation
	previous_rotation = new_rotation


func _on_interpolation_timer_timeout():
	rpc("interpolate_rotation", spaceship.rotation)
	rpc("interpolate_position", spaceship.position)


func _on_synchronization_timer_timeout():
#	rpc("synchronize_position", spaceship.position)
#	rpc("synchronize_rotation", spaceship.rotation)
	pass
