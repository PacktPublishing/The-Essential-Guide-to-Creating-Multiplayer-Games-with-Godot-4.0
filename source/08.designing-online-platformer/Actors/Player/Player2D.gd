extends PassThroughPlayer2D

signal died

@onready var animated_sprites = $Sprites/AnimatedSprite2D
@onready var sprites = $Sprites

var fall_speed = 0.0


@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	set_multiplayer_authority(player_id)
	set_physics_process(str(player_id) == str(name))
	set_process_unhandled_input(str(player_id) == str(name))


func setup_controller(index):
	for action in InputMap.get_actions():
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				event.device = index


func _physics_process(delta):
	super(delta)
	
	if direction > 0:
		sprites.scale.x = 1
	elif direction < 0:
		sprites.scale.x = -1
	
	var animation = animated_sprites.animation
	if is_on_floor():
		if not direction == 0.0:
			animation = "run"
		else:
			animation = "idle"
	else:
		if velocity.y >= 0.0:
			animation = "fall"
			fall_speed = velocity.y
		else:
			animation = "jump"
		
	if fall_speed > 0.0 and is_on_floor():
		animation = "ground"
	animated_sprites.play(animation)


func _on_animated_sprite_2d_animation_finished():
	if animated_sprites.animation == "ground":
		fall_speed = 0.0
		animated_sprites.play("idle")
	elif animated_sprites.animation == "hit":
		set_physics_process(true)
		set_process_unhandled_input(true)
		animated_sprites.play("idle")
