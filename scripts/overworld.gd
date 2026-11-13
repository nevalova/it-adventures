extends Node2D

# --- Variables Exportadas Editables desde el Inspector de Godot ---
@export_group("Diálogos - Roberto Huerta (Intro)")
@export_multiline var roberto_intro_1: String = "¡%s, qué bueno que te encuentro! ¡Necesito ayuda urgente en la oficina de Finanzas!"
@export_multiline var roberto_intro_2: String = "¡La impresora empezó a hacer ruidos raros, huele a quemado y tiene a la jefa al borde del colapso! ¡Sígueme, corre!"

@export_group("Diálogos - Oficina de Finanzas")
@export_multiline var roberto_office: String = "¡Aquí está el desastre! Bueno... ¡yo ya cumplí con avisar, te dejo con el experto! ¡Suerte!"
@export_multiline var usuaria_office_1: String = "¡Ayuda, por favor! Mandé a imprimir la nómina quincenal y esta máquina del demonio se tragó todo el papel y empezó a disparar tóner hirviendo..."
@export_multiline var usuaria_office_2: String = "¡Si no la neutralizas ahora mismo nos quedamos sin quincena y se incendia el departamento!"

@export_group("Diálogos - Victoria y Fin de Demo")
@export_multiline var victory_jefa_1: String = "¡Muchísimas gracias, %s! ¡Salvaste la nómina quincenal y a todo el departamento de Finanzas!"
@export_multiline var victory_jefa_2: String = "Esa máquina endemoniada casi destruye todos los balances y el servidor. ¡Eres un héroe de Sistemas!"
@export_multiline var victory_demo_text: String = "¡GRACIAS POR JUGAR, %s! ESTO SOLO ES UN DEMO.\nHas completado con éxito la primera misión de IT Adventures."
@export_multiline var jefa_chat_post: String = "¡Gracias de nuevo, %s! Por fin podemos trabajar en paz en nuestros escritorios. ¡Te ganaste café gratis de por vida en Finanzas!"

@export_group("Diálogos - Compañeros de Oficina")
@export_multiline var carlos_panic: String = "¡Cuidado con esa máquina! ¡No te acerques sin reiniciar el spooler antes!"
@export_multiline var carlos_thanks: String = "¡Qué alivio, %s! Ya estaba sudando frío pensando que me tocaría hacer las facturas a mano con máquina de escribir. ¡Excelente trabajo!"

@export_multiline var mariana_panic: String = "¡Ay no! ¡Los balances contables del trimestre se van a perder si esa impresora explota!"
@export_multiline var mariana_thanks: String = "¡Hola %s! Menos mal que llegaste a tiempo. Estábamos a minutos de una catástrofe fiscal. ¡Muchas gracias por rescatarnos!"

@export_multiline var printer_neutralized_text: String = "La Impresora Maldita yace en silencio, desconectada y sin tóner. Un cartel pegado dice: 'FUERA DE SERVICIO - SALVADA POR SISTEMAS'."

@export_group("Objetivos de Misión")
@export var obj_intro_text: String = "[!] ¡Roberto Huerta viene corriendo a pedir ayuda!"
@export var obj_follow_text: String = "Objetivo: Sigue a Roberto Huerta a la oficina de Finanzas ->"
@export var obj_battle_text: String = "[!] ¡Acércate a la Impresora Maldita y neutralízala!"
@export var obj_victory_text: String = "[!] ¡Victoria! Impresora neutralizada y quincena a salvo."

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
@onready var carlos = $Carlos
@onready var carlos_sprite = $Carlos/Sprite2D
@onready var mariana = $Mariana
@onready var mariana_sprite = $Mariana/Sprite2D

# NPCs Ociosos / Chistosos
@onready var don_ramiro = $DonRamiro
@onready var lic_brenda = $LicBrenda
@onready var paco_godinez = $PacoGodinez

# Boss Sombras del Pasado
@onready var dragon_boss = $DragonBoss
@onready var dragon_boss_sprite = $DragonBoss/Sprite2D
@onready var dark_overlay = $CanvasLayer/DarkOverlay

@onready var office_trigger = $OfficeTrigger
@onready var enemy_printer = $EnemyPrinter
@onready var enemy_printer_sprite = $EnemyPrinter/Sprite2D
@onready var enemy_printer_nametag = $EnemyPrinter/NameTag

