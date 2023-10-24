extends HTTPRequest

@export_global_file var spaceships_database_file = "user://.cache/PlayerSpaceships.json"

func _ready():
	var callable = Callable(self, "get_texture_downloaded_bytes")
	Performance.add_custom_monitor("Network/Texture Download Bytes", callable)


func get_texture_downloaded_bytes():
	return get_downloaded_bytes()


func download_spaceship(user, sprite_file):
	var players_spaceships = {}
	if FileAccess.file_exists(spaceships_database_file):
		var file = FileAccess.open(spaceships_database_file, FileAccess.READ)
		players_spaceships = JSON.parse_string(file.get_as_text())
	if user in players_spaceships:
		download_file = sprite_file
		var error = request(players_spaceships[user])
		await request_completed
		return error
	return FAILED
