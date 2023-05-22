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
	clear_free_cells()
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
	move_selected_piece(local_to_map(free_cell_position))


func move_selected_piece(target_cell):
	var current_cell = local_to_map(selected_piece.position)
	selected_piece.position = map_to_local(target_cell)
	
	# Updates meta_board
	meta_board[current_cell] = null
	meta_board[target_cell] = selected_piece
	crown()
	toggle_turn()
	selected_piece.deselect()


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
		else:
			available_pieces.append(piece)
	if capturing_pieces.size() > 0:
		for piece in capturing_pieces:
			piece.enable()
			piece.set_capturing(true)
	else:
		for piece in available_pieces:
			piece.enable()


func disable_pieces(team):
	for piece in team.get_children():
		piece.disable()
		piece.set_capturing(false)


func can_capture(piece):
	var directions = NEIGHBOR_CELLS_BLACK
	if current_turn == Teams.WHITE:
		directions = NEIGHBOR_CELLS_WHITE
	if piece.is_king:
		directions = NEIGHBOR_CELLS_KING
	var capturing = false
	for direction in directions:
		var current_cell = local_to_map(piece.position)
		var neighbor_cell = current_cell + direction
		# Cell is out of the board's boundaries
		if not neighbor_cell in meta_board:
			continue
		var cell_content = meta_board[neighbor_cell]
		# Cell is occupied
		if not cell_content == null:
			# The content of the cell is an opponent piece
			if not cell_content.team == piece.team:
				var capturing_cell = neighbor_cell + direction
				# There's no cells to move to after capturing, so capturing isn't possible
				if not capturing_cell in meta_board:
					continue
				# There's a neighbor free cell in the capturing direction
				cell_content = meta_board[capturing_cell]
				if cell_content == null:
					capturing = true
	return capturing


func capture_pieces(origin_cell, target_cell):
	var direction = Vector2(target_cell - origin_cell).normalized()
	direction = Vector2i(direction.round())
	var cell = target_cell - direction
	
	if not cell in meta_board:
		return
	
	var cell_content = meta_board[cell]
	if cell_content:
		cell_content.queue_free()
		meta_board[cell] = null


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
	var available_cells = search_available_cells(selected_piece_cell, movement_directions)
	for cell in available_cells:
		add_free_cell(cell)


func search_available_cells(current_cell, directions):
	var available_cells = []
	var capturing = false
	for direction in directions:
		var cell = current_cell + direction
		
		# Cell is out of the board's boundaries
		if not cell in meta_board:
			continue
		var cell_content = meta_board[cell]
		
		# Cell is occupied
		if not cell_content == null:
			# The content of the cell is an opponent piece
			if not cell_content.team == selected_piece.team:
				var capturing_cell = cell + direction
				# There's no cells to move to after capturing, so capturing isn't possible
				if not capturing_cell in meta_board:
					continue
				# There's a neighbor free cell in the capturing direction
				cell_content = meta_board[capturing_cell]
				if cell_content == null:
					capturing = true
					# Checks if previous cells lead to capturing, otherwise they are removed
					for available_cell in available_cells:
						for _direction in directions:
							var neighbor_cell = available_cell - _direction
							if not neighbor_cell in meta_board:
								continue
							cell_content = meta_board[neighbor_cell]
							# Removes cells that don't lead to capturing if
							if cell_content == null or cell_content == selected_piece:
								available_cells.erase(available_cell)
					available_cells.append(capturing_cell)
		elif not capturing:
			available_cells.append(cell)
	return available_cells


func clear_free_cells():
	for child in free_cells.get_children():
		child.queue_free()


func add_free_cell(cell):
	var free_cell = preload("res://06.building-online-checkers/FreeCell.tscn").instantiate()
	free_cells.add_child(free_cell)
	free_cell.position = map_to_local(cell)
	free_cell.selected.connect(_on_free_cell_selected)
