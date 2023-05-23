extends TileMap

const DIRECTIONS_CELLS_KING = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1)]
const DIRECTIONS_CELLS_BLACK = [Vector2i(-1, -1), Vector2i(1, -1)]
const DIRECTIONS_CELLS_WHITE = [Vector2i(1, 1), Vector2i(-1, 1)]

enum Teams{BLACK, WHITE}

var current_turn = Teams.BLACK
var meta_board = {}

@onready var black_team = $BlackTeam
@onready var white_team = $WhiteTeam
@onready var free_cells = $FreeCells

var selected_piece = null


func _ready():
	create_meta_board()
	map_pieces(black_team)
	map_pieces(white_team)
	enable_pieces(black_team)


func create_meta_board():
	for cell in get_used_cells(0):
		meta_board[cell] = null


func map_pieces(team):
	for piece in team.get_children():
		var piece_position = local_to_map(piece.position)
		meta_board[piece_position] = piece
		piece.selected.connect(_on_piece_selected.bind(piece))


func toggle_turn():
	clear_free_cells()
	selected_piece.deselect()
	if current_turn == Teams.BLACK:
		current_turn = Teams.WHITE
		disable_pieces(black_team)
		enable_pieces(white_team)
	else:
		current_turn = Teams.BLACK
		disable_pieces(white_team)
		enable_pieces(black_team)


func _on_piece_selected(piece):
	select_piece(piece)


func _on_free_cell_selected(free_cell_position):
	var free_cell = local_to_map(free_cell_position)
	if can_capture(selected_piece):
		capture_pieces(free_cell)
	else:
		move_selected_piece(free_cell)
	toggle_turn()


func move_selected_piece(target_cell):
	var current_cell = local_to_map(selected_piece.position)
	selected_piece.position = map_to_local(target_cell)
	
	# Updates meta_board
	meta_board[current_cell] = null
	meta_board[target_cell] = selected_piece
	crown()


func crown():
	var selected_piece_cell = local_to_map(selected_piece.position)
	
	if selected_piece.team == Teams.BLACK and selected_piece_cell.y < 1:
		selected_piece.is_king = true
	elif selected_piece.team == Teams.WHITE and selected_piece_cell.y > 6:
		selected_piece.is_king = true


func enable_pieces(team):
	var capturing_pieces = []
	var available_pieces = []
	
	for piece in team.get_children():
		var capturing = can_capture(piece)
		if capturing:
			capturing_pieces.append(piece)
		elif search_available_cells(piece).size() > 0:
			available_pieces.append(piece)
	if capturing_pieces.size() > 0:
		for piece in capturing_pieces:
			piece.enable()
	else:
		for piece in available_pieces:
			piece.enable()


func disable_pieces(team):
	for piece in team.get_children():
		piece.disable()


func can_capture(piece):
	var directions = get_piece_directions(piece)
	var capturing = false
	for direction in directions:
		var current_cell = local_to_map(piece.position)
		var neighbor_cell = current_cell + direction
		if not is_on_board(neighbor_cell):
			continue
		if is_free_cell(neighbor_cell):
			continue
		var cell_content = meta_board[neighbor_cell]
		if not is_opponent(neighbor_cell):
			continue
		var capturing_cell = neighbor_cell + direction
		if not is_on_board(capturing_cell):
			continue
		cell_content = meta_board[capturing_cell]
		if is_free_cell(capturing_cell):
			capturing = true
	return capturing


func capture_pieces(target_cell):
	var origin_cell = local_to_map(selected_piece.position)
	var direction = Vector2(target_cell - origin_cell).normalized()
	direction = Vector2i(direction.round())
	var cell = target_cell - direction
	
	if not is_on_board(cell):
		return
	
	var cell_content = meta_board[cell]
	if cell_content:
		cell_content.queue_free()
		meta_board[cell] = null
		move_selected_piece(target_cell)
	if can_capture(selected_piece):
		target_cell = target_cell + (direction * 2)
		capture_pieces(target_cell)


func select_piece(piece):
	clear_free_cells()
	selected_piece = piece
	
	var selected_piece_cell = local_to_map(selected_piece.position)
	var available_cells = search_available_cells(selected_piece)
	for cell in available_cells:
		add_free_cell(cell)


func get_piece_directions(piece):
	var directions = []
	if piece.team == Teams.BLACK:
		directions = DIRECTIONS_CELLS_BLACK
	else:
		directions = DIRECTIONS_CELLS_WHITE
	if piece.is_king:
		directions = DIRECTIONS_CELLS_KING
	return directions


func search_available_cells(piece):
	var available_cells = []
	var capturing = can_capture(piece)
	var directions = get_piece_directions(piece)
	var current_cell = local_to_map(piece.position)
	
	for direction in directions:
		var cell = current_cell + direction
		if not is_on_board(cell):
			continue
		if not is_free_cell(cell):
			if is_opponent(cell):
				var capturing_cell = cell + direction
				if not is_on_board(capturing_cell):
					continue
				if is_free_cell(capturing_cell):
					available_cells.append(capturing_cell)
					continue
				else:
					continue
			else:
				continue
		if not capturing:
			available_cells.append(cell)
	return available_cells


func is_opponent(cell):
	var is_opponent = false
	if not is_free_cell(cell):
		if not meta_board[cell].team == current_turn:
			is_opponent = true
	return is_opponent


func is_free_cell(cell):
	if not is_on_board(cell):
		return false
	return meta_board[cell] == null


func is_on_board(cell):
	return cell in meta_board


func clear_free_cells():
	for child in free_cells.get_children():
		child.queue_free()


func add_free_cell(cell):
	var free_cell = preload("res://06.building-online-checkers/FreeCell.tscn").instantiate()
	free_cells.add_child(free_cell)
	free_cell.position = map_to_local(cell)
	free_cell.selected.connect(_on_free_cell_selected)
