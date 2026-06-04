extends Node

var _cells: Array[Cell] = []

func _ready() -> void:
    call_deferred("get_cells")
    

func get_cells() -> void:
    for cell in get_tree().get_nodes_in_group("cells"):
        _cells.append(cell)

func get_species_cells(species: Species) -> Array[Cell] :
    return _cells.filter(func(c): return c.species == species)


func get_neighboring_cells(visibility : float, species: Species) -> Array[Cell] :
    # for now we don't care about visibility.
    # var species_cells = get_species_cells(species)
    return _cells.filter(func(c): return c.species != species)

