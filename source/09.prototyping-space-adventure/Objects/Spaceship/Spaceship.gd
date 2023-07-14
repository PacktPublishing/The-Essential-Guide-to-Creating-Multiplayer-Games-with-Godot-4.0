class_name Spaceship2D
extends RigidBody2D


@export var acceleration = 600.0
@export var turn_torque = 10.0


func thrust():
	var delta = get_physics_process_delta_time()
	linear_velocity += (acceleration * delta) * Vector2.RIGHT.rotated(rotation)


func turn(direction):
	var delta = get_physics_process_delta_time()
	angular_velocity += (direction * turn_torque) * delta
