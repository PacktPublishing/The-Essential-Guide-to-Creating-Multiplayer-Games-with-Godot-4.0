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
	var is_server = multiplayer.is_server()
	set_process(is_server)
	set_physics_process(is_server)
	set_process_unhandled_input(not is_server)
	camera.enabled = not is_server
	if is_server:
		$InterpolationTimer.start()
		$SynchronizationTimer.start()
	else:
		camera.make_current()


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		weapon.rpc("set_firing", true)
	elif event.is_action_released("shoot"):
		weapon.rpc("set_firing", false)
	
	if event.is_action_pressed(thrust_action):
		spaceship.rpc_id(1, "set_thrusting", true)
	elif event.is_action_released(thrust_action):
		spaceship.rpc_id(1, "set_thrusting", false)
	
	# Turning logic. If a turning key is just pressed or still pressed, the spaceship should turn.
	if event.is_action_pressed(turn_left_action):
		spaceship.rpc_id(1, "set_direction", -1)
		spaceship.rpc_id(1, "set_turning", true)
	elif event.is_action_released(turn_left_action):
		if Input.is_action_pressed(turn_right_action):
			spaceship.rpc_id(1, "set_direction", 1)
		else:
			spaceship.rpc_id(1, "set_turning", false)
			spaceship.rpc_id(1, "set_direction", 0)
	if event.is_action_pressed(turn_right_action):
		spaceship.rpc_id(1, "set_direction", 1)
		spaceship.rpc_id(1, "set_turning", true)
	elif event.is_action_released(turn_right_action):
		if Input.is_action_pressed(turn_left_action):
			spaceship.rpc_id(1, "set_direction", -1)
		else:
			spaceship.rpc_id(1, "set_turning", false)
			spaceship.rpc_id(1, "set_direction", 0)


@rpc("authority", "call_remote")
func interpolate_position(target_position, duration_in_seconds):
	var tween = create_tween()
	
	var interpolation = lerp(previous_position, target_position, 1.0)
	
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "position", interpolation, duration_in_seconds)
	tweener.from(previous_position)
	previous_position = target_position


@rpc("authority", "call_remote")
func interpolate_rotation(target_rotation, duration_in_seconds):
	var tween = create_tween()
	
	var interpolation = lerp_angle(previous_rotation, target_rotation, 1.0)
	
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "rotation", interpolation, duration_in_seconds)
	tweener.from(previous_rotation)
	previous_rotation = target_rotation


@rpc("authority", "call_remote")
func synchronize_position(new_position):
	for tween in get_tree().get_processed_tweens():
		tween.stop()
	
	# Prediction
	var distance = previous_position.distance_to(new_position)
	var direction = previous_position.direction_to(new_position)
	var linear_velocity = (direction * distance) / $SynchronizationTimer.wait_time
	extrapolate_position(linear_velocity)
	
	spaceship.position = new_position
	previous_position = new_position


func extrapolate_position(linear_velocity):
	spaceship.linear_velocity = linear_velocity


@rpc("authority", "call_remote")
func synchronize_rotation(new_rotation):
	for tween in get_tree().get_processed_tweens():
		tween.stop()
	
	# Prediction
	var angular_velocity = lerp_angle(previous_rotation, new_rotation, 1.0) / $SynchronizationTimer.wait_time
	extrapolate_rotation(angular_velocity)
	
	spaceship.rotation = new_rotation
	previous_rotation = new_rotation


func extrapolate_rotation(angular_velocity):
	spaceship.angular_velocity = angular_velocity


func _on_interpolation_timer_timeout():
	rpc("interpolate_rotation", spaceship.rotation, $InterpolationTimer.wait_time)
	rpc("interpolate_position", spaceship.position, $InterpolationTimer.wait_time)


func _on_synchronization_timer_timeout():
	rpc("synchronize_position", spaceship.position)
	rpc("synchronize_rotation", spaceship.rotation)
