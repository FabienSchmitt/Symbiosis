class_name Player
extends Resource

var _selected_cells : Array[Cell]
var _player_data : PlayerData

func _ready():
	_player_data = load("res://resources/player/player_data.tres")

func add_selected_cell(cell : Cell) -> void: 
	# If the cell has already been selected, we unselect
	var exist_index = _selected_cells.find(cell) 
	if exist_index >= 0:
		_selected_cells.erase(cell)
		cell.select(false)
		return

	_selected_cells.append(cell)
	cell.select(true)

func attack_cell(target : Cell) -> void:
	GameManager.attack_cell(target, _selected_cells)
	for selected_cell in _selected_cells:
		selected_cell.select(false)

	_selected_cells = []


