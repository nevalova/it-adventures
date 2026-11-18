extends Control

@onready var prompt_label = $MenuVBox/PromptLabel
@onready var btn_start = $MenuVBox/BtnStart
@onready var btn_options = $MenuVBox/BtnOptions
@onready var modal_options = $ControlOptionsModal
@onready var btn_mode_dpad = $ControlOptionsModal/Margin/VBox/CardsBox/BtnModeDpad
@onready var btn_mode_joystick = $ControlOptionsModal/Margin/VBox/CardsBox/BtnModeJoystick
@onready var btn_mode_point_click = $ControlOptionsModal/Margin/VBox/CardsBox/BtnModePointClick
@onready var btn_close_options = $ControlOptionsModal/Margin/VBox/BtnCloseOptions

var blink_timer: float = 0.0

func _ready():
	GameManager.preload_scene("res://scenes/character_select.tscn")
	GameManager.preload_scene("res://scenes/overworld.tscn")
	
	btn_start.pressed.connect(_start_game)
	btn_options.pressed.connect(_open_options)
	btn_close_options.pressed.connect(_close_options)
	
	btn_mode_dpad.pressed.connect(func(): _select_control_mode("dpad"))
	btn_mode_joystick.pressed.connect(func(): _select_control_mode("joystick"))
	btn_mode_point_click.pressed.connect(func(): _select_control_mode("point_and_click"))
	
	_update_ui_state()

func _update_ui_state():
	var cur = GameManager.control_type
	var mode_info = GameManager.control_modes.get(cur, {})
	var short_name = mode_info.get("short", "D-Pad")
	btn_options.text = "⚙ TIPO DE CONTROL: " + short_name.to_upper()
	
	# Actualizar estilo y textos de los botones de opciones
	_format_mode_button(btn_mode_dpad, "dpad", "1. D-Pad Clásico (Botones Fijos)")
	_format_mode_button(btn_mode_joystick, "joystick", "2. Análogo Arrastrable (Joystick Táctil)")
	_format_mode_button(btn_mode_point_click, "point_and_click", "3. Point and Click (Tocar para Moverse)")

func _format_mode_button(btn: Button, mode_key: String, base_title: String):
	var is_selected = (GameManager.control_type == mode_key)
	if is_selected:
		btn.text = "  [✓] " + base_title + "  <ACTIVO>"
		btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.7, 1.0))
	else:
		btn.text = "  [  ] " + base_title
		btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))

func _select_control_mode(new_mode: String):
	GameManager.set_control_type(new_mode)
	_update_ui_state()

func _open_options():
	modal_options.visible = true
	_update_ui_state()

func _close_options():
	modal_options.visible = false
	_update_ui_state()

func _process(delta):
	blink_timer += delta * 4.0
	prompt_label.modulate.a = 0.4 + 0.6 * abs(sin(blink_timer))

func _start_game():
	GameManager.change_scene_instant(get_tree(), "res://scenes/character_select.tscn")

func _input(event):
	if modal_options.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_options()
		return
		
	if event.is_action_pressed("ui_accept") \
	or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		_start_game()
