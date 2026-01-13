extends Area2D
class_name Cell

@export var replication_speed := 2.0
@export var size := 5
@export var max_size := 100
@export var species: Species

@onready var size_label : Label = $Label
@onready var _selected_circle : Sprite2D  = %SelectedCircle
@onready var _circle: Sprite2D = %BigDrawnCircle
@onready var swarm_multimesh : MultiMeshInstance2D = %SwarmMeshInstance
@onready var flow_field_manager: FlowFieldManager = %FlowFieldManager
@onready var _replication_timer: Timer = %ReplicationTimer
@onready var _light: PointLight2D = %PointLight2D


var flow_field: FlowField

func _ready() -> void:
	set_timer()
	size_label.text = str(size)
	if species == null : species = Species.new()
	_circle.modulate = species.color
	_selected_circle.modulate = species.color
	
	#shaders stuff
	# _circle.material = _circle.material.duplicate()
	# set_shader()

	_light.enabled = GameManager.player_data.species == species
	# _light.energy = 2.0 if GameManager.player_data.species == species else 0.4

func _process(delta: float) -> void:
	if (size >= max_size) : return
	if (_replication_timer.is_stopped()) :
		_replication_timer.start()

	_light.enabled = GameManager.player_data.species == species


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT  and event.is_pressed():
		if flow_field == null: 
			flow_field = flow_field_manager.compute_flow_field(global_position)
		print("flow field attacked : ", flow_field)
		GameManager.attack_cell(self)

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		GameManager.add_selected_cell(self)

func set_timer() -> void:
	_replication_timer.wait_time = species.replication_speed  # seconds	
	_replication_timer.timeout.connect(_on_timer_timeout)
	# in case, there is a change of species, restart timer
	_replication_timer.start()

# func set_shader() -> void:
# 	_circle.material.set_shader_parameter("base_color", species.color)

func update_species(new_species: Species) -> void:
	# TODO : when we have some other way to get the species.
	species = new_species
	_selected_circle.modulate = species.color
	_circle.modulate = species.color
	# set_shader()

func _on_timer_timeout() -> void:
	if species.is_neutral: return
	size += 1
	size_label.text = str(size)

func on_click():
	#create_swarm_multi_mesh()
	pass

func attack(target: Cell):
	var swarm_size = size / 2
	size -= swarm_size
	var swarm = Globals.swarm_factory.create_swarm(self, target, swarm_size)
	get_tree().current_scene.add_child(swarm)
	size_label.text = str(size)

# FOR MULTIMESH USAGE
# func create_swarm_multi_mesh():
# 	var swarm_size = size/2
# 	size -= swarm_size
# 	size_label.text = str(size)
# 	swarm_multimesh.spawn_swarm(self.position, swarm_size)

func select(selected: bool) -> void:
	_selected_circle.visible = selected

func damage(damage: int, particule_species: Species) -> void:
	size -= damage
	if size < 0:
		update_species(particule_species)
		size = size * -1
	size_label.text = str(size)
