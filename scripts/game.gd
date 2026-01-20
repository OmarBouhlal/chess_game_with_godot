extends Node2D

#@onready var board: Node2D = $Board

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#board.connect("game_finished",self._on_game_finished)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _on_game_finished():
	#print("game finished")
