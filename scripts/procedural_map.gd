extends Node2D
class_name ProceduralMap

@export var width := 200
@export var height := 100
@export var alive_percentage := 75.0
@export var pixel_size := 5
var previous_grid : Dictionary[Vector2i, bool] = {}
var grid :Dictionary[Vector2i, bool] = {}

func _ready() -> void:
	for j in height:
		for i in width:
			var is_alive = randf_range(0, 100) <= alive_percentage
			grid.get_or_add(Vector2i(i, j), is_alive)
			
	
	print(grid.size())
			

func _process(delta: float) -> void:
	if (Input.is_action_just_released("right")):
		previous_grid = grid.duplicate()
		_process_next_generation()
		queue_redraw()
		
	if (Input.is_action_just_released("left")):
		flood_fill()

func _process_next_generation() -> void:
	for i in width:
		for j in height:
			var dead_neighbors_count = count_dead_neighbors(i, j)
			var old_value = previous_grid.get(Vector2i(i, j))
			var is_dead = ((0 if old_value else 1) + dead_neighbors_count) >= 5
			grid[Vector2i(i, j)] = !is_dead

func count_dead_neighbors(i: int, j: int) -> int:
	var count = 0
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if x == 0 && y == 0: continue
			if not previous_grid.get(Vector2i(i + x, j + y)):
				count = count + 1
	return count
	
func flood_fill() -> void:
	# we want to make sure that every room is connected to the other
	# we pick one random alive cell and flood from there every connected cell. 
	var alives: Array[Vector2i] = grid.keys().filter(func(x: Vector2i) -> bool: return grid[x])
	var random_start = alives[randi_range(0, alives.size())]
	
	var alives_flooded : Array[Vector2i] = [random_start]
	var newly_flooded : Array[Vector2i] = [random_start]
	
	while newly_flooded.size() > 0:
		flood_neighbors(newly_flooded, alives_flooded)
		
	# check if all the alives are flooded?
	alives.sort()
	alives_flooded.sort()
	if alives_flooded == alives:
		print("fully connected")
		
	else:
		print("not connected")
	

func flood_neighbors(newly_flooded: Array[Vector2i], alives_flooded: Array[Vector2i]) -> void:
	var start := newly_flooded[0]
	for i in [-1, 0, 1]:
		for j in [-1, 0, 1]:
			if i == 0 && j == 0: continue
			var index = start + Vector2i(i, j)
			if grid.get(index) && !alives_flooded.has(index):
				newly_flooded.append(index)
				alives_flooded.append(index)	
	newly_flooded.remove_at(0)


func _draw() -> void:
	for i in width:
		for j in height:
			var value = grid.get(Vector2i(i, j))
			var color = Color.WHITE if value else Color.BLACK
			var rect = Rect2(Vector2i(i, j) * pixel_size, Vector2.ONE * pixel_size)
			draw_rect(rect, color)
