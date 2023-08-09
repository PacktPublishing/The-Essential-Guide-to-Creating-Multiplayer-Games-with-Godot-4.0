extends Node2D


@export var max_health = 3
@onready var health = max_health

@onready var animator = $AnimationPlayer


@rpc("authority", "call_local")
func explode():
	animator.play("explode")


@rpc("any_peer", "call_local")
func hit():
	animator.play("hit")


@rpc("any_peer", "call_local")
func apply_damage(damage):
	health -= damage
	if health < 1:
		rpc("explode")
	elif health > 0:
		rpc("hit")


func _on_hurt_area_2d_damage_taken(damage):
	rpc_id(1, "apply_damage", damage)


func _on_animation_player_animation_finished(anim_name):
	if is_multiplayer_authority():
		if anim_name == "explode":
			queue_free()
