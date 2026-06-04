extends Node
class_name Swarm

var _particules : Array[Particule]
var _target: Cell
var _center: Vector2
var species : Species

var seek_weight: float = 30
var boids_weight: float = 5
var align_weight: float = 0.5
var cohesion_weight: float = 1
var avoid_weight: float = 20
var visibility_threshold := 75

var flow_field: FlowField
var noise: FastNoiseLite
var speed_sample : float = 0;


func _init(particules: Array[Particule], target: Cell) -> void:
	_particules = particules
	_target = target
	flow_field = target.get_flow_field()
	print("target flow field : ", flow_field)
	connect_particules()
	create_noise()

func connect_particules():
	for p in _particules:
		p.reached.connect(on_reached.bind(p))

func _physics_process(delta: float) -> void:
	compute_center()
	
	speed_sample = fposmod(speed_sample + delta, 1)

	#print("particules : ", flow_field.destination_cell.world_position, flow_field.destination_cell.grid_position)
	for p in _particules:
		var cell_below = flow_field.get_cell_from_world(p.global_position)
		var direction = cell_below.flow.normalized() 

		# adding some noise
		var angle = randf() * TAU

		var boid_force = get_boids_force(p, get_neighbors(p)).normalized() 
		p.velocity += boid_force * boids_weight + direction * seek_weight
		p.velocity = p.velocity.limit_length(p.speed)
		p.global_position = p.global_position + (p.velocity * delta * p.curve_max_speed.sample(speed_sample))
		p.rotation = p.velocity.angle() + deg_to_rad(90)
	
	if _particules.size() == 0:
		queue_free()


func create_noise() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()  # Optional random seed
	noise.frequency = 0.02

func compute_center() -> void : 
	var sum = Vector2.ZERO
	for p in _particules: 
		sum += p.position

	_center = sum / _particules.size()

func get_boids_force(p: Particule, n: Array[Particule]) -> Vector2:
	if n == []:
		return Vector2.ZERO
	return avoid(p, n) * avoid_weight + stick(p, n) * cohesion_weight + align(p, n) * align_weight;

func get_neighbors(current: Particule) -> Array[Particule]:
	return _particules.filter(func(other) : return other != current && \
		other.position.distance_to(current.position) < visibility_threshold)


func avoid(current: Particule, neighbors: Array[Particule]) -> Vector2:
	var result = Vector2.ZERO

	for other in neighbors:
		var distance_to = current.position.distance_to(other.position)
		if distance_to > 25 : continue
		result += (current.position - other.position).normalized() * (1 - distance_to / visibility_threshold)
	return result

func stick(current: Particule, neighbors: Array[Particule]) -> Vector2:
	var center = neighbors.reduce(func(c, p): return p.position + c, Vector2.ZERO) / neighbors.size()
	return (center - current.position).normalized()

func align(current: Particule, neighbors: Array[Particule]) -> Vector2:
	var avg = Vector2.ZERO
	for n in neighbors:
		avg += n.velocity
	avg /= neighbors.size()
	return (avg - current.velocity).normalized()

func on_reached(p: Particule):
	print("reached")
	_particules.erase(p)
	p.queue_free()
