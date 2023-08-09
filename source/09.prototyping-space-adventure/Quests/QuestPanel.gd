extends ScrollContainer


func _ready():
	Quests.quest_created.connect(add_quest)
	Quests.retrieve_quests()


func add_quest(quest):
	var label = Label.new()
	var quest_data = "%s \n %s/%s \n \n %s" %[quest.title, quest.current_amount, quest.target_amount, quest.description]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = quest_data
	$VBoxContainer.add_child(label)
	quest.updated.connect(update_quest.bind(label, quest))


func update_quest(quest_id, current_amount, label, quest):
	var quest_data = "%s \n %s/%s \n \n %s" %[quest.title, quest.current_amount, quest.target_amount, quest.description]
	label.text = quest_data
