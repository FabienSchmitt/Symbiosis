extends Node

var _cells : Array[Cell]
var _selected_cells : Array[Cell]
var connection : Array[Behaviors]
var grid: FlowFieldGrid
var player_data: PlayerData

enum Behaviors {SYMBIOSE, PREDATION, PARASITE}

func _ready() -> void:
	player_data = load("res://resources/player/player_data.tres")	

func init_scene():
	create_grid()

## Cells
func add_cell(cell: Cell) -> void: 
	_cells.append(cell)

func add_selected_cell(cell : Cell) -> void: 
	# If the cell has already been selected, we unselect
	var exist_index = _selected_cells.find(cell) 
	if exist_index >= 0:
		_selected_cells.erase(cell)
		cell.select(false)
		return

	_selected_cells.append(cell)
	cell.select(true)

func attack_cell(cell : Cell) -> void:
	for selected_cell in _selected_cells: 
		selected_cell.attack(cell)
		selected_cell.select(false)

	_selected_cells = []

# func get_cells(p_species: Species) -> Array[Cell] :
# 	return _cells.filter(func(c): return c.species == p_species)

## Species
func create_grid() -> void:
	#default value, should come as a parameter I guess...
	grid = FlowFieldGrid.new(Vector2i(23, 13), 50)