# HUD & Controls
@onready var hud_hero_name = $CanvasLayer/HUD/HeroInfo/HeroName
@onready var hud_hero_role = $CanvasLayer/HUD/HeroInfo/HeroRole
@onready var hud_stats = $CanvasLayer/HUD/HeroInfo/HeroStats
@onready var btn_switch = $CanvasLayer/HUD/TouchControls/RightBox/SwitchBtn
@onready var btn_demo_modal = $CanvasLayer/HUD/TouchControls/RightBox/BtnDemoModal
@onready var btn_interact = $CanvasLayer/HUD/TouchControls/RightBox/BtnInteract
@onready var touch_controls = $CanvasLayer/HUD/TouchControls
@onready var objective_label = $CanvasLayer/HUD/ObjectiveBanner/Label
@onready var interact_banner = $CanvasLayer/HUD/InteractBanner
@onready var interact_label = $CanvasLayer/HUD/InteractBanner/Label

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

# Demo Complete Modal
@onready var demo_modal = $CanvasLayer/DemoCompleteModal
@onready var demo_title = $CanvasLayer/DemoCompleteModal/Margin/VBox/Title
@onready var demo_subtitle = $CanvasLayer/DemoCompleteModal/Margin/VBox/SubTitle
@onready var demo_body = $CanvasLayer/DemoCompleteModal/Margin/VBox/BodyText
@onready var btn_restart_demo = $CanvasLayer/DemoCompleteModal/Margin/VBox/ButtonsHBox/BtnRestartDemo
@onready var btn_close_modal = $CanvasLayer/DemoCompleteModal/Margin/VBox/ButtonsHBox/BtnCloseModal

# State Machine
enum State {
	IDLE,
	ROBERTO_RUN_TO_PLAYER,
	ROBERTO_RUN_TO_OFFICE,
	ROBERTO_FLEE,
	FREE_EXPLORE,
	ROBERTO_LEAD_TO_BOSS
}

var current_state: State = State.IDLE
var anim_timer: float = 0.0
var dialog_queue: Array = []
var on_dialog_closed_callback: Callable
var current_interactable: String = ""

# Frases chistosas de oficina para NPCs ociosos
var don_ramiro_quotes: Array = [
	"Muchachos, ¿alguien sabe a qué hora traen los tacos de canasta? Ya son las 11:15 y mi cuerpo exige manteca con salsa verde.",
	"Dicen que si dejas una computadora prendida más de 40 días, Windows cobra conciencia y se une al sindicato.",
	"Yo por eso guardo todos mis archivos confidenciales en la Papelera de Reciclaje... nadie busca ahí, es el escondite perfecto.",
	"En mis tiempos no había Wi-Fi, nos gritábamos las celdas de Excel de cubículo a cubículo.",
	"¿Ustedes creen que si le pongo un post-it a la cámara web evito que el SAT me audite las facturas?"
]

var lic_brenda_quotes: Array = [
	"¡Aviso parroquial! Queda terminantemente prohibido meter pescado con ajo al microondas del piso 3. Se los advierto por las buenas.",
	"Mandé un correo con copia a Dirección General, Finanzas, RH y a la ONU para que quede constancia por escrito de que se acabaron los clips.",
	"¡Saludos cordiales! ... Bueno, ni tan cordiales porque urge para ayer a primera hora.",
	"Estamos organizando la dinámica de integración: 'Construyendo puentes con popotes y bombones'. La asistencia es obligatoria y sin goce de horas extras.",
	"Si alguien vio una taza que dice 'La Mejor Jefa del Mundo', devuélvanla de inmediato o habrá consecuencias en el aguinaldo."
]

var paco_godinez_quotes: Array = [
	"El secreto supremo de la oficina es caminar rápido por el pasillo con una carpeta amarilla y cara de estresado. Nadie se atreve a pedirte nada.",
	"Llevo 3 horas fingiendo que leo un PDF de 80 páginas sobre políticas de seguridad cibernética. En realidad estoy viendo autos usados.",
	"¿Tú crees que si desconecto el cable negro con franjas amarillas se cancela la junta de las 4 PM? Piénsalo bien...",
	"El café de la empresa no despierta, solo acelera el pánico existencial de las 2 de la tarde.",
	"Vengo llegando del baño... estuve 40 minutos esperando a que se me pasaran las ganas de trabajar."
]

