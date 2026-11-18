extends Node2D

var marker_radius: float = 14.0
var marker_alpha: float = 1.0

func trigger_at(world_pos: Vector2):
	global_position = world_pos
	visible = true
	marker_radius = 18.0
	marker_alpha = 1.0
	queue_redraw()
	var tween = create_tween()
	tween.tween_property(self, "marker_radius", 5.0, 0.32)
	tween.parallel().tween_property(self, "marker_alpha", 0.0, 0.32)
	tween.tween_callback(func(): visible = false)

func _process(_delta):
	if visible:
		queue_redraw()

func _draw():
	if not visible:
		return
	var col = Color(0.3, 0.9, 1.0, marker_alpha)
	draw_arc(Vector2.ZERO, marker_radius, 0, TAU, 24, col, 2.0, true)
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 1.0, 1.0, marker_alpha))
