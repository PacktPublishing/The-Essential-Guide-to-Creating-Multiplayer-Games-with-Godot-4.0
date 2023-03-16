extends Control


@onready var label = $Label
@onready var texture_rect = $TextureRect


func update_data(user_name, texture_path):
	label.text = user_name
	texture_rect.texture = load(texture_path)
