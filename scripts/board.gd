extends Node2D

const BOARD_SIZE = 8
const CELL_W = 20

const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")
const PROMOTION_CHOICE = preload("res://scenes/texture_button.tscn")
@onready var panel_container: PanelContainer = $PanelContainer
@onready var grid_container: GridContainer = $PanelContainer/BoxContainer/GridContainer



# Possible move
const PIECE_MOVE = preload("res://art/dot/piece_move.png")

# Bishops
const BLACK_BISHOP = preload("res://art/bishop/black_bishop.png")
const WHITE_BISHOP = preload("res://art/bishop/white_bishop.png")
# Kings
const BLACK_KING = preload("res://art/king/black_king.png")
const WHITE_KING = preload("res://art/king/white_king.png")
# Queens
const BLACK_QUEEN = preload("res://art/queen/black_queen.png")
const WHITE_QUEEN = preload("res://art/queen/white_queen.png")
#Pawns
const BLACK_PAWN = preload("res://art/pawn/black_pawn.png")
const WHITE_PAWN = preload("res://art/pawn/white_pawn.png")
# knights
const BLACK_KNIGHT = preload("res://art/knight/black_knight.png")
const WHITE_KNIGHT = preload("res://art/knight/white_knight.png")
# rooks
const BLACK_ROOK = preload("res://art/rook/black_rook.png")
const WHITE_ROOK = preload("res://art/rook/white_rook.png")

@onready var pieces: Node2D = $pieces
@onready var dots: Node2D = $dots

var board: Array
var white : bool = true
var state : bool = false
var selected_piece : Vector2
var moves = []
var promotion_pos : Vector2

# number -> type of piece and color
# + : white
# - : black

# 0 : nothing( the cell is empty )
# 1 : king
# 2 : queen
# 3 : bishop
# 4 : knight
# 5 : rook
# 6 : pawn


# Castling
var white_king = false
var black_king = false

var white_rook_left = false
var white_rook_right = false
var black_rook_left = false
var black_rook_right = false

# Checking
var white_king_pos = Vector2(0,4)
var black_king_pos = Vector2(7,4)


func _ready() -> void:
	panel_container.visible = false
	board.append([5,4,3,2,1,3,4,5])
	board.append([6,6,6,6,6,6,6,6])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([-6,-6,-6,-6,-6,-6,-6,-6])
	board.append([-5,-4,-3,-2,-1,-3,-4,-5])
	
	draw_board()


func draw_board():
	for child in pieces.get_children():
		child.queue_free()
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var piece_holder:Sprite2D = TEXTURE_HOLDER.instantiate()
			pieces.add_child(piece_holder)
			piece_holder.global_position = Vector2(j*CELL_W + floor(CELL_W / 2) , - i * CELL_W - floor(CELL_W / 2) )
			
			piece_holder.texture = get_piece_texture(board[i][j])
			#match board[i][j]:
				## BLACK Player :
				#-6: piece_holder.texture = BLACK_PAWN
				#-5: piece_holder.texture = BLACK_ROOK
				#-4: piece_holder.texture = BLACK_KNIGHT
				#-3: piece_holder.texture = BLACK_BISHOP
				#-2: piece_holder.texture = BLACK_QUEEN
				#-1: piece_holder.texture = BLACK_KING
				## no piece:
				#0: piece_holder.texture = null
				## WHITE Player :
				#1: piece_holder.texture = WHITE_KING
				#2: piece_holder.texture = WHITE_QUEEN
				#3: piece_holder.texture = WHITE_BISHOP
				#4: piece_holder.texture = WHITE_KNIGHT
				#5: piece_holder.texture = WHITE_ROOK
				#6: piece_holder.texture = WHITE_PAWN
				
func get_piece_texture(piece_value):
	match piece_value:
				# BLACK Player :
				-6: return BLACK_PAWN
				-5: return BLACK_ROOK
				-4: return BLACK_KNIGHT
				-3: return BLACK_BISHOP
				-2: return BLACK_QUEEN
				-1: return BLACK_KING
				# no piece:
				0: return null
				# WHITE Player :
				1: return WHITE_KING
				2: return WHITE_QUEEN
				3: return WHITE_BISHOP
				4: return WHITE_KNIGHT
				5: return WHITE_ROOK
				6: return WHITE_PAWN
func _input(event):
	if event is InputEventMouseButton && event.pressed:
		if event.button_index  == MOUSE_BUTTON_LEFT:
			if is_mouse_out():
				print("out")
				return 
			var var1 = int(get_global_mouse_position().x / CELL_W)
			var var2 = abs(int(get_global_mouse_position().y / CELL_W))
			print(var1,var2)
			if !state && (white && board[var2][var1] > 0 || !white && board[var2][var1] < 0) :
				print("valid select of piece") 
				selected_piece = Vector2(var2,var1)
				state = true
				show_options()
			elif state:
				# the move (action) is confirmed
				set_move(var2,var1)
				
				
				

