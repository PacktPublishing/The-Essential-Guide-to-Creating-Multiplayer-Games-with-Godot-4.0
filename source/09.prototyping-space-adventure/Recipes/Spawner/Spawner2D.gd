class_name Spawner2D
extends Node2D

signal spawned(spawnling)
@export var spawn_scene: PackedScene


func spawn(reference = spawn_scene):
	var spawnling = reference.instantiate()
	# Prevents that the Spawner's transform affects its children
	spawnling.global_position = global_position
	spawnling.top_level = true
	add_child(spawnling, true)
	spawned.emit(spawnling)
	return spawnling