func _ready():
	$Player/Camera2D.make_current()
	var leader = GameManager.get_leader_data()
	hud_hero_name.text = leader["name"]
	hud_hero_role.text = leader["role"]
	hud_stats.text = "Nv. %d  |  HP: %d/%d  |  ATQ: %d  |  EXP: %d/%d" % [
		leader.get("level", 1),
		leader["hp"],
		leader["max_hp"],
		leader["atk"],
		leader.get("exp", 0),
		leader.get("exp_to_next", 60)
	]
	hud_hero_name.modulate = leader["color"]
	
	btn_switch.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	)
	
	btn_demo_modal.pressed.connect(func():
		_open_demo_modal()
	)
	
	btn_restart_demo.pressed.connect(func():
		GameManager.reset_game()
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	)
	
	btn_close_modal.pressed.connect(func():
		_close_demo_modal()
	)
	
	btn_interact.pressed.connect(func():
		_trigger_current_interaction()
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
	
	# Conexión de áreas de interacción
	$Usuaria/InteractArea.body_entered.connect(func(body): if body == player: _set_interactable("usuaria"))
	$Usuaria/InteractArea.body_exited.connect(func(body): if body == player and current_interactable == "usuaria": _clear_interactable())
	
	$Carlos/InteractArea.body_entered.connect(func(body): if body == player: _set_interactable("carlos"))
	$Carlos/InteractArea.body_exited.connect(func(body): if body == player and current_interactable == "carlos": _clear_interactable())
	
	$Mariana/InteractArea.body_entered.connect(func(body): if body == player: _set_interactable("mariana"))
	$Mariana/InteractArea.body_exited.connect(func(body): if body == player and current_interactable == "mariana": _clear_interactable())
	
	$DonRamiro/InteractArea.body_entered.connect(func(body): if body == player: _set_interactable("ramiro"))
	$DonRamiro/InteractArea.body_exited.connect(func(body): if body == player and current_interactable == "ramiro": _clear_interactable())
	
	$LicBrenda/InteractArea.body_entered.connect(func(body): if body == player: _set_interactable("brenda"))
	$LicBrenda/InteractArea.body_exited.connect(func(body): if body == player and current_interactable == "brenda": _clear_interactable())
	
	$PacoGodinez/InteractArea.body_entered.connect(func(body): if body == player: _set_interactable("paco"))
	$PacoGodinez/InteractArea.body_exited.connect(func(body): if body == player and current_interactable == "paco": _clear_interactable())
	
	$EnemyPrinter/PrinterInteract.body_entered.connect(func(body): if body == player: _set_interactable("printer"))
	$EnemyPrinter/PrinterInteract.body_exited.connect(func(body): if body == player and current_interactable == "printer": _clear_interactable())
	
	# Verificar estado de la partida
	if not GameManager.intro_cutscene_done:
		player.global_position = Vector2(140, 200)
		player.set_facing(Vector2.RIGHT)
		player.can_move = false
		
		roberto.global_position = Vector2(480, 200)
		roberto.visible = true
		current_state = State.ROBERTO_RUN_TO_PLAYER
		touch_controls.visible = false
		objective_label.text = obj_intro_text
	else:
		if GameManager.player_saved_position != Vector2.ZERO:
			player.global_position = GameManager.player_saved_position
		player.can_move = true
		touch_controls.visible = true
		
		if GameManager.dragon_boss_defeated:
			dragon_boss.visible = false
			roberto.visible = false
			btn_demo_modal.visible = true
			objective_label.text = "[!] ¡Victoria Total! Has derrotado a las Sombras del Pasado."
			enemy_printer.set_collision_layer_value(3, false)
			enemy_printer_sprite.modulate = Color(0.55, 0.55, 0.55, 1.0)
			enemy_printer_nametag.text = "[V] Neutralizada"
			enemy_printer_nametag.modulate = Color(0.3, 0.9, 0.6, 1.0)
		elif GameManager.printer_defeated:
			roberto.visible = false
			btn_demo_modal.visible = true
			objective_label.text = obj_victory_text
			
			enemy_printer.set_collision_layer_value(3, false)
			enemy_printer_sprite.modulate = Color(0.55, 0.55, 0.55, 1.0)
			enemy_printer_nametag.text = "[V] Neutralizada"
			enemy_printer_nametag.modulate = Color(0.3, 0.9, 0.6, 1.0)
			
			if not GameManager.victory_dialogue_shown:
				GameManager.victory_dialogue_shown = true
				_start_victory_dialogue()
			elif not GameManager.dragon_boss_cutscene_done:
				_start_dragon_incident()
		elif GameManager.office_cutscene_done:
			roberto.visible = false
			objective_label.text = obj_battle_text
		else:
			roberto.global_position = Vector2(700, 190)
			roberto_sprite.frame = 2 * 4 + 0
			objective_label.text = obj_follow_text
		current_state = State.FREE_EXPLORE

func _process(delta):
	anim_timer += delta
	
	if usuaria.visible:
		if GameManager.printer_defeated:
			usuaria_sprite.frame = 8 * 4 + 0
		else:
			var panic_col = int(anim_timer * 4.0) % 4
			usuaria_sprite.frame = 10 * 4 + panic_col
			
	var work_col = int(anim_timer * 2.0) % 4
	carlos_sprite.frame = 0 * 4 + work_col
	mariana_sprite.frame = 0 * 4 + work_col
	paco_godinez.get_node("Sprite2D").frame = 0 * 4 + work_col
	
	match current_state:
		State.ROBERTO_RUN_TO_PLAYER:
			var move_speed = roberto_run_in_speed
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 8.0) % 4
			roberto_sprite.frame = 2 * 4 + run_col
			
			if roberto.position.x <= 200.0:
				roberto.position.x = 200.0
				roberto_sprite.frame = 2 * 4 + 0
				current_state = State.IDLE
				_start_intro_dialog()
				
		State.ROBERTO_RUN_TO_OFFICE:
			var move_speed = roberto_run_office_speed
			roberto.position.x += move_speed * delta
			var run_col = int(anim_timer * 9.0) % 4
			roberto_sprite.frame = 6 * 4 + run_col
			
			if roberto.position.x >= 700.0:
				roberto.position.x = 700.0
				roberto_sprite.frame = 2 * 4 + 0
				current_state = State.FREE_EXPLORE
				
		State.ROBERTO_FLEE:
			var move_speed = roberto_flee_speed
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 10.0) % 4
			roberto_sprite.frame = 2 * 4 + run_col
			
			if roberto.position.x <= 500.0:
				roberto.visible = false
				current_state = State.FREE_EXPLORE
				
		State.ROBERTO_LEAD_TO_BOSS:
			var move_speed = 160.0
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 8.0) % 4
			roberto_sprite.frame = 1 * 4 + run_col # Caminando hacia la izquierda
			
			player.position.x = roberto.position.x + 42.0
			player.position.y = roberto.position.y
			player.set_facing(Vector2.LEFT)
			
			if roberto.position.x <= 510.0:
				roberto.position.x = 510.0
				roberto_sprite.frame = 1 * 4 + 0
				player.position.x = 545.0
				player.set_facing(Vector2.LEFT)
				current_state = State.IDLE
				_trigger_dragon_boss_confrontation()

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

