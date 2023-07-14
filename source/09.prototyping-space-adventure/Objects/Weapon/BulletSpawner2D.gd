extends Spawner2D


func spawn(reference = spawn_scene):
	var bullet = super(reference)
	bullet.direction = Vector2.RIGHT.rotated(global_rotation)
