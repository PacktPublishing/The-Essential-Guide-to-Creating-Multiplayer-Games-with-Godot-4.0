extends Node2D

@export var thrust_action = "move_up"
@export var turn_left_action = "move_left"
@export var turn_right_action = "move_right"
@export var shoot_action = "shoot"


@onready var spaceship = $Spaceship
@onready var weapon = $Spaceship/Weapon2D
@onready var camera = $Camera2D
@onready var http_request = $TextureDownloadHTTPRequest

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
	if not multiplayer.is_server():
		camera.make_current()
	else:
		$InterpolationTimer.start()
		$SynchronizationTimer.start()


@rpc("authority", "call_local")
func load_spaceship(user):
	var spaceship_file = "user://.cache/" + user + "_spaceship.png"
	if FileAccess.file_exists(spaceship_file):
		update_sprite(spaceship_file)
	else:
		if await http_request.download_spaceship(user, spaceship_file) == OK:
			update_sprite(spaceship_file)


func update_sprite(spaceship_file):
	var image = Image.load_from_file(spaceship_file)
	var texture = ImageTexture.create_from_image(image)
	$Spaceship/Sprite2D.texture = texture


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		weapon.rpc("set_firing", true)
	elif event.is_action_released("shoot"):
		weapon.rpc("set_firing", false)


@rpc("authority", "call_remote")
func interpolate_position(target_position, duration_in_seconds):
	var tween = create_tween()

	var final_value = lerp(previous_position, target_position, 1.0)

	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "position", final_value, duration_in_seconds)
	tweener.from(previous_position)
	previous_position = target_position


@rpc("authority", "call_remote")
func interpolate_rotation(target_rotation, duration_in_seconds):
	var tween = create_tween()

	var final_value = lerp_angle(previous_rotation, target_rotation, 1.0)

	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "rotation", final_value, duration_in_seconds)
	tweener.from(previous_rotation)
	previous_rotation = target_rotation


@rpc("authority", "call_remote")
func synchronize_position(new_position, synchronization_tic):
	for tween in get_tree().get_processed_tweens():
		tween.stop()

	var future_position = predict_position(new_position, synchronization_tic)
	extrapolate_position(future_position, synchronization_tic)

	spaceship.position = new_position
	previous_position = new_position



func predict_position(new_position, seconds_ahead):
	var distance = previous_position.distance_to(new_position)
	var direction = previous_position.direction_to(new_position)
	var linear_velocity = (direction * distance) / seconds_ahead
	spaceship.linear_velocity = linear_velocity

	var next_position = new_position + (linear_velocity * seconds_ahead)
	return next_position


func extrapolate_position(next_position, seconds_ahead):
	var tween = create_tween()

	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "position", next_position, seconds_ahead)
	tweener.from(previous_position)


@rpc("authority", "call_remote")
func synchronize_rotation(new_rotation, synchronization_tic):
	for tween in get_tree().get_processed_tweens():
		tween.stop()

	var future_rotation = predict_rotation(new_rotation, synchronization_tic)
	extrapolate_rotation(future_rotation, synchronization_tic)

	spaceship.rotation = new_rotation
	previous_rotation = new_rotation


func predict_rotation(new_rotation, seconds_ahead):
	var angular_velocity = lerp_angle(previous_rotation, new_rotation, 1.0) / seconds_ahead
	spaceship.angular_velocity = angular_velocity

	var next_rotation = spaceship.rotation + (angular_velocity * seconds_ahead)
	return next_rotation


func extrapolate_rotation(target_rotation, seconds_ahead):
	var tween = create_tween()

	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener = tween.tween_property(spaceship, "rotation", target_rotation, seconds_ahead)
	tweener.from(previous_rotation)


func _on_interpolation_timer_timeout():
	rpc("interpolate_rotation", spaceship.rotation, $InterpolationTimer.wait_time)
	rpc("interpolate_position", spaceship.position, $InterpolationTimer.wait_time)


func _on_synchronization_timer_timeout():
	rpc("synchronize_position", spaceship.position, $SynchronizationTimer.wait_time)
	rpc("synchronize_rotation", spaceship.rotation, $SynchronizationTimer.wait_time)