func show_options():
	moves = get_actions()
	if moves == []:
		state = false
		return
	show_dots()
func show_dots():
	for i in moves:
		var holder:Sprite2D = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.texture = PIECE_MOVE
		holder.global_position = Vector2(i.y * CELL_W + floor(CELL_W/2),- i.x * CELL_W - floor(CELL_W/2))
		
func delete_dots():
	for child in dots.get_children():
		child.queue_free()		
func set_move(var2,var1):
		for move in moves:
			if move.x == var2 && move.y == var1:
				check_castling(move)
				board[var2][var1] = board[selected_piece.x][selected_piece.y]
				board[selected_piece.x][selected_piece.y] = 0
				var is_promotion = check_promotion(var2,var1)
				if is_promotion:
					promotion_pos = Vector2(var2,var1)
					display_promotion_choices()
				else:	
					white = !white
					draw_board()	
				break	
		delete_dots()
		state = false	
func check_promotion(var2,var1):
	if abs(board[var2][var1]) == 6  && (var2 == 7 || var2 == 0):
		print("you can promote")
		return true
	return false
func check_castling(move):
	match board[selected_piece.x][selected_piece.y]:
					1:
						if selected_piece.x == 0 && selected_piece.y == 4:
							white_king = true
							if move.y == 2:
								white_rook_left = true
								white_rook_right = true
								board[0][0] = 0
								board[0][3] = 5
							if move.y == 6:
								white_rook_left = true
								white_rook_right = true
								board[0][7] = 0
								board[0][5] = 5
						white_king_pos = move		
					-1:
						if selected_piece.x == 7 && selected_piece.y == 4:
							black_king = true
							if move.y == 2:
								black_rook_left = true
								black_rook_right = true
								board[7][0] = 0
								board[7][3] = -5
							if move.y == 6:
								black_rook_left = true
								black_rook_right = true
								board[7][7] = 0
								board[7][5] = -5
						black_king_pos = move			
					5:
						if selected_piece.x == 0 && selected_piece.y == 0:
							white_rook_left = true
						elif selected_piece.x == 0 && selected_piece.y == 7:
							white_rook_right = true	
					-5:	
						if selected_piece.x == 7 && selected_piece.y == 0:
							black_rook_left = true
						elif selected_piece.x == 7 && selected_piece.y == 7:
							black_rook_right = true			
func display_promotion_choices():
	for child in grid_container.get_children():
		child.queue_free()
	var choices = [2,5,3,4]
	for choice in choices:
		var final_choice = choice if white else -choice
		var choice_holder:TextureButton = PROMOTION_CHOICE.instantiate()
		choice_holder.texture_normal = get_piece_texture(final_choice)
		choice_holder.custom_minimum_size = Vector2(CELL_W,CELL_W)
		choice_holder.ignore_texture_size = true
		choice_holder.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		choice_holder.pressed.connect(_on_piece_selected.bind(final_choice))
		grid_container.add_child(choice_holder)
	panel_container.visible = true	
	
func _on_piece_selected(piece_type: int):
	
	board[promotion_pos.x][promotion_pos.y] = piece_type
	white = !white
	panel_container.visible = false
	draw_board()	

func is_in_check(king_pos:Vector2):
	var directions = [Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1),Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)]
	var pawn_direction = 1 if white else -1
	var pawn_attacks = [
		 king_pos + Vector2(pawn_direction,1),
		 king_pos + Vector2(pawn_direction,-1)
	]
	for attack in pawn_attacks:
		if is_valid_position(attack):
			if is_enemy(attack) && abs(board[attack.x][attack.y]) == 6:
				return true
	for i in directions:
		var pos = king_pos + i
		if is_valid_position(pos):
			if white && board[pos.x][pos.y] == -6 || !white && board[pos.x][pos.y] == 6:
				return true
	for i in directions:
		var pos = king_pos + i
		while is_valid_position(pos):
			if !is_empty(pos):
				var piece = board[pos.x][pos.y]
				if (i.x == 0 || i.y == 0) && (white && piece in [-2,-5] || !white && piece in [2,5]):
					return true
				elif (i.x != 0 && i.y != 0) && (white && piece in [-2,-3] || !white && piece in [2,3]) :
					return true
				break
			pos += i							
	var knight_directions = [Vector2(2,1),Vector2(2,-1),Vector2(1,2),Vector2(-1,2),Vector2(-2,1),Vector2(-2,-1),Vector2(1,-2),Vector2(-1,-2)]	
	for i in knight_directions:
		var pos = king_pos + i
		if is_valid_position(pos):
			if white && board[pos.x][pos.y] == -4 || !white && board[pos.x][pos.y] == 4:
				return true
	return false			
									
