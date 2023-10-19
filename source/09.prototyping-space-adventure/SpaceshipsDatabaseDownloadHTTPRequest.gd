extends HTTPRequest


@export_global_dir var cache_directory = "user://.cache/"
@export_global_file var spaceships_database_path = "user://.cache/PlayerSpaceships.json"
@export var spaceships_database_link = "https://raw.githubusercontent.com/PacktPublishing/The-Essential-Guide-to-Creating-Multiplayer-Games-with-Godot-4.0/13.caching-data/source/09.prototyping-space-adventure/PlayerSpaceships.json"


func download_spaceships_database():
	var directory_access = DirAccess.open(cache_directory)
	if not directory_access:
		DirAccess.make_dir_absolute(cache_directory)
	var file_access = FileAccess.open(spaceships_database_path, FileAccess.READ)
	if not file_access:
		download_file = spaceships_database_path
		request(spaceships_database_link)
		await request_completed


func clear_cache(directory_access):
	if directory_access:
		for file in directory_access.get_files():
			directory_access.remove(file)
