extends Node2D


@export var number_of_cells := 50
@export var minimal_cell_radius := 20
@export var maximal_cell_radius = 100

@export var max_iteration := 1000

@onready var camera_2d: DebugCamera = $Camera2D


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
		
	#debug camera settings 
	var rect2 = compute_bounds()
	frame_camera(camera_2d, rect2)

func _draw() -> void:
	var bounds = compute_bounds()
	draw_rect(bounds, Color(4.899, 0.0, 4.899, 0.976), false, 2.0)

func compute_bounds() -> Rect2:
	var min_pos = Vector2.INF
	var max_pos = -Vector2.INF

	for c in _cells:
		min_pos.x = min(min_pos.x, c.global_position.x - c.radius)
		min_pos.y = min(min_pos.y, c.global_position.y - c.radius)
		max_pos.x = max(max_pos.x, c.global_position.x + c.radius)
		max_pos.y = max(max_pos.y, c.global_position.y + c.radius)

	return Rect2(min_pos, max_pos - min_pos)
	
func frame_camera(camera: Camera2D, bounds: Rect2):
	camera.global_position = bounds.get_center()

	var viewport_size = get_viewport_rect().size
	var zoom_x = viewport_size.x / bounds.size.x 
	var zoom_y =  viewport_size.y / bounds.size.y
	
	
	camera.zoom = Vector2.ONE * min(zoom_x, zoom_y) *0.9
	
	print("bounds: ", bounds, "viewport : ", viewport_size)
	print("bounds size : ", bounds.size)
	print("Zoom : ", zoom_x, " ",  zoom_y)

	
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
