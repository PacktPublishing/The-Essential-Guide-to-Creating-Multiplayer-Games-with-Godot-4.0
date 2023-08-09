extends Spawner2D


@export var radius = 300.0
@export var min_angle = PI
@export var max_angle = TAU

func spawn(reference = spawn_scene):
	var spawnling = super(reference)
	
	var radial_offset = Vector2.RIGHT.rotated(randf_range(min_angle, max_angle)) * randf_range(-radius, radius)
	spawnling.global_position += radial_offset
