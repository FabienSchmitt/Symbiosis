extends Node2D


@export var number_of_cells := 50
@export var minimal_cell_radius := 20
@export var maximal_cell_radius = 100

@export var max_iteration := 1000

var _cell_scene: PackedScene

var _cells: Array[Cell] = []

func _ready() -> void:
	# rule of thumb
	var max_pos = sqrt(number_of_cells) * ((maximal_cell_radius - minimal_cell_radius) / 2.0) * 6
	_cell_scene = preload("res://scenes/cell.tscn")
	for n in number_of_cells:
		var radius = randi_range(minimal_cell_radius, maximal_cell_radius)
		var cell = _cell_scene.instantiate()
		cell.radius = radius
		cell.global_position = Vector2(randf_range(-max_pos / 2.0, max_pos / 2.0), - randf_range(-max_pos / 2.0, max_pos / 2.0))
		_cells.append(cell)

	_execute_loop()

	for cell in _cells:
		get_tree().current_scene.add_child(cell)

	
func _execute_loop():
	for i in max_iteration:
		if _check_placement():
			print ("setup complete on iteration ", i)
			return
	
	print("Max iteration reached")

func _check_placement() -> bool:
	var contains_overlap = false
	# check cells repartition
	for i in _cells.size():
		for j in range(i + 1, _cells.size()):
			var c1 = _cells[i]
			var c2 = _cells[j]
			if _do_overlap_and_repel(c1, c2) :
				contains_overlap = true
	
	var placement_complete = !contains_overlap
	return placement_complete
	

func _do_overlap_and_repel(c1: Cell, c2: Cell) -> bool:
	var direction = c1.global_position - c2.global_position
	if direction.length() > c1.radius + c2.radius:
		return false
	
	# repel if they overlap
	var push = c1.radius + c2.radius - direction.length()
	c1.global_position += direction.normalized() * (push * 0.75)
	c2.global_position -= direction.normalized() * (push * 0.75)
	return true
