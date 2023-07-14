extends Node2D


@export var max_health = 3
@onready var health = max_health

@onready var animator = $AnimationPlayer


func _ready():
	if not multiplayer.get_unique_id() == 1:
		set_process(false)


func _process(delta):
	translate(Vector2(10, 10) * delta)


func _on_HurtArea2D_hurt(damage):
	hurt(damage)


func die():
	explode()


func explode():
	animator.play("explode")


func hurt(damage):
	health -= damage
	if health < 1:
		die()
	else:
		animator.play("hit")
