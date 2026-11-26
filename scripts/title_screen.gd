extends Control

@onready var press_start_screen = $PressStartScreen
@onready var touch_button = $PressStartScreen/TouchButton
@onready var prompt_label = $PressStartScreen/PromptVBox/PromptLabel

@onready var blue_rpg_menu = $BlueRPGMenu
@onready var btn_continue = $BlueRPGMenu/Margin/VBox/BtnContinue
@onready var btn_start = $BlueRPGMenu/Margin/VBox/BtnStart
@onready var btn_options = $BlueRPGMenu/Margin/VBox/BtnOptions
@onready var btn_fullscreen = $BlueRPGMenu/Margin/VBox/BtnFullscreen
@onready var btn_install = $BlueRPGMenu/Margin/VBox/BtnInstall
@onready var btn_back = $BlueRPGMenu/Margin/VBox/BtnBack

@onready var modal_options = $ControlOptionsModal
@onready var btn_mode_dpad = $ControlOptionsModal/Margin/VBox/CardsBox/BtnModeDpad
@onready var btn_mode_joystick = $ControlOptionsModal/Margin/VBox/CardsBox/BtnModeJoystick
@onready var btn_mode_point_click = $ControlOptionsModal/Margin/VBox/CardsBox/BtnModePointClick
@onready var btn_close_options = $ControlOptionsModal/Margin/VBox/BtnCloseOptions

var blink_timer: float = 0.0

func _ready():
	GameManager.preload_scene("res://scenes/character_select.tscn")
	GameManager.preload_scene("res://scenes/overworld.tscn")
	
	# Conexiones de pantalla inicial
	touch_button.pressed.connect(_open_blue_menu)
	
	# Conexiones del menú azul
	btn_continue.pressed.connect(_continue_game)
	btn_start.pressed.connect(_start_game)
	btn_options.pressed.connect(_open_options)
	btn_fullscreen.pressed.connect(_toggle_fullscreen)
	btn_install.pressed.connect(_trigger_install_or_share)
	btn_back.pressed.connect(_close_blue_menu)
	
	# Conexiones de opciones de control
	btn_close_options.pressed.connect(_close_options)
	btn_mode_dpad.pressed.connect(func(): _select_control_mode("dpad"))
	btn_mode_joystick.pressed.connect(func(): _select_control_mode("joystick"))
	btn_mode_point_click.pressed.connect(func(): _select_control_mode("point_and_click"))
	
	# Estado inicial: mostrar pantalla de presionar/tocar
	press_start_screen.visible = true
	blue_rpg_menu.visible = false
	modal_options.visible = false
	
	_update_ui_state()

func _open_blue_menu():
	press_start_screen.visible = false
	blue_rpg_menu.visible = true
	modal_options.visible = false
	
	if GameManager.has_save_file():
		btn_continue.visible = true
		btn_continue.text = "CONTINUAR PARTIDA"
		btn_start.text = "NUEVA PARTIDA"
	else:
		btn_continue.visible = false
		btn_start.text = "INICIAR PARTIDA"
		
	_update_ui_state()

func _close_blue_menu():
	blue_rpg_menu.visible = false
	modal_options.visible = false
	press_start_screen.visible = true

func _continue_game():
	if GameManager.load_game():
		GameManager.change_scene_instant(get_tree(), "res://scenes/overworld.tscn")
	else:
		_start_game()

func _start_game():
	GameManager.change_scene_instant(get_tree(), "res://scenes/character_select.tscn")

func _toggle_fullscreen():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
			if (!document.fullscreenElement) {
				document.documentElement.requestFullscreen().catch(function(e) { console.log(e); });
			} else {
				if (document.exitFullscreen) {
					document.exitFullscreen();
				}
			}
		""")
	
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
	get_tree().create_timer(0.1).timeout.connect(_update_fullscreen_button)

func _update_fullscreen_button():
	var mode = DisplayServer.window_get_mode()
	var is_fs = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if is_fs:
		btn_fullscreen.text = "PANTALLA COMPLETA: ACTIVADA"
		btn_fullscreen.add_theme_color_override("font_color", Color(0.3, 1.0, 0.7, 1.0))
	else:
		btn_fullscreen.text = "PANTALLA COMPLETA: DESACTIVADA"
		btn_fullscreen.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0, 1.0))

func _update_ui_state():
	var cur = GameManager.control_type
	var mode_info = GameManager.control_modes.get(cur, {})
	var short_name = mode_info.get("short", "D-Pad")
	btn_options.text = "TIPO DE CONTROL: " + short_name.to_upper()
	
	_format_mode_button(btn_mode_dpad, "dpad", "1. D-Pad Clasico (Botones Fijos)")
	_format_mode_button(btn_mode_joystick, "joystick", "2. Analogo Arrastrable (Joystick Tactil)")
	_format_mode_button(btn_mode_point_click, "point_and_click", "3. Point and Click (Tocar para Moverse)")
	
	_update_fullscreen_button()

func _format_mode_button(btn: Button, mode_key: String, base_title: String):
	var is_selected = (GameManager.control_type == mode_key)
	if is_selected:
		btn.text = "  [*] " + base_title + "  <ACTIVO>"
		btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.7, 1.0))
	else:
		btn.text = "  [ ] " + base_title
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

func _trigger_install_or_share():
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (window.triggerShareOrInstall) { window.triggerShareOrInstall(); }")


func _process(delta):
	blink_timer += delta * 4.0
	if prompt_label and press_start_screen.visible:
		prompt_label.modulate.a = 0.35 + 0.65 * abs(sin(blink_timer))

func _input(event):
	if modal_options.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_options()
		return
		
	if blue_rpg_menu.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_blue_menu()
		return
		
	if press_start_screen.visible:
		if event is InputEventScreenTouch and event.pressed:
			_open_blue_menu()
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_blue_menu()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept") \
		or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
			_open_blue_menu()
			get_viewport().set_input_as_handled()
