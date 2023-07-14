extends Spawner2D


func spawn(reference = spawn_scene):
	var spawnling = reference.instantiate()
	# Prevents that the Spawner's transform affects its children
	spawnling.global_position = global_position
	spawnling.top_level = true
	spawned.emit(spawnling)
	return spawnling