func start_encounter_dialog(user_name: String, portrait_path: String, color: Color, problem_text: String, enemy_spec: Dictionary, enemy_id: String):
	player.can_move = false
	touch_controls.visible = false
	
	dialog_queue = [
		{
			"speaker": user_name,
			"portrait": portrait_path,
			"color": color,
			"text": problem_text
		},
		{
			"speaker": "ALERTA DE SISTEMAS",
			"portrait": enemy_spec.get("texture_path", "res://assets/bug_enemy.png"),
			"color": Color("#f87171"),
			"text": "¡El problema se materializa como un '%s'! ¡Iniciando combate de Soporte Técnico!" % enemy_spec.get("name", "Problema")
		}
	]
	
	on_dialog_closed_callback = func():
		GameManager.player_saved_position = player.global_position
		GameManager.current_enemy_id = enemy_id
		GameManager.current_enemy_data = enemy_spec
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
		
	_show_next_in_queue()

func _on_office_trigger_entered(body):
	if body == player and not GameManager.office_cutscene_done:
		GameManager.office_cutscene_done = true
		player.can_move = false
		player.set_facing(Vector2.RIGHT)
		touch_controls.visible = false
		
		dialog_queue = [
			{
				"speaker": "Roberto Huerta",
				"portrait": "res://assets/characters/roberto_huerta_portrait.png",
				"color": Color("#f1c40f"),
				"text": roberto_office
			},
			{
				"speaker": "Jefa de Finanzas",
				"portrait": "res://assets/characters/usuaria_portrait.png",
				"color": Color("#fd79a8"),
				"text": usuaria_office_1
			},
			{
				"speaker": "Jefa de Finanzas",
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

func _start_victory_dialogue():
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	player.can_move = false
	player.set_facing(Vector2.UP)
	
	dialog_queue = [
		{
			"speaker": "Jefa de Finanzas",
			"portrait": "res://assets/characters/usuaria_portrait.png",
			"color": Color("#fd79a8"),
			"text": victory_jefa_1 % hero_name
		},
		{
			"speaker": "Jefa de Finanzas",
			"portrait": "res://assets/characters/usuaria_portrait.png",
			"color": Color("#fd79a8"),
			"text": victory_jefa_2
		}
	]
	
	on_dialog_closed_callback = func():
		_start_dragon_incident()
	
	_show_next_in_queue()

func _start_dragon_incident():
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	
	roberto.global_position = player.global_position + Vector2(60, 0)
	roberto.visible = true
	roberto_sprite.frame = 1 * 4 + 0
	player.can_move = false
	touch_controls.visible = false
	
	dialog_queue = [
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": "¡%s! ¡Oye, allá afuera en el pasillo principal está un señor muy alterado preguntando por su dragón!" % hero_name
		},
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": "¡Dice que si no sale Sistemas ahora mismo habrá consecuencias catastróficas! ¡Ven, te llevo con él, sígueme!"
		}
	]
	
	on_dialog_closed_callback = func():
		current_state = State.ROBERTO_LEAD_TO_BOSS
		objective_label.text = "[!] Sigue a Roberto Huerta hacia el pasillo principal ->"
		
	_show_next_in_queue()

