extends Node2D

@export var background_color: Color = Color.BROWN

func _ready() -> void:
	print("init scene")
	GameManager.init_scene()
	RenderingServer.set_default_clear_color(background_color)
