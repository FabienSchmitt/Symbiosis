extends Node2D

@export var start_node: Node2D
@export var end_node: Node2D
@export var color: Color = Color(0.5, 0.8, 1.0, 0.4)
@export var wave_amplitude: float = 8.0
@export var wave_frequency: float = 5.0
@export var segments: int = 20

var t: float = 0.0

func _process(delta):
    t += delta
    queue_redraw()

func _draw():
    if not start_node or not end_node:
        return
    var points = []
    for i in range(segments + 1):
        var f = i / float(segments)
        var pos = start_node.global_position.lerp(end_node.global_position, f)
        var offset = Vector2(0, sin(f * wave_frequency + t * 4.0) * wave_amplitude)
        points.append(to_local(pos + offset.rotated((end_node.global_position - start_node.global_position).angle())))
    draw_polyline(points, color, 2.0)
