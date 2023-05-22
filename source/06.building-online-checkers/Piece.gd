extends Node2D

signal selected
signal deselected

enum Teams{BLACK, WHITE}

@export var team: Teams = Teams.BLACK
@export var is_king = false: set = _set_is_king
@export var king_texture = preload("res://06.building-online-checkers/WhiteKing.svg")

@onready var area = $Area2D
@onready var selected_color_rect = $SelectColorRect
@onready var capturing_color_rect = $CapturingColorRect
@onready var sprite = $Sprite2D

var is_selected = false


func _set_is_king(new_value):
	is_king = new_value
	if not is_inside_tree():
		await(ready)
	if is_king:
		sprite.texture = king_texture


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			select()


func select():
	get_tree().call_group("selected", "deselect")
	add_to_group("selected")
	selected_color_rect.show()
	is_selected = true
	selected.emit()


func deselect():
	remove_from_group("selected")
	selected_color_rect.hide()
	is_selected = false
	deselected.emit()


func enable():
	area.input_pickable = true


func disable():
	area.input_pickable = false


func set_capturing(capturing):
	capturing_color_rect.visible = capturing
