extends TileMap

const NEIGHBOR_CELLS_KING = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1)]
const NEIGHBOR_CELLS_BLACK = [Vector2i(-1, -1), Vector2i(1, -1)]
const NEIGHBOR_CELLS_WHITE = [Vector2i(1, 1), Vector2i(-1, 1)]

enum Teams{BLACK, WHITE}

var current_turn = Teams.WHITE
var meta_board = {}

@onready var black_team = $BlackTeam
@onready var white_team = $WhiteTeam
@onready var free_cells = $FreeCells

var selected_piece = null
var available_cells = []


func _ready():
	create_meta_board()
	map_pieces(black_team)
	map_pieces(white_team)
	toggle_turn()


func create_meta_board():
	for cell in get_used_cells(0):
		meta_board[cell] = null


func map_pieces(team):
	for piece in team.get_children():
		var piece_position = local_to_map(piece.position)
		meta_board[piece_position] = piece
		piece.selected.connect(_on_piece_selected.bind(piece))


func toggle_turn():
	if current_turn == Teams.BLACK:
		current_turn = Teams.WHITE
		for piece in black_team.get_children():
			piece.disable()
		for piece in white_team.get_children():
			piece.enable()
	else:
		current_turn = Teams.BLACK
		for piece in white_team.get_children():
			piece.disable()
		for piece in black_team.get_children():
			piece.enable()
	for child in free_cells.get_children():
		child.queue_free()


func _on_piece_selected(piece):
	select_piece(piece)


func _on_free_cell_selected(free_cell_position):
	var current_cell = local_to_map(selected_piece.position)
	var free_cell = local_to_map(free_cell_position)
	selected_piece.position = free_cell_position
	
	# Updates meta_board
	meta_board[current_cell] = null
	meta_board[free_cell] = selected_piece
	
	capture_pieces(current_cell, free_cell)
	selected_piece.deselect()
	
	toggle_turn()


func capture_pieces(origin_cell, target_cell):
	var direction = Vector2(target_cell - origin_cell).normalized()
	direction = direction.round()
	var cell = target_cell - Vector2i(direction)
	
	var cell_content = meta_board[cell]
	if cell_content:
		cell_content.queue_free()


func select_piece(piece):
	clear_free_cells()
	selected_piece = piece
	var movement_directions = []
	
	match current_turn:
		Teams.BLACK:
			movement_directions = NEIGHBOR_CELLS_BLACK
		Teams.WHITE:
			movement_directions = NEIGHBOR_CELLS_WHITE
	if piece.is_king:
		movement_directions = NEIGHBOR_CELLS_KING
	
	var selected_piece_cell = local_to_map(selected_piece.position)
	for direction in movement_directions:
		var capturing = search_available_cells(selected_piece_cell, direction)
		if capturing:
			break
	for cell in available_cells:
		add_free_cell(cell)


func search_available_cells(current_cell, direction):
	var cell = current_cell + direction
	var capturing = false
	if not cell in meta_board:
		return
	var cell_content = meta_board[cell]
	if cell_content == null:
		available_cells.append(cell)
	elif not cell_content.get_parent() == selected_piece.get_parent():
		var capturing_cell = cell + direction
		if capturing_cell in meta_board:
			if meta_board[capturing_cell] == null:
				available_cells.clear()
				available_cells.append(cell + direction)
				capturing = true
	return capturing


func clear_free_cells():
	for child in free_cells.get_children():
		child.queue_free()
	available_cells.clear()


func add_free_cell(cell):
	var free_cell = preload("res://06.building-online-checkers/FreeCell.tscn").instantiate()
	free_cells.add_child(free_cell)
	free_cell.position = map_to_local(cell)
	free_cell.selected.connect(_on_free_cell_selected)
