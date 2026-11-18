extends Control

# Virtual Joystick para control análogo arrastrable
signal joystick_moved(vector: Vector2)
signal joystick_released()

@export var max_radius: float = 40.0
@export var base_radius: float = 46.0
@export var knob_radius: float = 20.0

var center: Vector2 = Vector2.ZERO
var knob_pos: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var active_touch_index: int = -1

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	_update_center()
	resized.connect(_update_center)

func _update_center():
	center = size * 0.5
	knob_pos = center
	queue_redraw()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_stop_drag()
	elif event is InputEventMouseMotion and is_dragging:
		_process_drag(event.position)
	elif event is InputEventScreenTouch:
		if event.pressed and not is_dragging:
			active_touch_index = event.index
			_start_drag(event.position)
		elif not event.pressed and event.index == active_touch_index:
			_stop_drag()
	elif event is InputEventScreenDrag and is_dragging:
		if event.index == active_touch_index or active_touch_index == -1:
			_process_drag(event.position)

func _start_drag(pos: Vector2):
	is_dragging = true
	_process_drag(pos)

func _process_drag(pos: Vector2):
	var offset = pos - center
	if offset.length() > max_radius:
		offset = offset.normalized() * max_radius
	knob_pos = center + offset
	var output = offset / max_radius
	joystick_moved.emit(output)
	queue_redraw()

func _stop_drag():
	is_dragging = false
	active_touch_index = -1
	knob_pos = center
	joystick_released.emit()
	queue_redraw()

func _draw():
	if not visible:
		return
		
	# Fondo de la base del joystick
	draw_circle(center, base_radius, Color(0.04, 0.1, 0.22, 0.6))
	# Borde exterior de la base
	draw_arc(center, base_radius, 0, TAU, 32, Color(0.2, 0.85, 1.0, 0.7), 2.0, true)
	
	# Cruz tenue central de orientación
	draw_line(center - Vector2(10, 0), center + Vector2(10, 0), Color(0.3, 0.6, 0.9, 0.4), 1.0)
	draw_line(center - Vector2(0, 10), center + Vector2(0, 10), Color(0.3, 0.6, 0.9, 0.4), 1.0)
	
	# Pomo central / Knob
	var knob_color = Color(0.25, 0.8, 1.0, 0.85) if is_dragging else Color(0.2, 0.6, 0.9, 0.65)
	var knob_center_color = Color(0.9, 0.98, 1.0, 0.95) if is_dragging else Color(0.7, 0.9, 1.0, 0.8)
	
	draw_circle(knob_pos, knob_radius, knob_color)
	draw_arc(knob_pos, knob_radius, 0, TAU, 24, Color(1, 1, 1, 0.9), 1.5, true)
	draw_circle(knob_pos, knob_radius * 0.4, knob_center_color)