func _trigger_dragon_boss_confrontation():
	dragon_boss.global_position = Vector2(430, 180)
	dragon_boss.visible = true
	dragon_boss_sprite.frame = 2 * 4 + 0 # Mirando a la derecha
	
	dark_overlay.visible = true
	dark_overlay.modulate = Color(1, 1, 1, 0.0)
	var tw = create_tween()
	tw.tween_property(dark_overlay, "modulate:a", 0.75, 0.6)
	
	objective_label.text = "[!] SOMBRAS DEL PASADO: El Señor del Dragón"
	
	dialog_queue = [
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": "¡Ahí está! Es él... ¡las Sombras del Pasado han regresado a la oficina!"
		},
		{
			"speaker": "Sombras del Pasado",
			"portrait": "res://assets/characters/dragon_boss_portrait.png",
			"color": Color("#ef4444"),
			"text": "¡Quiero de vuelta mi dragón! Si no lo regresan, nunca volverán a ver el splitter, los discos duros y por supuesto... ¡el Magic Trackpad! ¡JAJAJAJAJA!"
		}
	]
	
	on_dialog_closed_callback = func():
		dark_overlay.visible = false
		GameManager.dragon_boss_cutscene_done = true
		GameManager.player_saved_position = player.global_position
		GameManager.current_enemy_id = "dragon_boss_main"
		GameManager.current_enemy_data = {
			"name": "El Señor del Dragón",
			"type": "dragon_boss",
			"desc": "Sombras del pasado... Exige de vuelta su dragón o retendrá el splitter, discos duros y el trackpad.",
			"hp": 650,
			"max_hp": 650,
			"atk": 25,
			"def": 14,
			"exp_reward": 350,
			"texture_path": "res://assets/enemies/enemy_dragon_boss.png",
			"attacks": [
				"Acoso",
				"La Cólera del Dragón",
				"Emputarse por nada"
			]
		}
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
		
	_show_next_in_queue()

func _open_demo_modal():
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	var hero_role = leader["role"]
	var hero_title = leader["title"]
	var hero_level = leader.get("level", 1)
	
	if GameManager.dragon_boss_defeated:
		demo_title.text = "¡VICTORIA LEGENDARIA!"
		demo_subtitle.text = "¡Felicidades %s! ¡Has derrotado al Señor del Dragón!" % hero_name
		demo_body.text = ("Has vencido a la Impresora Maldita y derrotado a las Sombras del Pasado.\n\n" +
			"¡El splitter, los discos duros y el Magic Trackpad han sido rescatados para Sistemas!\n\n" +
			"Héroe Legendario: %s [Nivel %d - %s]\n" +
			"Especialidad: %s\n\n" +
			"[!] ¡Has completado todas las misiones de la Demo de IT Adventures!") % [hero_name, hero_level, hero_role, hero_title]
	else:
		demo_subtitle.text = "¡Gracias %s, esto solo es un demo!" % hero_name
		demo_body.text = ("Has neutralizado con éxito a la Impresora Maldita y salvado la nómina de Finanzas.\n\n" +
			"Héroe de la Misión: %s [Nivel %d - %s]\n" +
			"Especialidad: %s\n\n" +
			"[!] Novedades del Sistema de TI:\n" +
			" - ¡Enemigos de soporte derrotados ganan EXP y subes de nivel!\n" +
			" - Nuevos problemas físicos en el piso (Outlook, Teclados, Wi-Fi, CPUs)\n" +
			" - Charla con Don Ramiro, Lic. Brenda y Paco Godínez") % [hero_name, hero_level, hero_role, hero_title]
		
	demo_modal.visible = true
	player.can_move = false

