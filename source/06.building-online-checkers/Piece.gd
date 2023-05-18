extends Node2D

signal selected
signal deselected

var is_selected = false
var is_king = false

@onready var area = $Area2D
@onready var color_rect = $ColorRect


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			select()


func select():
	get_tree().call_group("selected", "deselect")
	add_to_group("selected")
	color_rect.show()
	is_selected = true
	selected.emit()


func deselect():
	remove_from_group("selected")
	color_rect.hide()
	is_selected = false
	deselected.emit()


func enable():
	area.input_pickable = true


func disable():
	area.input_pickable = false
