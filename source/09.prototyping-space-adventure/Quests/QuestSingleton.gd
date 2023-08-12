extends Node

signal quest_created(new_quest)

var quest_scene = preload("res://09.prototyping-space-adventure/Quests/Quest.tscn")
var quests = {}


func retrieve_quests():
	if multiplayer.is_server():
		return
	await(get_tree().create_timer(0.1).timeout)
	QuestDatabase.rpc_id(1, "get_player_quests", AuthenticationCredentials.user)


@rpc("authority", "call_remote")
func create_quest(quest_data):
	var quest = quest_scene.instantiate()
	quest.id = quest_data["id"]
	quest.title = quest_data["title"]
	quest.description = quest_data["description"]
	quest.target_amount = quest_data["target_amount"]
	quest.current_amount = quest_data["current_amount"]
	quest.completed = quest_data["completed"]
	add_child(quest)
	quests[quest.id] = quest
	quest_created.emit(quest)


func increase_quest_progress(quest_id, amount):
	if not quest_id in quests.keys():
		return
	var quest = quests[quest_id]
	quest.current_amount += amount
	QuestDatabase.rpc_id(1, "update_player_progress", quest_id, quest.current_amount, quest.completed, AuthenticationCredentials.user)


func get_quest(quest_id):
	return quests[quest_id]