func _close_demo_modal():
	demo_modal.visible = false
	player.can_move = true

func _set_interactable(id: String):
	current_interactable = id
	btn_interact.visible = true
	interact_banner.visible = true
	match id:
		"usuaria":
			interact_label.text = "[E] Hablar con Jefa de Finanzas"
		"carlos":
			interact_label.text = "[E] Hablar con Carlos (Facturación)"
		"mariana":
			interact_label.text = "[E] Hablar con Mariana (Contabilidad)"
		"ramiro":
			interact_label.text = "[E] Hablar con Don Ramiro"
		"brenda":
			interact_label.text = "[E] Hablar con Lic. Brenda (RH)"
		"paco":
			interact_label.text = "[E] Hablar con Paco Godínez"
		"printer":
			interact_label.text = "[E] Inspeccionar Impresora"

func _clear_interactable():
	current_interactable = ""
	btn_interact.visible = false
	interact_banner.visible = false

func _trigger_current_interaction():
	if dialog_box.visible:
		_advance_dialog()
		return
		
	if current_interactable.is_empty():
		return
		
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	
	match current_interactable:
		"usuaria":
			dialog_queue = [
				{
					"speaker": "Jefa de Finanzas",
					"portrait": "res://assets/characters/usuaria_portrait.png",
					"color": Color("#fd79a8"),
					"text": (jefa_chat_post % hero_name) if GameManager.printer_defeated else usuaria_office_1
				}
			]
		"carlos":
			dialog_queue = [
				{
					"speaker": "Carlos (Facturación)",
					"portrait": "res://assets/characters/carlos_portrait.png",
					"color": Color("#60a5fa"),
					"text": (carlos_thanks % hero_name) if GameManager.printer_defeated else carlos_panic
				}
			]
		"mariana":
			dialog_queue = [
				{
					"speaker": "Mariana (Contabilidad)",
					"portrait": "res://assets/characters/mariana_portrait.png",
					"color": Color("#34d399"),
					"text": (mariana_thanks % hero_name) if GameManager.printer_defeated else mariana_panic
				}
			]
		"ramiro":
			var q = don_ramiro_quotes[randi() % don_ramiro_quotes.size()]
			dialog_queue = [
				{
					"speaker": "Don Ramiro (El Decano)",
					"portrait": "res://assets/characters/don_ramiro_portrait.png",
					"color": Color("#fbbf24"),
					"text": q
				}
			]
		"brenda":
			var q = lic_brenda_quotes[randi() % lic_brenda_quotes.size()]
			dialog_queue = [
				{
					"speaker": "Lic. Brenda (RH)",
					"portrait": "res://assets/characters/lic_brenda_portrait.png",
					"color": Color("#f472b6"),
					"text": q
				}
			]
		"paco":
			var q = paco_godinez_quotes[randi() % paco_godinez_quotes.size()]
			dialog_queue = [
				{
					"speaker": "Paco Godínez",
					"portrait": "res://assets/characters/carlos_portrait.png",
					"color": Color("#facc15"),
					"text": q
				}
			]
		"printer":
			dialog_queue = [
				{
					"speaker": "Impresora",
					"portrait": "res://assets/props/printer.png",
					"color": Color("#f87171"),
					"text": printer_neutralized_text if GameManager.printer_defeated else "¡La impresora está echando chispas y humo! ¡Peligro inminente!"
				}
			]
			
	on_dialog_closed_callback = func():
		player.can_move = true
		
	player.can_move = false
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
	if demo_modal.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_demo_modal()
			get_viewport().set_input_as_handled()
		return
		
	if dialog_box.visible:
		if event.is_action_pressed("ui_accept") 		or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E)) 		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) 		or (event is InputEventScreenTouch and event.pressed):
			get_viewport().set_input_as_handled()
			_advance_dialog()
	else:
		if not current_interactable.is_empty():
			if event.is_action_pressed("ui_accept") 			or (event is InputEventKey and event.pressed and (event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
				get_viewport().set_input_as_handled()
				_trigger_current_interaction()
