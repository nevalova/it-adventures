extends Node2D

# --- Variables Exportadas Editables desde el Inspector de Godot ---
@export_group("Diálogos - Roberto Huerta (Intro)")
@export_multiline var roberto_intro_1: String = "¡%s, qué bueno que te encuentro! ¡Necesito ayuda urgente en la oficina de Finanzas!"
@export_multiline var roberto_intro_2: String = "¡La impresora empezó a hacer ruidos raros, huele a quemado y tiene a la jefa al borde del colapso! ¡Sígueme, corre!"

@export_group("Diálogos - Oficina de Finanzas")
@export_multiline var roberto_office: String = "¡Aquí está el desastre! Bueno... ¡yo ya cumplí con avisar, te dejo con el experto! ¡Suerte!"
@export_multiline var usuaria_office_1: String = "¡Ayuda, por favor! Mandé a imprimir la nómina quincenal y esta máquina del demonio se tragó todo el papel y empezó a disparar tóner hirviendo..."
@export_multiline var usuaria_office_2: String = "¡Si no la neutralizas ahora mismo nos quedamos sin quincena y se incendia el departamento!"

@export_group("Objetivos de Misión")
@export var obj_intro_text: String = "[!] ¡Roberto Huerta viene corriendo a pedir ayuda!"
@export var obj_follow_text: String = "Objetivo: Sigue a Roberto Huerta a la oficina de Finanzas ->"
@export var obj_battle_text: String = "[!] ¡Acércate a la Impresora Maldita y neutralízala!"

@export_group("Velocidades de Cinemática")
@export var roberto_run_in_speed: float = 190.0
@export var roberto_run_office_speed: float = 240.0
@export var roberto_flee_speed: float = 260.0

# --- Referencias de Nodos ---
@onready var player = $Player
@onready var roberto = $RobertoHuerta
@onready var roberto_sprite = $RobertoHuerta/Sprite2D
@onready var usuaria = $Usuaria
@onready var usuaria_sprite = $Usuaria/Sprite2D
@onready var office_trigger = $OfficeTrigger
@onready var enemy_printer = $EnemyPrinter

# HUD & Controls
@onready var hud_hero_name = $CanvasLayer/HUD/HeroInfo/HeroName
@onready var hud_hero_role = $CanvasLayer/HUD/HeroInfo/HeroRole
@onready var hud_stats = $CanvasLayer/HUD/HeroInfo/HeroStats
@onready var btn_switch = $CanvasLayer/HUD/TouchControls/RightBox/SwitchBtn
@onready var touch_controls = $CanvasLayer/HUD/TouchControls
@onready var objective_label = $CanvasLayer/HUD/ObjectiveBanner/Label

# D-Pad táctil
@onready var btn_up = $CanvasLayer/HUD/TouchControls/DpadBox/BtnUp
@onready var btn_down = $CanvasLayer/HUD/TouchControls/DpadBox/BtnDown
@onready var btn_left = $CanvasLayer/HUD/TouchControls/DpadBox/BtnLeft
@onready var btn_right = $CanvasLayer/HUD/TouchControls/DpadBox/BtnRight

# Dialog Box
@onready var dialog_box = $CanvasLayer/DialogBox
@onready var dialog_portrait = $CanvasLayer/DialogBox/Margin/HBox/PortraitFrame/Portrait
@onready var dialog_speaker = $CanvasLayer/DialogBox/Margin/HBox/TextBox/Speaker
@onready var dialog_message = $CanvasLayer/DialogBox/Margin/HBox/TextBox/Message
@onready var dialog_btn = $CanvasLayer/DialogBox/Margin/HBox/BtnContinue

# State Machine
enum State {
	IDLE,
	ROBERTO_RUN_TO_PLAYER,
	ROBERTO_RUN_TO_OFFICE,
	ROBERTO_FLEE,
	FREE_EXPLORE
}

var current_state: State = State.IDLE
var anim_timer: float = 0.0
var dialog_queue: Array = []
var on_dialog_closed_callback: Callable

func _ready():
	var leader = GameManager.get_leader_data()
	hud_hero_name.text = leader["name"]
	hud_hero_role.text = leader["role"]
	hud_stats.text = "HP: %d/%d  |  ATQ: %d" % [leader["hp"], leader["max_hp"], leader["atk"]]
	hud_hero_name.modulate = leader["color"]
	
	btn_switch.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	)
	
	# Conexión táctil del D-Pad
	btn_up.button_down.connect(func(): player.dpad_up = true)
	btn_up.button_up.connect(func(): player.dpad_up = false)
	btn_down.button_down.connect(func(): player.dpad_down = true)
	btn_down.button_up.connect(func(): player.dpad_down = false)
	btn_left.button_down.connect(func(): player.dpad_left = true)
	btn_left.button_up.connect(func(): player.dpad_left = false)
	btn_right.button_down.connect(func(): player.dpad_right = true)
	btn_right.button_up.connect(func(): player.dpad_right = false)
	
	# Conexión del botón de diálogo
	dialog_btn.pressed.connect(_advance_dialog)
	
	# Conexión del trigger de la oficina
	office_trigger.body_entered.connect(_on_office_trigger_entered)
	
	# Verificar estado de la partida
	if not GameManager.intro_cutscene_done:
		# Secuencia inicial: jugador quieto mirando a la derecha
		player.global_position = Vector2(140, 200)
		player.set_facing(Vector2.RIGHT)
		player.can_move = false
		
		# Roberto empieza corriendo desde la derecha
		roberto.global_position = Vector2(480, 200)
		roberto.visible = true
		current_state = State.ROBERTO_RUN_TO_PLAYER
		touch_controls.visible = false
		objective_label.text = obj_intro_text
	else:
		# Ya se hizo la intro
		if GameManager.player_saved_position != Vector2.ZERO:
			player.global_position = GameManager.player_saved_position
		player.can_move = true
		touch_controls.visible = true
		
		if GameManager.office_cutscene_done:
			# Roberto ya huyó de la escena
			roberto.visible = false
			objective_label.text = obj_battle_text
		else:
			# Roberto está esperando en la oficina
			roberto.global_position = Vector2(880, 200)
			roberto_sprite.frame = 2 * 4 + 0 # Mirando a la izquierda
			objective_label.text = obj_follow_text
		current_state = State.FREE_EXPLORE

