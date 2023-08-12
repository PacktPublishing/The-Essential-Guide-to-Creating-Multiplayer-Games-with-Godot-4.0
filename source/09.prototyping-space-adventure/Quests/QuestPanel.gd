extends ScrollContainer

var quest_labels = {}


func _ready():
	Quests.quest_created.connect(add_quest)
	Quests.retrieve_quests()


func add_quest(quest):
	var label = Label.new()
	var quest_data = "%s \n %s/%s \n \n %s" %[quest.title, quest.current_amount, quest.target_amount, quest.description]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = quest_data
	$VBoxContainer.add_child(label)
	quest.updated.connect(update_quest)
	
	quest_labels[quest.id] = label


func update_quest(quest_id, current_amount):
	var quest = Quests.get_quest(quest_id)
	var quest_data_text = "%s \n %s/%s \n \n %s" %[quest.title, quest.current_amount, quest.target_amount, quest.description]
	var label = quest_labels[quest_id]
	label.text = quest_data_text
