extends Node

@export_file("QuestDatabase.json") var quest_database_file_path = "res://09.prototyping-space-adventure/Quests/QuestDatabase.json"
@export_file("PlayerProgress.json") var player_progress_file_path = "res://09.prototyping-space-adventure/Quests/PlayerProgress.json"


var quest_database = {}
var progress_database = {}

func _ready():
	load_database()


func _notification(notification):
	if notification == NOTIFICATION_WM_CLOSE_REQUEST:
		store_database()


func load_database():
	var quest_database_file = FileAccess.open(quest_database_file_path, FileAccess.READ)
	quest_database = JSON.parse_string(quest_database_file.get_as_text())
	quest_database_file.close()
	var progress_database_file = FileAccess.open(player_progress_file_path, FileAccess.READ)
	progress_database = JSON.parse_string(progress_database_file.get_as_text())
	progress_database_file.close()


func store_database():
	var progress_database_json = JSON.stringify(progress_database)
	var progress_database_file = FileAccess.open(player_progress_file_path, FileAccess.WRITE)
	
	progress_database_file.store_string(progress_database_json)
	progress_database_file.close()


func get_player_quests():
	var quests = {}
	for quest in progress_database:
		var quest_data = {}
		quest_data["id"] = quest
		quest_data["title"] = get_title(quest)
		quest_data["description"] = get_description(quest)
		quest_data["target_amount"] = get_target_amount(quest)
		quest_data["current_amount"] = get_progress(quest)
		quest_data["completed"] = get_completion(quest)
		quests[quest] = quest_data
	return quests


func update_player_progress(quest_id, current_amount, completed):
	progress_database[quest_id]["progress"] = current_amount
	progress_database[quest_id]["completed"] = completed


func get_title(quest_id):
	return quest_database[quest_id]["title"]


func get_description(quest_id):
	return quest_database[quest_id]["description"]


func get_target_amount(quest_id):
	return quest_database[quest_id]["target_amount"]


func get_progress(quest_id):
	return progress_database[quest_id]["progress"]


func get_completion(quest_id):
	return progress_database[quest_id]["completed"]