func _process(delta):
	anim_timer += delta
	
	# Animación de pánico leve de la Usuaria
	if usuaria.visible:
		var panic_col = int(anim_timer * 4.0) % 4
		usuaria_sprite.frame = 10 * 4 + panic_col
	
	match current_state:
		State.ROBERTO_RUN_TO_PLAYER:
			# Roberto corre hacia la izquierda hacia el jugador
			var move_speed = roberto_run_in_speed
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 8.0) % 4
			roberto_sprite.frame = 2 * 4 + run_col # Fila 2 = Izquierda
			
			if roberto.position.x <= 200.0:
				roberto.position.x = 200.0
				roberto_sprite.frame = 2 * 4 + 0 # Parado mirando al jugador
				current_state = State.IDLE
				_start_intro_dialog()
				
		State.ROBERTO_RUN_TO_OFFICE:
			# Roberto sale corriendo a la oficina a la derecha
			var move_speed = roberto_run_office_speed
			roberto.position.x += move_speed * delta
			var run_col = int(anim_timer * 9.0) % 4
			roberto_sprite.frame = 6 * 4 + run_col # Fila 6 = Derecha
			
			if roberto.position.x >= 880.0:
				roberto.position.x = 880.0
				roberto_sprite.frame = 2 * 4 + 0 # Espera mirando a la izquierda
				current_state = State.FREE_EXPLORE
				
		State.ROBERTO_FLEE:
			# Roberto sale corriendo huyendo de la oficina (hacia la izquierda y desaparece)
			var move_speed = roberto_flee_speed
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 10.0) % 4
			roberto_sprite.frame = 2 * 4 + run_col # Fila 2 = Izquierda huyendo
			
			if roberto.position.x <= 500.0:
				roberto.visible = false
				current_state = State.FREE_EXPLORE

func _start_intro_dialog():
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	
	dialog_queue = [
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": roberto_intro_1 % hero_name
		},
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": roberto_intro_2
		}
	]
	
	on_dialog_closed_callback = func():
		GameManager.intro_cutscene_done = true
		current_state = State.ROBERTO_RUN_TO_OFFICE
		player.can_move = true
		touch_controls.visible = true
		objective_label.text = obj_follow_text
	
	_show_next_in_queue()

func _on_office_trigger_entered(body):
	if body == player and not GameManager.office_cutscene_done:
		GameManager.office_cutscene_done = true
		player.can_move = false
		player.set_facing(Vector2.RIGHT)
		touch_controls.visible = false
		
		# Secuencia de llegada a la oficina
		dialog_queue = [
			{
				"speaker": "Roberto Huerta",
				"portrait": "res://assets/characters/roberto_huerta_portrait.png",
				"color": Color("#f1c40f"),
				"text": roberto_office
			},
			{
				"speaker": "Usuaria de Finanzas",
				"portrait": "res://assets/characters/usuaria_portrait.png",
				"color": Color("#fd79a8"),
				"text": usuaria_office_1
			},
			{
				"speaker": "Usuaria de Finanzas",
				"portrait": "res://assets/characters/usuaria_portrait.png",
				"color": Color("#fd79a8"),
				"text": usuaria_office_2
			}
		]
		
		on_dialog_closed_callback = func():
			current_state = State.ROBERTO_FLEE
			player.can_move = true
			touch_controls.visible = true
			objective_label.text = obj_battle_text
		
		_show_next_in_queue()

func _show_next_in_queue():
	if dialog_queue.is_empty():
		dialog_box.visible = false
		if on_dialog_closed_callback.is_valid():
			var cb = on_dialog_closed_callback
			on_dialog_closed_callback = Callable()
			cb.call()
		return
	
	var data = dialog_queue.pop_front()
	dialog_speaker.text = data["speaker"]
	dialog_speaker.modulate = data["color"]
	dialog_message.text = data["text"]
	
	if ResourceLoader.exists(data["portrait"]):
		dialog_portrait.texture = load(data["portrait"])
		dialog_portrait.visible = true
	else:
		dialog_portrait.visible = false
		
	dialog_box.visible = true

func _advance_dialog():
	_show_next_in_queue()

func _unhandled_input(event):
	if dialog_box.visible:
		if event.is_action_pressed("ui_accept") \
		or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)) \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed):
			get_viewport().set_input_as_handled()
			_advance_dialog()
