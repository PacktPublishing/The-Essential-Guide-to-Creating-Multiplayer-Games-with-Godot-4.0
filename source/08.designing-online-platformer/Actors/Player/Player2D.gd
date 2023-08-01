extends PassThroughPlayer2D

signal died

@onready var animated_sprites = $Sprites/AnimatedSprite2D
@onready var sprites = $Sprites
@onready var label = $Label

var fall_speed = 0.0


@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	set_multiplayer_authority(player_id)
	var is_player = player_id == get_multiplayer_authority()
	set_physics_process(is_player)
	set_process_unhandled_input(is_player)
	label.text = "P%s" % get_index()


func setup_controller(index):
	for action in InputMap.get_actions():
		var new_action = action + "%s" % index
		InputMap.add_action(new_action)
		for event in InputMap.action_get_events(action):
			var new_event = event.duplicate()
			new_event.device = index
			InputMap.action_add_event(new_action, event)
		for property in get_property_list():
			if not typeof(get(property.name)) == TYPE_STRING:
				continue
			if get(property.name) == action:
				set(property.name, new_action)


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
