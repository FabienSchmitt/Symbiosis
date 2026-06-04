class_name IAPlayer
extends Node

@onready var attack_timer = %AttackTimer

@export var species: Species
@export var behavior: float = 1
@export var visibility := 10_000_000.0


func _ready() -> void:
	attack_timer.timeout.connect(_plan_attacks)


func get_close_ennemy_cells() -> Array[Cell] : 
	return CellsManager.get_neighboring_cells(visibility, species)


func get_my_cells() -> Array[Cell]:
	return CellsManager.get_species_cells(species)

func is_in_attack_range(target: Cell, source: Cell) -> bool :
	return true

func _plan_attacks():
	var my_cells = get_my_cells()
	var possible_targets = get_close_ennemy_cells()

	var valid_targets : Dictionary = {}

	for target in possible_targets:
		for my_cell in my_cells : 
			if target.population < my_cell.population / 2.0:
				if !valid_targets.find_key(target):
					valid_targets.get_or_add(target, [my_cell])
				else : 
					valid_targets.get(target).append(my_cell)
	
	if !valid_targets.is_empty():
		select_random_attack(valid_targets)


func select_random_attack(targets: Dictionary):
	var keys = targets.keys()
	var key = keys.pick_random()

	var source = targets.get(key).pick_random()
	attack(key, source)


func attack(target : Cell, source: Cell) -> void : 
	GameManager.attack_cell(target, [source])
