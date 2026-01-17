extends Node2D

const BOARD_SIZE = 8
const CELL_W = 20

const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")

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

var board: Array
var white : bool
var state : bool
var seleted_piece : Vector2
var moves = []

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

func _ready() -> void:
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
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var piece_holder:Sprite2D = TEXTURE_HOLDER.instantiate()
			pieces.add_child(piece_holder)
			piece_holder.global_position = Vector2(j*CELL_W + CELL_W / 2 , - i * CELL_W - CELL_W / 2 )
			
			match board[i][j]:
				-6: piece_holder.texture = BLACK_PAWN
				-5: piece_holder.texture = BLACK_ROOK
				-4: piece_holder.texture = BLACK_KNIGHT
				-3: piece_holder.texture = BLACK_BISHOP
				-2: piece_holder.texture = BLACK_QUEEN
				-1: piece_holder.texture = BLACK_KING
				0: piece_holder.texture = null
				1: piece_holder.texture = WHITE_KING
				2: piece_holder.texture = WHITE_QUEEN
				3: piece_holder.texture = WHITE_BISHOP
				4: piece_holder.texture = WHITE_KNIGHT
				5: piece_holder.texture = WHITE_ROOK
				6: piece_holder.texture = WHITE_PAWN
			
func _process(delta: float) -> void:
	pass
