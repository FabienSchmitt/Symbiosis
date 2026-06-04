extends Node

var connection : Array[Behaviors]
var grid: FlowFieldGrid

enum Behaviors {SYMBIOSE, PREDATION, PARASITE}

func init_scene():
	create_grid()

func create_grid() -> void:
	#default value, should come as a parameter I guess...
	grid = FlowFieldGrid.new(Vector2i(23, 13), 50)


func attack_cell(target: Cell, sources: Array[Cell]) -> void :
	for source in sources: 
		source.attack(target)
