extends Area2D

signal selected(cell_position)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			select()


func select():
	selected.emit(self.position)
