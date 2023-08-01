extends Node


var quest_database = {}
var player_database = {}

func _ready():
	if multiplayer.get_unique_id() == 1:
		load_database()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if multiplayer.get_unique_id() == 1:
			store_progress()


func load_database():
	var quest_database_file = FileAccess.open("res://09.prototyping-space-adventure/Quests/QuestDatabase.json", FileAccess.READ)
	quest_database = JSON.parse_string(quest_database_file.get_as_text())
	quest_database_file.close()
	var player_database_file = FileAccess.open("res://09.prototyping-space-adventure/Quests/PlayerProgressDatabase.json", FileAccess.READ)
	player_database = JSON.parse_string(player_database_file.get_as_text())
	player_database_file.close()


func request_quest_data(quest_id):
	rpc_id(1, "get_quest_data", quest_id)


func request_player_data(player_id):
	rpc_id(1, "get_player_data", player_id)


# Client
@rpc("authority", "call_remote")
func add_quest_data(quest_id, quest_data):
	quest_database[quest_id] = quest_data


# Client
@rpc("authority", "call_remote")
func add_player_data(player_id, player_data):
	player_database[player_id] = player_data


# Server
@rpc("any_peer", "call_remote")
func get_quest_data(quest_id):
	if not is_multiplayer_authority():
		return
	var requester_id = multiplayer.get_remote_sender_id()
	var quest_data = quest_database[quest_id]
	rpc_id(requester_id, "add_quest_data", quest_id, quest_data)
	return quest_data


# Server
@rpc("any_peer", "call_remote")
func get_player_data(player_id):
	if not is_multiplayer_authority():
		return
	var requester_id = multiplayer.get_remote_sender_id()
	var player_data = player_database[player_id]
	rpc_id(requester_id, "add_quest_data", player_id, player_data)
	return player_data


@rpc("any_peer", "call_remote")
func get_player_quests(player_id):
	if not is_multiplayer_authority():
		return
	var requester_id = multiplayer.get_remote_sender_id()
	var quest_data = {}
	for quest in player_database[player_id]:
		quest_data["id"] = quest
		quest_data["title"] = get_title(quest)
		quest_data["description"] = get_description(quest)
		quest_data["target_amount"] = get_target_amount(quest)
		quest_data["current_amount"] = get_progress(player_id, quest)
		quest_data["completed"] = get_completion(player_id, quest)
		Quests.rpc_id(requester_id, "create_quest", quest_data)


@rpc("any_peer", "call_remote")
func update_player_progress(player_id, quest_id, current_amount, completed):
	if not is_multiplayer_authority():
		return
	player_database[player_id][quest_id]["progress"] = current_amount
	player_database[player_id][quest_id]["completed"] = completed


func store_progress():
	var player_database_json = JSON.stringify(player_database)
	var player_database_file = FileAccess.open("res://09.prototyping-space-adventure/Quests/PlayerProgressDatabase.json", FileAccess.WRITE)
	
	player_database_file.store_string(player_database_json)
	player_database_file.close()


func get_title(quest_id):
	if not quest_database.has(quest_id):
		request_quest_data(quest_id)
	return quest_database[quest_id]["title"]


func get_description(quest_id):
	if not quest_database.has(quest_id):
		request_quest_data(quest_id)
	return quest_database[quest_id]["description"]


func get_target_amount(quest_id):
	if not quest_database.has(quest_id):
		request_quest_data(quest_id)
	return quest_database[quest_id]["target_amount"]


func get_progress(player_id, quest_id):
	if not player_database.has(player_id):
		request_player_data(player_id)
	return player_database[player_id][quest_id]["progress"]


func get_completion(player_id, quest_id):
	if not player_database.has(player_id):
		request_player_data(player_id)
	return player_database[player_id][quest_id]["completed"]
