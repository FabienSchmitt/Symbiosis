extends CharacterBody2D

@export var speed: float = 300

@onready var _sprite = $WhiteCircle

func _ready():
    _sprite.modulate = GameManager.player_data.species.color

func _physics_process(delta):
    var direction = Vector2.ZERO
    direction.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
    direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
    var target_velocity = direction.normalized() * speed 

    velocity = velocity.lerp(target_velocity, 10 * delta)
    move_and_slide()    