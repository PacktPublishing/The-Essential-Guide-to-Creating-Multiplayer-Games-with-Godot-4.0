extends Node2D


@export var speed = 1200.0

@onready var direction = Vector2.RIGHT.rotated(rotation)
@onready var velocity = speed * direction


func _physics_process(delta):
	velocity = speed * direction
	rotation = direction.angle()
	translate(velocity * delta)


func destroy():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	destroy()


func _on_hit_area_2d_damage_applied(damage):
	destroy()
