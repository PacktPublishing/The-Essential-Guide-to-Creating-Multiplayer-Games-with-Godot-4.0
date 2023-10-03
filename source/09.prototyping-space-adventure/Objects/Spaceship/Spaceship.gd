class_name Spaceship2D
extends RigidBody2D


@export var acceleration = 600.0
@export var turn_torque = 10.0

@export var thrusting = false : set = set_thrusting
@export var turning = false : set = set_turning
@export_range(-1, 1, 1) var direction = 0 : set = set_direction


func _physics_process(delta):
	if thrusting:
		thrust(delta)
	if turning:
		turn(delta)


func thrust(delta):
	linear_velocity += (acceleration * delta) * Vector2.RIGHT.rotated(rotation)
	print("Thrusting caller is: %s" % multiplayer.get_unique_id())


func turn(delta):
	angular_velocity += (direction * turn_torque) * delta


@rpc("any_peer", "call_local")
func set_thrusting(is_thrusting):
	print("Set thrusting caller is: %s" % multiplayer.get_remote_sender_id())
	thrusting = is_thrusting


@rpc("any_peer", "call_local")
func set_turning(is_turning):
	turning = is_turning


@rpc("any_peer", "call_local")
func set_direction(new_direction):
	direction = new_direction
