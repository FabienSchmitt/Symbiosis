extends Area2D
class_name Particule

@export var speed := 300.0
@export var curve_max_speed : Curve 
@export var default_color := Color.BLUE
@onready var sprite : Sprite2D = $Triangle

signal reached
var curve: Curve2D

var target : Cell
var source: Cell

var velocity = Vector2.ZERO
var species: Species
var current_color : Color

var active_ray := 0
var obstace_in_front = false

func _ready() -> void:
	var base_color = default_color if species == null else species.color
	var color_adjust = randf() / 5.0 
	
	current_color = base_color + Color(color_adjust, color_adjust, color_adjust)
	sprite.modulate = current_color
	curve = Curve2D.new()
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area != target: return

	var damage = 1
	if target.species == species:
		damage = -1
	target.damage(damage, species)
	reached.emit()