func get_actions():
	var _moves= []
	match abs(board[selected_piece.x][selected_piece.y]):
		1:_moves = get_king_actions()
		2:_moves = get_queen_actions()
		3:_moves = get_bishop_actions()
		4:_moves = get_knight_actions()
		5:_moves = get_rook_actions()
		6:_moves = get_pawn_actions()
	return _moves
func get_rook_actions():
	var _moves = []
	var directions = [Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)]
	
	for i in directions:
		var pos = selected_piece
		pos += i
		while is_valid_position(pos):
			if is_empty(pos): _moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
				break
			else:
				break
			pos+=i		
	return _moves

func get_bishop_actions():
	var _moves = []
	var directions = [Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]
	
	for i in directions:
		var pos = selected_piece
		pos += i
		while is_valid_position(pos):
			if is_empty(pos): _moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
				break
			else:
				break
			pos+=i		
	return _moves

func get_queen_actions():
	var _moves = []
	var directions = [Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1),Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)]
	
	for i in directions:
		var pos = selected_piece
		pos += i
		while is_valid_position(pos):
			if is_empty(pos): _moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
				break
			else:
				break
			pos+=i		
	return _moves
	
func get_king_actions():
	var _moves = []
	var directions = [Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1),Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)]
	
	if white:
		board[white_king_pos.x][white_king_pos.y] = 0
	else:
		board[black_king_pos.x][black_king_pos.y] = 0
	for i in directions:
		var pos = selected_piece
		pos += i
		if is_valid_position(pos):
			if !is_in_check(pos):
				if is_empty(pos): _moves.append(pos)
				elif is_enemy(pos):
					_moves.append(pos)
	if white && !white_king:
		if 	!white_rook_left && is_empty(Vector2(0,1)) && is_empty(Vector2(0,2)) && is_empty(Vector2(0,3)):
			_moves.append(Vector2(0,2))	
		if 	!white_rook_right && is_empty(Vector2(0,6)) && is_empty(Vector2(0,5)):
			_moves.append(Vector2(0,6))	
	elif !white && !black_king:
		if 	!black_rook_left && is_empty(Vector2(7,1)) && is_empty(Vector2(7,2)) && is_empty(Vector2(7,3)):
			_moves.append(Vector2(7,2))	
		if 	!black_rook_right && is_empty(Vector2(7,6)) && is_empty(Vector2(7,5)):
			_moves.append(Vector2(7,6))	
	if white:
		board[white_king_pos.x][white_king_pos.y] = 1
	else:
		board[black_king_pos.x][black_king_pos.y] = 1		
	return _moves			

func get_knight_actions():
	var _moves = []
	var directions = [Vector2(2,1),Vector2(2,-1),Vector2(1,2),Vector2(-1,2),Vector2(-2,1),Vector2(-2,-1),Vector2(1,-2),Vector2(-1,-2)]
	
	for i in directions:
		var pos = selected_piece
		pos += i
		if is_valid_position(pos):
			if is_empty(pos): _moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
	return _moves	
	
func get_pawn_actions():
	var _moves = []
	var direction
	var is_first_move = false
	if white: direction = Vector2(1,0)
	else:
		direction = Vector2(-1,0)
	
	if white && selected_piece.x == 1 || !white && selected_piece.x == 6:
		is_first_move = true
	var pos = selected_piece + direction
	if is_empty(pos): _moves.append(pos)
	pos = selected_piece + Vector2(direction.x,1)
	if is_valid_position(pos):
		if is_enemy(pos): _moves.append(pos)
	pos = selected_piece + Vector2(direction.x,-1)
	if is_valid_position(pos):
		if is_enemy(pos): _moves.append(pos)
		
	pos  = selected_piece + direction * 2
	if is_first_move && is_empty(pos) && is_empty(selected_piece + direction):
		_moves.append(pos)
	
	return _moves	
			
func is_valid_position(pos:Vector2):
	if pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >=0 && pos.y < BOARD_SIZE: return true
	return false
func is_empty(pos:Vector2):
	if board[pos.x][pos.y] == 0: return true
	return false	
func is_enemy(pos:Vector2):
	if white && board[pos.x][pos.y] < 0 || !white && board[pos.x][pos.y] > 0: return true
	return false		
			
		
func is_mouse_out():
	if get_global_mouse_position().x  < 0 || get_global_mouse_position().y > 0 || get_global_mouse_position().y < -160 || get_global_mouse_position().x > 160 :	
		return true
	return false	
				
			
				  
func _process(delta: float) -> void:
	pass
