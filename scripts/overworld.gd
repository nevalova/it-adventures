extends Node2D

const SpriteLayout = preload("res://scripts/sprite_layout.gd")

# --- Variables Exportadas Editables desde el Inspector de Godot ---
@export_group("Diálogos - Roberto Huerta (Intro)")
@export_multiline var roberto_intro_1: String = "¡%s, qué bueno que te encuentro! ¡Necesito ayuda urgente en la oficina de Finanzas!"
@export_multiline var roberto_intro_2: String = "¡La impresora empezó a hacer ruidos raros, huele a quemado y tiene a la jefa al borde del colapso! ¡Reúne a tres compañeros y vamos juntos! Te esperaré aquí hasta que el equipo esté completo."

@export_group("Diálogos - Oficina de Finanzas")
@export_multiline var roberto_office: String = "¡Aquí está el desastre! Bueno... ¡yo ya cumplí con avisar, te dejo con el experto! ¡Suerte!"
@export_multiline var usuaria_office_1: String = "¡Ayuda, por favor! Mandé a imprimir la nómina quincenal y esta máquina del demonio se tragó todo el papel y empezó a disparar tóner hirviendo..."
@export_multiline var usuaria_office_2: String = "¡Si no la neutralizas ahora mismo nos quedamos sin quincena y se incendia el departamento!"

@export_group("Diálogos - Victoria y Fin de Demo")
@export_multiline var victory_jefa_1: String = "¡Muchísimas gracias, %s! ¡Salvaste la nómina quincenal y a todo el departamento de Finanzas!"
@export_multiline var victory_jefa_2: String = "Esa máquina endemoniada casi destruye todos los balances y el servidor. ¡Eres un héroe de Sistemas!"
@export_multiline var victory_demo_text: String = "¡GRACIAS POR JUGAR, %s! ESTO SOLO ES UN DEMO.\nHas completado con éxito la primera misión de IT Adventures."
@export_multiline var jefa_chat_post: String = "¡Gracias de nuevo, %s! Por fin podemos trabajar en paz en nuestros escritorios. ¡Te ganaste café gratis de por vida en Finanzas!"

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

# Boss Sombras del Pasado
@onready var dragon_boss = $DragonBoss
@onready var dragon_boss_sprite = $DragonBoss/Sprite2D
@onready var dark_overlay = $CanvasLayer/DarkOverlay
@onready var episode_card = $CanvasLayer/DarkOverlay/EpisodeCard

# Servidor Principal / Contraseña Olvidada
@onready var server_boss = $ServerBoss
@onready var server_boss_sprite = $ServerBoss/Sprite2D
@onready var server_boss_nametag = $ServerBoss/NameTag

# Director de Redes (Censurado)
@onready var director_censurado = $DirectorCensurado
@onready var director_sprite = $DirectorCensurado/Sprite2D

@onready var office_trigger = $OfficeTrigger
@onready var enemy_printer = $EnemyPrinter
@onready var enemy_printer_sprite = $EnemyPrinter/Sprite2D
@onready var enemy_printer_nametag = $EnemyPrinter/NameTag

# HUD & Controls
@onready var hud_hero_name = $CanvasLayer/HUD/HeroInfo/HeroName
@onready var hud_hero_role = $CanvasLayer/HUD/HeroInfo/HeroRole
@onready var hud_stats = $CanvasLayer/HUD/HeroInfo/HeroStats
@onready var btn_switch = $CanvasLayer/HUD/TouchControls/RightBox/SwitchBtn
@onready var btn_squad = $CanvasLayer/HUD/TouchControls/RightBox/BtnSquad
@onready var btn_demo_modal = $CanvasLayer/HUD/TouchControls/RightBox/BtnDemoModal
@onready var btn_interact = $CanvasLayer/HUD/TouchControls/RightBox/BtnInteract
@onready var touch_controls = $CanvasLayer/HUD/TouchControls
@onready var objective_label = $CanvasLayer/HUD/ObjectiveBanner/Label
@onready var interact_banner = $CanvasLayer/HUD/InteractBanner
@onready var interact_label = $CanvasLayer/HUD/InteractBanner/Label

# Companions & Gestor de Escuadrón IT
@onready var companions_root = $Companions
@onready var squad_modal = $CanvasLayer/SquadModal
@onready var squad_slot_count_label = $CanvasLayer/SquadModal/Margin/VBox/HeaderHBox/SlotCountLabel
@onready var squad_heroes_list = $CanvasLayer/SquadModal/Margin/VBox/Scroll/HeroesList
@onready var btn_close_squad = $CanvasLayer/SquadModal/Margin/VBox/BtnCloseSquad

# D-Pad táctil
@onready var dpad_box = $CanvasLayer/HUD/TouchControls/DpadBox
@onready var joystick_box = $CanvasLayer/HUD/TouchControls/JoystickBox
@onready var btn_control_mode = $CanvasLayer/HUD/TouchControls/RightBox/BtnControlMode
@onready var click_marker = $ClickMarker
@onready var modal_control_options = $CanvasLayer/ControlOptionsModal
@onready var btn_mode_dpad = $CanvasLayer/ControlOptionsModal/Margin/VBox/CardsBox/BtnModeDpad
@onready var btn_mode_joystick = $CanvasLayer/ControlOptionsModal/Margin/VBox/CardsBox/BtnModeJoystick
@onready var btn_mode_point_click = $CanvasLayer/ControlOptionsModal/Margin/VBox/CardsBox/BtnModePointClick
@onready var btn_close_control_options = $CanvasLayer/ControlOptionsModal/Margin/VBox/BtnCloseOptions
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

# HUD Budget & Nelly's Shop
@onready var hud_hero_budget = $CanvasLayer/HUD/HeroInfo/HeroBudget
@onready var shop_modal = $CanvasLayer/ShopModal
@onready var shop_budget_label = $CanvasLayer/ShopModal/Margin/VBox/HeaderHBox/BudgetLabel
@onready var shop_items_list = $CanvasLayer/ShopModal/Margin/VBox/ItemsScroll/ItemsList
@onready var shop_feedback_label = $CanvasLayer/ShopModal/Margin/VBox/FeedbackLabel
@onready var btn_close_shop = $CanvasLayer/ShopModal/Margin/VBox/BtnCloseShop

# Photo Modal & Server Login Modal
@onready var photo_modal = $CanvasLayer/PhotoModal
@onready var btn_close_photo = $CanvasLayer/PhotoModal/Margin/VBox/BtnClosePhoto
@onready var server_login_modal = $CanvasLayer/ServerLoginModal
@onready var pass_input = $CanvasLayer/ServerLoginModal/Margin/VBox/PassRow/PassInput
@onready var hint_label = $CanvasLayer/ServerLoginModal/Margin/VBox/HintLabel
@onready var btn_submit_pass = $CanvasLayer/ServerLoginModal/Margin/VBox/BtnHBox/BtnSubmitPass
@onready var btn_cancel_pass = $CanvasLayer/ServerLoginModal/Margin/VBox/BtnHBox/BtnCancelPass

# State Machine
enum State {
	IDLE,
	ROBERTO_RUN_TO_PLAYER,
	ROBERTO_RUN_TO_OFFICE,
	ROBERTO_FLEE,
	FREE_EXPLORE,
	ROBERTO_LEAD_TO_BOSS,
	ROBERTO_RUN_TO_TELL_ABOUT_BOSS,
	DRAGON_BOSS_FLEE_TO_BACK
}

var current_state: State = State.IDLE
var anim_timer: float = 0.0
var dialog_queue: Array = []
var on_dialog_closed_callback: Callable
var on_photo_closed_callback: Callable
var current_interactable: String = ""

# Sistema de Compañeros de Escuadrón
var companion_nodes: Dictionary = {}
var site_exit_barrier: StaticBody2D
var safety_advisor: Node2D
var exit_warning_open: bool = false
var senor_apoyo_node: Node2D = null

# Sistema de Misiones, Oficina Brujiris y Menú Debug/Guardado
var supply_box_node: Node2D = null
var door_brujiris_node: Node2D = null
var brujiris_office_root: Node2D = null
var brujiris_npc_node: Node2D = null
var debug_modal: PanelContainer = null
var btn_save_hud: Button = null
var btn_debug_hud: Button = null
var save_toast_label: Label = null

func _ready():
	GameManager.preload_scene("res://scenes/battle.tscn")
	GameManager.preload_scene("res://scenes/character_select.tscn")
	$Player/Camera2D.make_current()
	if GameManager.inside_brujiris_office:
		$Player/Camera2D.limit_left = 3200
		$Player/Camera2D.limit_right = 3840
	else:
		$Player/Camera2D.limit_left = 0
		$Player/Camera2D.limit_right = 3072
	$Player/Camera2D.limit_top = 0
	$Player/Camera2D.limit_bottom = 360
	
	_update_hud_stats()
	btn_close_shop.pressed.connect(_close_shop_modal)
	btn_close_photo.pressed.connect(_close_photo_modal)
	btn_cancel_pass.pressed.connect(_close_server_login_modal)
	btn_submit_pass.pressed.connect(_on_submit_password)
	pass_input.text_submitted.connect(func(_t): _on_submit_password())
	
	btn_squad.pressed.connect(_open_squad_modal)
	btn_close_squad.pressed.connect(_close_squad_modal)
	
	# Y-Sort dinámico para que todos los muebles y personajes se ordenen exactamente por profundidad
	if has_node("OfficeFurniture"):
		for desk in $OfficeFurniture.get_children():
			desk.reparent(self)
			_anchor_furniture(desk)
	if has_node("EnvironmentProps"):
		for prop in $EnvironmentProps.get_children():
			prop.reparent(self)
			_anchor_furniture(prop)
			
	_setup_companions()
	_setup_team_exit()
	_setup_senor_apoyo()
	_setup_paper_quest()
	_setup_brujiris_office()
	_setup_debug_and_save_ui()
	_prepare_world_visuals(self)
	
	btn_switch.visible = false
	btn_switch.pressed.connect(func():
		GameManager.change_scene_instant(get_tree(), "res://scenes/character_select.tscn")
	)
	
	btn_demo_modal.pressed.connect(func():
		_open_demo_modal()
	)
	
	btn_restart_demo.pressed.connect(func():
		GameManager.reset_game()
		GameManager.change_scene_instant(get_tree(), "res://scenes/character_select.tscn")
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
	
	# Conexión del Joystick Virtual
	joystick_box.joystick_moved.connect(func(v):
		if player:
			player.joystick_vector = v
	)
	joystick_box.joystick_released.connect(func():
		if player:
			player.joystick_vector = Vector2.ZERO
	)
	
	# Conexión del selector de controles
	btn_control_mode.pressed.connect(_open_control_options)
	btn_close_control_options.pressed.connect(_close_control_options)
	btn_mode_dpad.pressed.connect(func(): _select_overworld_control_mode("dpad"))
	btn_mode_joystick.pressed.connect(func(): _select_overworld_control_mode("joystick"))
	btn_mode_point_click.pressed.connect(func(): _select_overworld_control_mode("point_and_click"))
	_update_touch_controls_mode()
	
	# Conexión del botón de diálogo
	dialog_btn.pressed.connect(_advance_dialog)
	
	# Conexión del trigger de la oficina
	office_trigger.body_entered.connect(_on_office_trigger_entered)
	
	# Conexión de áreas de interacción
	if has_node("Nelly/InteractArea"):
		$Nelly/InteractArea.body_entered.connect(func(body):
			if body == player:
				_set_interactable("nelly")
		)
		$Nelly/InteractArea.body_exited.connect(func(body):
			if body == player and current_interactable == "nelly":
				_clear_interactable()
		)
	
	$Usuaria/InteractArea.body_entered.connect(func(body): if body == player: _set_interactable("usuaria"))
	$Usuaria/InteractArea.body_exited.connect(func(body): if body == player and current_interactable == "usuaria": _clear_interactable())
	
	$EnemyPrinter/PrinterInteract.body_entered.connect(func(body):
		if body == player:
			_set_interactable("printer")
	)
	$EnemyPrinter/PrinterInteract.body_exited.connect(func(body): if body == player and current_interactable == "printer": _clear_interactable())
	
	$DragonBoss/InteractArea.body_entered.connect(func(body):
		if body == player:
			if GameManager.dragon_boss_fled and not GameManager.dragon_boss_defeated:
				_set_interactable("dragon_boss")
			elif GameManager.dragon_boss_defeated:
				_set_interactable("dragon_boss_kneeling")
	)
	$DragonBoss/InteractArea.body_exited.connect(func(body):
		if body == player and (current_interactable == "dragon_boss" or current_interactable == "dragon_boss_kneeling"):
			_clear_interactable()
	)
	
	if has_node("ServerBoss/InteractArea"):
		$ServerBoss/InteractArea.body_entered.connect(func(body):
			if body == player:
				_set_interactable("server_boss")
		)
		$ServerBoss/InteractArea.body_exited.connect(func(body):
			if body == player and current_interactable == "server_boss":
				_clear_interactable()
		)
	
	if has_node("DirectorCensurado/InteractArea"):
		$DirectorCensurado/InteractArea.body_entered.connect(func(body):
			if body == player:
				_set_interactable("director")
		)
		$DirectorCensurado/InteractArea.body_exited.connect(func(body):
			if body == player and current_interactable == "director":
				_clear_interactable()
		)
	
	if $RobertoHuerta.has_node("InteractArea"):
		$RobertoHuerta/InteractArea.body_entered.connect(func(body):
			if body == player and (GameManager.dragon_boss_defeated or (GameManager.intro_cutscene_done and not GameManager.office_cutscene_done)):
				_set_interactable("roberto")
		)
		$RobertoHuerta/InteractArea.body_exited.connect(func(body):
			if body == player and current_interactable == "roberto":
				_clear_interactable()
		)
	
	director_censurado.visible = false
	
	# The repeatable Israel gag must never replay a main-story/final-boss scene.
	if GameManager.just_defeated_senor_apoyo:
		player.global_position = GameManager.player_saved_position
		player.can_move = false
		current_state = State.FREE_EXPLORE
		roberto.visible = false
		if GameManager.dragon_boss_fled and not GameManager.dragon_boss_defeated:
			dragon_boss.visible = true
			dragon_boss.position = Vector2(1880, 180)
		_update_objective_label_for_current_state()
	elif not GameManager.intro_cutscene_done:
		player.global_position = Vector2(140, 200)
		player.set_facing(Vector2.RIGHT)
		player.can_move = false
		
		roberto.global_position = Vector2(480, 200)
		roberto.visible = true
		current_state = State.ROBERTO_RUN_TO_PLAYER
		touch_controls.visible = false
		objective_label.text = obj_intro_text
	else:
		if GameManager.inside_brujiris_office:
			if GameManager.player_saved_position != Vector2.ZERO:
				player.global_position = GameManager.player_saved_position
			else:
				player.global_position = Vector2(3260, 200)
			objective_label.text = "[!] Oficina de Auditoría - Habla con Brujiris"
		else:
			if GameManager.player_saved_position != Vector2.ZERO:
				player.global_position = GameManager.player_saved_position
		player.can_move = true
		touch_controls.visible = true
		
		if GameManager.dragon_boss_defeated:
			enemy_printer.set_collision_layer_value(3, false)
			enemy_printer_sprite.position = Vector2(0, -19)
			enemy_printer_sprite.modulate = Color(0.55, 0.55, 0.55, 1.0)
			enemy_printer_nametag.text = "[V] Neutralizada"
			enemy_printer_nametag.modulate = Color(0.3, 0.9, 0.6, 1.0)
			
			if not GameManager.dragon_flee_cutscene_done:
				# Mostrar su sprite chibi huyendo hacia la derecha y luego desaparece
				dragon_boss.visible = true
				dragon_boss.position = Vector2(1880, 180)
				dragon_boss_sprite.texture = load("res://assets/characters/dragon_boss_spritesheet.png")
				dragon_boss_sprite.hframes = 4
				dragon_boss_sprite.vframes = 12
				dragon_boss_sprite.frame = 6 * 4 + 0 # Mirando / corriendo hacia la derecha
				SpriteLayout.configure(dragon_boss_sprite, $DragonBoss/NameTag, 42.0)
				if dragon_boss.has_node("NameTag"):
					$DragonBoss/NameTag.text = "¡Huyendo!"
					$DragonBoss/NameTag.modulate = Color(1.0, 0.4, 0.3)
				
				# Personaje Legalmente Seguro aparece para dar el diálogo
				director_censurado.visible = true
				director_censurado.position = Vector2(1780, 180)
				director_sprite.frame = 2 * 4 + 0
				if director_censurado.has_node("NameTag"):
					$DirectorCensurado/NameTag.text = "[!] Personaje Legalmente Seguro"
				
				player.global_position = Vector2(1820, 180)
				player.set_facing(Vector2.RIGHT)
				player.can_move = false
				touch_controls.visible = false
				
				_start_dragon_boss_flee_sequence()
			else:
				# Ya huyó: desaparece permanentemente del overworld
				dragon_boss.visible = false
				
				if GameManager.server_boss_defeated:
					director_censurado.visible = false
					roberto.visible = true
					roberto.position = Vector2(1820, 180)
					roberto_sprite.frame = 6 * 4 + 0
					btn_demo_modal.visible = true
					objective_label.text = "[!] ¡Victoria Total! Servidores 100, 245, 189, 122 y 117 conectados. ¡Habla con Roberto!"
					if has_node("ServerBoss"):
						server_boss.visible = true
						server_boss_sprite.modulate = Color(0.4, 0.9, 0.5)
						server_boss_nametag.text = "[V] Servidor 117 (Desbloqueado)"
						server_boss_nametag.modulate = Color(0.3, 0.9, 0.5)
				elif not GameManager.director_cutscene_done:
					director_censurado.visible = true
					director_censurado.position = Vector2(1780, 180)
					director_sprite.frame = 2 * 4 + 0
					_start_director_incident_dialogue()
				else:
					# Personaje Legalmente Seguro ya se fue
					director_censurado.visible = false
					roberto.visible = false
					objective_label.text = "[!] ¡Ve a la Sala de Servidores al este y resuelve el Servidor 117!"
		elif GameManager.printer_defeated:
			roberto.visible = false
			btn_demo_modal.visible = true
			objective_label.text = obj_victory_text
			
			enemy_printer.set_collision_layer_value(3, false)
			enemy_printer_sprite.position = Vector2(0, -19)
			enemy_printer_sprite.modulate = Color(0.55, 0.55, 0.55, 1.0)
			enemy_printer_nametag.text = "[V] Neutralizada"
			enemy_printer_nametag.modulate = Color(0.3, 0.9, 0.6, 1.0)
			
			if not GameManager.victory_dialogue_shown:
				GameManager.victory_dialogue_shown = true
				_start_victory_dialogue()
			elif not GameManager.dragon_boss_cutscene_done:
				_start_dragon_incident()
			elif GameManager.dragon_boss_fled:
				dragon_boss.visible = true
				dragon_boss.position = Vector2(1880, 180)
				dragon_boss_sprite.frame = 2 * 4 + 0 # Mirando a la izquierda esperando al jugador
				objective_label.text = "[!] ¡Avanza por la nueva oficina y enfrenta a El Señor del Dragón al fondo!"
		elif GameManager.office_cutscene_done:
			roberto.visible = false
			objective_label.text = obj_battle_text
		else:
			roberto.global_position = Vector2(500 if GameManager.party.size() < 4 else 700, 190)
			roberto_sprite.frame = 2 * 4 + 0
			objective_label.text = obj_follow_text
		current_state = State.FREE_EXPLORE
		
	if not GameManager.dragon_boss_defeated:
		director_censurado.visible = true
		director_censurado.position = Vector2(750, 155)
		$DirectorCensurado/NameTag.text = "Personaje Legalmente Seguro"

	if GameManager.just_defeated_senor_apoyo:
		GameManager.just_defeated_senor_apoyo = false
		_start_post_senor_apoyo_dialogue()
	_mount_office_printer()

func _setup_team_exit() -> void:
	site_exit_barrier = StaticBody2D.new()
	site_exit_barrier.name = "TeamExitBarrier"
	site_exit_barrier.position = Vector2(580, 180)
	site_exit_barrier.collision_layer = 2
	var shape = RectangleShape2D.new()
	shape.size = Vector2(16, 114)
	var collider = CollisionShape2D.new()
	collider.shape = shape
	site_exit_barrier.add_child(collider)
	add_child(site_exit_barrier)
	# A separate instance avoids interfering with the director's later story.
	safety_advisor = director_censurado.duplicate(0) as Node2D
	safety_advisor.name = "SiteSafetyAdvisor"
	safety_advisor.position = Vector2(542, 165)
	safety_advisor.visible = false
	safety_advisor.get_node("NameTag").text = "Personaje Legalmente Seguro"
	var interaction = safety_advisor.get_node_or_null("InteractArea")
	if interaction:
		interaction.free()
	add_child(safety_advisor)

func _refresh_team_departure() -> void:
	var complete = GameManager.party.size() == 4
	# Let an existing save outside return to the site; only outbound travel is gated.
	site_exit_barrier.collision_layer = 2 if not complete and player.position.x < 580.0 else 0
	if not exit_warning_open:
		safety_advisor.visible = false
	if not GameManager.intro_cutscene_done or GameManager.office_cutscene_done:
		return
	if not complete:
		if current_state == State.ROBERTO_RUN_TO_OFFICE:
			current_state = State.FREE_EXPLORE
			roberto.position.x = minf(roberto.position.x, 510.0)
			roberto_sprite.frame = 8
		if player.can_move and not dialog_box.visible:
			objective_label.text = "[!] Recluta tres compañeros en sus escritorios. Equipo: %d/4" % GameManager.party.size()
	else:
		if player.can_move and not dialog_box.visible and not squad_modal.visible and current_state in [State.IDLE, State.FREE_EXPLORE]:
			if roberto.position.x < 700.0:
				current_state = State.ROBERTO_RUN_TO_OFFICE
			objective_label.text = obj_follow_text

func _physics_process(_delta: float) -> void:
	if GameManager.party.size() < 4 and player.can_move and GameManager.intro_cutscene_done and not dialog_box.visible:
		if player.position.x > 530.0 and player.position.x < 580.0:
			_warn_about_solo_it()

func _warn_about_solo_it() -> void:
	if exit_warning_open or dialog_box.visible:
		return
	exit_warning_open = true
	player.cancel_navigation()
	player.velocity = Vector2.ZERO
	player.can_move = false
	player.position.x = minf(player.position.x, 525.0)
	safety_advisor.visible = true
	safety_advisor.get_node("Sprite2D").frame = 8
	dialog_queue = [{
		"speaker": "Personaje Legalmente Seguro",
		"portrait": "res://assets/characters/director_censurado_portrait.png",
		"color": Color("#fdcb6e"),
		"text": "¡Hey! Es muy peligroso arreglar problemas de IT solo, ¡te comerán vivo! Lleva a tu equipo: lleva tres más contigo. Necesitas un equipo de cuatro para salir. (%d/4)" % GameManager.party.size()
	}]
	on_dialog_closed_callback = func():
		exit_warning_open = false
		safety_advisor.visible = false
		player.can_move = true
		_refresh_team_departure()
	_show_next_in_queue()

func _mount_office_printer() -> void:
	# Table and printer sort together; printer art is drawn AFTER the tabletop.
	var table = get_node("PrinterTable") as Node2D
	enemy_printer.reparent(table, true)
	enemy_printer.y_sort_enabled = false
	enemy_printer_sprite.position.y = -19.0
	enemy_printer_nametag.position.y = -59.0
	table.move_child(enemy_printer, table.get_child_count() - 1)

func _anchor_furniture(prop: Node2D) -> void:
	# Sort at the bottom of the furniture while preserving art and collision.
	prop.y_sort_enabled = false
	var visual = prop as Sprite2D
	if visual == null:
		visual = prop.get_node_or_null("Sprite") as Sprite2D
	if visual == null or visual.texture == null:
		return
	var image = visual.texture.get_image()
	var bounds = image.get_used_rect()
	var bottom = float(bounds.end.y) - image.get_height() * 0.5
	if prop == visual:
		prop.position.y += bottom * visual.scale.y
		visual.offset.y -= bottom
	else:
		var ground = visual.position.y + bottom * visual.scale.y
		prop.position.y += ground
		for part in prop.get_children():
			if part is Node2D:
				part.position.y -= ground

func can_ambient_npcs_walk() -> bool:
	return is_instance_valid(player) and player.can_move and current_state in [State.IDLE, State.FREE_EXPLORE]

func _prepare_world_visuals(root: Node) -> void:
	for child in root.get_children():
		if child is CanvasLayer:
			continue
		# Actors are single sorting units: sprite, name and effects stay together.
		if child is Node2D and child.has_node("Sprite2D"):
			var actor_sprite = child.get_node("Sprite2D") as Sprite2D
			if actor_sprite != null and actor_sprite.hframes == 4 and actor_sprite.vframes == 12:
				child.y_sort_enabled = false
				SpriteLayout.configure(actor_sprite, child.get_node_or_null("NameTag"), 42.0 if child == dragon_boss else 38.0)
		_prepare_world_visuals(child)

func _process(delta):
	anim_timer += delta
	
	_refresh_team_departure()
	_refresh_paper_quest_giver()

	_update_stationed_companions()
	
	if touch_controls.visible:
		dpad_box.visible = (GameManager.control_type == "dpad")
		joystick_box.visible = (GameManager.control_type == "joystick")
	else:
		dpad_box.visible = false
		joystick_box.visible = false
	
	if usuaria.visible:
		if GameManager.printer_defeated:
			usuaria_sprite.frame = 8 * 4 + 0
		else:
			var panic_col = int(anim_timer * 4.0) % 4
			usuaria_sprite.frame = 10 * 4 + panic_col
			
	match current_state:
		State.ROBERTO_RUN_TO_PLAYER:
			var move_speed = roberto_run_in_speed
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 8.0) % 4
			roberto_sprite.frame = 2 * 4 + run_col # Caminando hacia la izquierda
			
			if roberto.position.x <= 200.0:
				roberto.position.x = 200.0
				roberto_sprite.frame = 2 * 4 + 0 # Mirando a la izquierda hacia el jugador
				current_state = State.IDLE
				_start_intro_dialog()
				
		State.ROBERTO_RUN_TO_OFFICE:
			var move_speed = roberto_run_office_speed
			roberto.position.x += move_speed * delta
			var run_col = int(anim_timer * 9.0) % 4
			roberto_sprite.frame = 6 * 4 + run_col # Caminando hacia la derecha
			
			if roberto.position.x >= 700.0:
				roberto.position.x = 700.0
				roberto_sprite.frame = 2 * 4 + 0 # Mirando hacia la izquierda esperando al jugador
				current_state = State.FREE_EXPLORE
				
		State.ROBERTO_FLEE:
			var move_speed = roberto_flee_speed
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 10.0) % 4
			roberto_sprite.frame = 2 * 4 + run_col # Huyendo hacia la izquierda
			
			if roberto.position.x <= 500.0:
				roberto.visible = false
				current_state = State.FREE_EXPLORE
				
		State.ROBERTO_LEAD_TO_BOSS:
			var move_speed = 150.0
			roberto.position.x -= move_speed * delta
			var run_col = int(anim_timer * 8.0) % 4
			roberto_sprite.frame = 2 * 4 + run_col # Roberto caminando hacia la izquierda
			
			player.position.x = roberto.position.x + 42.0
			player.position.y = roberto.position.y
			player.play_walk_anim(Vector2.LEFT, run_col) # El jugador anima su caminata al compás
			
			if roberto.position.x <= 510.0:
				roberto.position.x = 510.0
				roberto_sprite.frame = 2 * 4 + 0 # Parado mirando a la izquierda
				player.position.x = 545.0
				player.set_facing(Vector2.LEFT) # Detiene caminata y queda mirando a la izquierda
				current_state = State.IDLE
				_trigger_dragon_boss_confrontation()
				
		State.ROBERTO_RUN_TO_TELL_ABOUT_BOSS:
			var move_speed = roberto_run_in_speed
			roberto.position.x += move_speed * delta
			var run_col = int(anim_timer * 8.0) % 4
			roberto_sprite.frame = 6 * 4 + run_col # Corriendo hacia la derecha hacia el jugador
			
			if roberto.position.x >= player.position.x - 50.0:
				roberto.position.x = player.position.x - 50.0
				roberto_sprite.frame = 6 * 4 + 0 # Parado mirando a la derecha al jugador
				player.set_facing(Vector2.LEFT)
				current_state = State.IDLE
				_show_roberto_dragon_dialog()
				
		State.DRAGON_BOSS_FLEE_TO_BACK:
			var move_speed = 400.0
			dragon_boss.position.x += move_speed * delta
			var run_col = int(anim_timer * 9.0) % 4
			dragon_boss_sprite.frame = 6 * 4 + run_col # Corriendo hacia la derecha al fondo
			
			if dragon_boss.position.x >= 1880.0:
				dragon_boss.position.x = 1880.0
				dragon_boss_sprite.frame = 2 * 4 + 0 # Mirando a la izquierda
				current_state = State.IDLE
				_show_roberto_boss_fled_dialog()

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
		current_state = State.FREE_EXPLORE
		player.can_move = true
		touch_controls.visible = true
		_refresh_team_departure()
	
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
		}
	]
	
	on_dialog_closed_callback = func():
		GameManager.player_saved_position = player.global_position
		GameManager.current_enemy_id = enemy_id
		GameManager.current_enemy_data = enemy_spec
		GameManager.change_scene_instant(get_tree(), "res://scenes/battle.tscn")
		
	_show_next_in_queue()

func show_solved_dialog(user_name: String, portrait_path: String, color: Color, thank_text: String):
	player.can_move = false
	touch_controls.visible = false
	
	dialog_queue = [
		{
			"speaker": user_name,
			"portrait": portrait_path,
			"color": color,
			"text": thank_text
		}
	]
	
	on_dialog_closed_callback = func():
		player.can_move = true
		touch_controls.visible = true
		
	_show_next_in_queue()

func _on_office_trigger_entered(body):
	if body == player and GameManager.party.size() < 4:
		player.global_position = Vector2(525, clampf(player.global_position.y, 145, 215))
		_warn_about_solo_it()
		return
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
	player.can_move = false
	touch_controls.visible = false
	# Roberto llega caminando desde la entrada de la oficina hacia el jugador
	roberto.position = Vector2(650, player.position.y)
	roberto.visible = true
	roberto_sprite.frame = 6 * 4 + 0 # Mirando a la derecha hacia el jugador
	current_state = State.ROBERTO_RUN_TO_TELL_ABOUT_BOSS

func _show_roberto_dragon_dialog():
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	
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
	dragon_boss_sprite.frame = 6 * 4 + 0 # Mirando a la derecha hacia Roberto y el jugador
	
	dark_overlay.visible = true
	dark_overlay.color = Color(0, 0, 0, 0.65)
	dark_overlay.modulate = Color(1, 1, 1, 0.0)
	episode_card.visible = false
	var tw = create_tween()
	tw.tween_property(dark_overlay, "modulate:a", 1.0, 0.6)
	
	objective_label.text = "[!] Pasillo Principal: Presencia Inesperada"
	
	dialog_queue = [
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": "¡Ahí está! Es él... ¡El Señor del Dragón ha venido a la oficina!"
		},
		{
			"speaker": "El Señor del Dragón",
			"portrait": "res://assets/characters/dragon_boss_portrait.png",
			"color": Color("#ef4444"),
			"text": "¡Quiero de vuelta mi dragón! Si no lo regresan, nunca volverán a ver el splitter, los discos duros y por supuesto... ¡el Magic Trackpad! ¡JAJAJAJAJA!"
		}
	]
	
	on_dialog_closed_callback = func():
		_start_episode_title_sequence()
		
	_show_next_in_queue()

func _start_episode_title_sequence():
	player.can_move = false
	touch_controls.visible = false
	dark_overlay.visible = true
	dark_overlay.color = Color(0, 0, 0, 1.0)
	dark_overlay.modulate = Color(1, 1, 1, 1.0)
	episode_card.visible = true
	episode_card.modulate = Color(1, 1, 1, 0.0)
	
	var tw = create_tween()
	tw.tween_property(episode_card, "modulate:a", 1.0, 0.8)
	tw.tween_interval(1.8)
	tw.tween_property(episode_card, "modulate:a", 0.0, 0.5)
	tw.tween_property(dark_overlay, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func():
		episode_card.visible = false
		dark_overlay.visible = false
		_start_boss_escape_sequence()
	)

func _start_boss_escape_sequence():
	dialog_queue = [
		{
			"speaker": "El Señor del Dragón",
			"portrait": "res://assets/characters/dragon_boss_portrait.png",
			"color": Color("#ef4444"),
			"text": "¡Si tienen el valor de intentar recuperarlos, vengan a buscarme al fondo de la oficina, detrás de la impresora! ¡JAJAJAJAJA!"
		}
	]
	
	on_dialog_closed_callback = func():
		current_state = State.DRAGON_BOSS_FLEE_TO_BACK
		
	_show_next_in_queue()

func _show_roberto_boss_fled_dialog():
	GameManager.dragon_boss_cutscene_done = true
	GameManager.dragon_boss_fled = true
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	
	dialog_queue = [
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": "¡El Señor del Dragón escapó al fondo de la nueva área de oficinas, detrás de la impresora! ¡Debemos detenerlo y recuperar el equipo!"
		},
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": "¡Avanza por los pasillos, %s! Pero mantente alerta: varios compañeros de las áreas tienen problemas técnicos graves y van a pedir tu apoyo en el camino." % hero_name
		}
	]
	
	on_dialog_closed_callback = func():
		player.can_move = true
		touch_controls.visible = true
		current_state = State.FREE_EXPLORE
		objective_label.text = "[!] ¡Avanza por la nueva oficina y enfrenta a El Señor del Dragón al fondo!"
		
	_show_next_in_queue()

func _start_dragon_boss_battle():
	GameManager.player_saved_position = player.global_position
	GameManager.current_enemy_id = "dragon_boss_main"
	GameManager.current_enemy_data = {
		"name": "El Señor del Dragón",
		"type": "dragon_boss",
		"desc": "El Señor del Dragón... Exige de vuelta a su dragón o retendrá el splitter, discos duros y el trackpad.",
		"hp": 280,
		"max_hp": 280,
		"atk": 14,
		"def": 6,
		"exp_reward": 400,
		"spritesheet_path": "res://assets/characters/dragon_boss_battle_spritesheet.png",
		"texture_path": "res://assets/characters/dragon_boss_battle_spritesheet.png",
		"attacks": [
			"Acoso",
			"La Cólera del Dragón",
			"Emputarse por nada",
			"DONDE ESTA MI DRAGON IMPRESO EN 3D"
		]
	}
	GameManager.change_scene_instant(get_tree(), "res://scenes/battle.tscn")

func _setup_senor_apoyo():
	if senor_apoyo_node != null:
		senor_apoyo_node.queue_free()
		senor_apoyo_node = null
		
	# Solo aparece si el personaje seleccionado es Israel
	if GameManager.selected_hero_id != "israel":
		return
		
	senor_apoyo_node = Node2D.new()
	senor_apoyo_node.name = "SenorApoyo"
	senor_apoyo_node.y_sort_enabled = true
	senor_apoyo_node.position = Vector2(1185, 240)
	
	var spr = Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sheet_path = GameManager.get_apoyo_spritesheet_path(GameManager.just_defeated_senor_apoyo and not GameManager.current_enemy_data.get("is_skeleton", false))
	if ResourceLoader.exists(sheet_path):
		spr.texture = load(sheet_path)
	spr.hframes = 4
	spr.vframes = 12
	spr.frame = 0 # Mirando al frente
	spr.scale = Vector2(0.24, 0.24)
	spr.position = Vector2(0, -10)
	senor_apoyo_node.add_child(spr)
	
	var tag = Label.new()
	tag.name = "NameTag"
	tag.offset_left = -60.0
	tag.offset_top = -32.0
	tag.offset_right = 60.0
	tag.offset_bottom = -16.0
	tag.add_theme_font_size_override("font_size", 8)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.text = "[!] ¿Me apoyas?"
	tag.modulate = Color(1.0, 0.65, 0.25)
	senor_apoyo_node.add_child(tag)
	
	var area = Area2D.new()
	area.name = "InteractArea"
	area.collision_layer = 4
	area.collision_mask = 1
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 28.0
	col.shape = circle
	area.add_child(col)
	senor_apoyo_node.add_child(area)
	
	area.body_entered.connect(func(body):
		if body == player:
			_set_interactable("senor_apoyo")
	)
	area.body_exited.connect(func(body):
		if body == player and current_interactable == "senor_apoyo":
			_clear_interactable()
	)
	
	add_child(senor_apoyo_node)

func _start_senor_apoyo_dialog():
	var spr = senor_apoyo_node.get_node("Sprite2D") as Sprite2D
	spr.texture = load(GameManager.get_apoyo_spritesheet_path())
	SpriteLayout.configure(spr, senor_apoyo_node.get_node("NameTag"))
	player.can_move = false
	touch_controls.visible = false
	
	dialog_queue = [
		{
			"speaker": "El Señor",
			"portrait": "res://assets/characters/senor_apoyo_portrait.png",
			"color": Color("#e67e22"),
			"portrait_texture": GameManager.get_apoyo_portrait(),
			"text": "¿Me apoyas?"
		},
		{
			"speaker": "Israel",
			"portrait": "res://assets/characters/israel_portrait.png",
			"color": Color("#e74c3c"),
			"text": "Estoy ocupado."
		}
	]
	
	if GameManager.apoyo_is_skeleton() and not GameManager.apoyo_skeleton_comment_seen:
		dialog_queue.insert(1, {
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#f1c40f"),
			"text": "Ya déjalo, ya está muerto."
		})
		GameManager.apoyo_skeleton_comment_seen = true

	on_dialog_closed_callback = func():
		GameManager.player_saved_position = player.global_position
		GameManager.current_enemy_id = "senor_apoyo"
		GameManager.current_enemy_data = {
			"name": "El Señor",
			"type": "senor_apoyo",
			"hp": 1,
			"max_hp": 1,
			"atk": 1,
			"def": 0,
			"exp_reward": 0,
			"portrait_path": "res://assets/characters/senor_apoyo_portrait.png",
			"is_skeleton": GameManager.apoyo_is_skeleton(),
			"spritesheet_path": GameManager.get_apoyo_spritesheet_path()
		}
		GameManager.change_scene_instant(get_tree(), "res://scenes/battle.tscn")
		
	_show_next_in_queue()

func _start_post_senor_apoyo_dialogue():
	dialog_queue.clear()
	on_dialog_closed_callback = Callable()
	player.can_move = false
	touch_controls.visible = false
	dialog_queue = [
		{
			"speaker": "El Señor",
			"portrait": "res://assets/characters/senor_apoyo_portrait.png",
			"portrait_texture": GameManager.get_apoyo_portrait(not GameManager.current_enemy_data.get("is_skeleton", false)),
			"color": Color("#e67e22"),
			"text": "¿Me... apoyas?"
		},
		{
			"speaker": "Israel",
			"portrait": "res://assets/characters/israel_portrait.png",
			"color": Color("#e74c3c"),
			"text": GameManager.get_apoyo_taunt()
		}
	]
	on_dialog_closed_callback = func():
		player.can_move = true
		touch_controls.visible = true
	_show_next_in_queue()

func _start_brujiris_battle():
	GameManager.player_saved_position = player.global_position
	GameManager.current_enemy_id = "brujiris"
	var spec = {
		"name": "Brujiris",
		"type": "brujiris",
		"desc": "¡Exige ver las grabaciones de seguridad de inmediato! No encuentra su caja con documentos clave.",
		"hp": 180,
		"max_hp": 180,
		"atk": 16,
		"def": 6,
		"exp_reward": 260,
		"portrait_path": "res://assets/characters/npc_curly_portrait.png",
		"spritesheet_path": "res://assets/characters/npc_curly_spritesheet.png",
		"attacks": [
			"Auditoría Sorpresa Inapelable",
			"Exigir Grabaciones de Cámaras",
			"Póliza Extraviada de Alto Riesgo",
			"Reclamo Directo a Dirección"
		]
	}
	GameManager.current_enemy_data = spec
	GameManager.change_scene_instant(get_tree(), "res://scenes/battle.tscn")

func _refresh_paper_quest_giver() -> void:
	if not GameManager.director_cutscene_done or not GameManager.printer_defeated:
		return
	if not player.can_move or dialog_box.visible:
		return
	if GameManager.paper_quest_state < 2 and not director_censurado.visible:
		director_censurado.position = Vector2(750, 155)
		director_censurado.visible = true
		director_censurado.set_meta("paper_only", true)
		$DirectorCensurado/NameTag.text = "Personaje Legalmente Seguro"
	elif GameManager.paper_quest_state == 2 and director_censurado.get_meta("paper_only", false):
		director_censurado.visible = false
		director_censurado.set_meta("paper_only", false)

func _start_paper_quest_dialog():
	var m_text = ""
	if not GameManager.printer_defeated:
		m_text = "¡Cuidado con esa máquina! ¡La impresora empezó a disparar tóner y tiene a Finanzas paralizado!"
	elif GameManager.paper_quest_state == 0:
		GameManager.paper_quest_accepted = true
		m_text = "¡Hola! Por fin calmaron a la impresora, pero se quedó totalmente vacía sin papel para terminar la nómina. ¿Podrías ir al estante de suministros en Finanzas por un paquete de hojas bond?"
		objective_label.text = "[Misión] Ve al estante de papelería en Finanzas por un paquete de hojas bond"
	elif GameManager.paper_quest_state == 1:
		m_text = "¡Excelente, ya tienes el paquete de hojas! Ve a colocarlas en la Bandeja 1 de la impresora para que pueda terminar la nómina."
	else:
		m_text = "¡Muchísimas gracias! Ahora sí pudimos imprimir toda la nómina quincenal a tiempo. ¡Eres el mejor de Sistemas!"

	dialog_queue = [
		{
			"speaker": "Personaje Legalmente Seguro",
			"portrait": "res://assets/characters/director_censurado_portrait.png",
			"color": Color("#fdcb6e"),
			"text": m_text
		}
	]
	on_dialog_closed_callback = func():
		player.can_move = true
	player.can_move = false
	_show_next_in_queue()

func _setup_paper_quest():
	if supply_box_node != null:
		supply_box_node.queue_free()
		supply_box_node = null
	# The existing censored director gives the quest; do not spawn another NPC.
	# Estante de hojas en Finanzas, fuera de los cuatro escritorios del site.
	supply_box_node = Node2D.new()
	supply_box_node.name = "SupplyPaperBox"
	supply_box_node.y_sort_enabled = true
	supply_box_node.position = Vector2(1200, 75)
	
	var spr_b = Sprite2D.new()
	spr_b.name = "Sprite2D"
	spr_b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if ResourceLoader.exists("res://assets/props/printer.png"):
		spr_b.texture = load("res://assets/props/printer.png")
		spr_b.scale = Vector2(0.35, 0.35)
	spr_b.modulate = Color(0.85, 0.9, 1.0)
	supply_box_node.add_child(spr_b)
	
	var tag_b = Label.new()
	tag_b.name = "NameTag"
	tag_b.offset_left = -70.0
	tag_b.offset_top = -30.0
	tag_b.offset_right = 70.0
	tag_b.offset_bottom = -15.0
	tag_b.add_theme_font_size_override("font_size", 8)
	tag_b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_b.text = "[Estante] Hojas Bond"
	tag_b.modulate = Color(1.0, 0.85, 0.4)
	supply_box_node.add_child(tag_b)
	
	var area_b = Area2D.new()
	area_b.name = "InteractArea"
	area_b.collision_layer = 4
	area_b.collision_mask = 1
	var col_b = CollisionShape2D.new()
	var circle_b = CircleShape2D.new()
	circle_b.radius = 28.0
	col_b.shape = circle_b
	area_b.add_child(col_b)
	supply_box_node.add_child(area_b)
	
	area_b.body_entered.connect(func(body):
		if body == player:
			_set_interactable("supply_paper_box")
	)
	area_b.body_exited.connect(func(body):
		if body == player and current_interactable == "supply_paper_box":
			_clear_interactable()
	)
	add_child(supply_box_node)

func _setup_brujiris_office():
	if door_brujiris_node != null:
		door_brujiris_node.queue_free()
		door_brujiris_node = null
	if brujiris_office_root != null:
		brujiris_office_root.queue_free()
		brujiris_office_root = null
		
	# 1. Puerta en el pasillo principal hacia la oficina de Auditoría (x: 1280, y: 52)
	door_brujiris_node = Node2D.new()
	door_brujiris_node.name = "DoorBrujiris"
	door_brujiris_node.y_sort_enabled = true
	door_brujiris_node.position = Vector2(1280, 52)
	
	var door_vis = ColorRect.new()
	door_vis.size = Vector2(34, 44)
	door_vis.position = Vector2(-17, -22)
	door_vis.color = Color(0.25, 0.15, 0.35)
	door_brujiris_node.add_child(door_vis)
	
	var door_inner = ColorRect.new()
	door_inner.size = Vector2(28, 38)
	door_inner.position = Vector2(-14, -19)
	door_inner.color = Color(0.38, 0.22, 0.5)
	door_brujiris_node.add_child(door_inner)
	
	var tag_d = Label.new()
	tag_d.name = "NameTag"
	tag_d.offset_left = -80.0
	tag_d.offset_top = -36.0
	tag_d.offset_right = 80.0
	tag_d.offset_bottom = -20.0
	tag_d.add_theme_font_size_override("font_size", 8)
	tag_d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_d.text = "[Puerta] Oficina Auditoría"
	tag_d.modulate = Color(0.9, 0.6, 1.0)
	door_brujiris_node.add_child(tag_d)
	
	var area_d = Area2D.new()
	area_d.name = "InteractArea"
	area_d.collision_layer = 4
	area_d.collision_mask = 1
	var col_d = CollisionShape2D.new()
	var circle_d = CircleShape2D.new()
	circle_d.radius = 26.0
	col_d.shape = circle_d
	area_d.add_child(col_d)
	door_brujiris_node.add_child(area_d)
	
	area_d.body_entered.connect(func(body):
		if body == player:
			_set_interactable("door_brujiris")
	)
	area_d.body_exited.connect(func(body):
		if body == player and current_interactable == "door_brujiris":
			_clear_interactable()
	)
	add_child(door_brujiris_node)
	
	# 2. Estructura e interior de la oficina independiente (x: 3200..3840, y: 0..360)
	brujiris_office_root = Node2D.new()
	brujiris_office_root.name = "BrujirisOfficeRoot"
	brujiris_office_root.y_sort_enabled = true
	brujiris_office_root.position = Vector2(3200, 0)
	
	var floor_rect = ColorRect.new()
	floor_rect.z_index = -2
	floor_rect.size = Vector2(640, 360)
	floor_rect.color = Color(0.12, 0.09, 0.16)
	brujiris_office_root.add_child(floor_rect)
	
	var rug_rect = ColorRect.new()
	rug_rect.z_index = -1
	rug_rect.position = Vector2(100, 80)
	rug_rect.size = Vector2(440, 210)
	rug_rect.color = Color(0.19, 0.14, 0.26)
	brujiris_office_root.add_child(rug_rect)
	
	var wall_top = ColorRect.new()
	wall_top.size = Vector2(640, 60)
	wall_top.color = Color(0.08, 0.06, 0.11)
	brujiris_office_root.add_child(wall_top)
	
	var wall_bottom = ColorRect.new()
	wall_bottom.position = Vector2(0, 330)
	wall_bottom.size = Vector2(640, 30)
	wall_bottom.color = Color(0.08, 0.06, 0.11)
	brujiris_office_root.add_child(wall_bottom)
	
	var wall_left = ColorRect.new()
	wall_left.size = Vector2(25, 360)
	wall_left.color = Color(0.08, 0.06, 0.11)
	brujiris_office_root.add_child(wall_left)
	
	var wall_right = ColorRect.new()
	wall_right.position = Vector2(615, 0)
	wall_right.size = Vector2(25, 360)
	wall_right.color = Color(0.08, 0.06, 0.11)
	brujiris_office_root.add_child(wall_right)
	
	var borders_body = StaticBody2D.new()
	borders_body.name = "OfficeBorders"
	borders_body.collision_layer = 2
	
	var col_top = CollisionShape2D.new()
	var rect_top = RectangleShape2D.new()
	rect_top.size = Vector2(640, 60)
	col_top.shape = rect_top
	col_top.position = Vector2(320, 30)
	borders_body.add_child(col_top)
	
	var col_bot = CollisionShape2D.new()
	var rect_bot = RectangleShape2D.new()
	rect_bot.size = Vector2(640, 30)
	col_bot.shape = rect_bot
	col_bot.position = Vector2(320, 345)
	borders_body.add_child(col_bot)
	
	var col_l = CollisionShape2D.new()
	var rect_l = RectangleShape2D.new()
	rect_l.size = Vector2(25, 360)
	col_l.shape = rect_l
	col_l.position = Vector2(12.5, 180)
	borders_body.add_child(col_l)
	
	var col_r = CollisionShape2D.new()
	var rect_r = RectangleShape2D.new()
	rect_r.size = Vector2(25, 360)
	col_r.shape = rect_r
	col_r.position = Vector2(627.5, 180)
	borders_body.add_child(col_r)
	
	brujiris_office_root.add_child(borders_body)
	
	var exit_door = Node2D.new()
	exit_door.name = "ExitDoor"
	exit_door.position = Vector2(35, 200)
	
	var exit_vis = ColorRect.new()
	exit_vis.size = Vector2(14, 48)
	exit_vis.position = Vector2(-7, -24)
	exit_vis.color = Color(0.2, 0.45, 0.6)
	exit_door.add_child(exit_vis)
	
	var tag_ex = Label.new()
	tag_ex.offset_left = 12.0
	tag_ex.offset_top = -10.0
	tag_ex.offset_right = 100.0
	tag_ex.offset_bottom = 10.0
	tag_ex.add_theme_font_size_override("font_size", 8)
	tag_ex.text = "[Puerta] Salir"
	tag_ex.modulate = Color(0.6, 0.85, 1.0)
	exit_door.add_child(tag_ex)
	
	var area_ex = Area2D.new()
	area_ex.name = "InteractArea"
	area_ex.collision_layer = 4
	area_ex.collision_mask = 1
	var col_ex = CollisionShape2D.new()
	var circle_ex = CircleShape2D.new()
	circle_ex.radius = 26.0
	col_ex.shape = circle_ex
	area_ex.add_child(col_ex)
	exit_door.add_child(area_ex)
	
	area_ex.body_entered.connect(func(body):
		if body == player:
			_set_interactable("door_brujiris_exit")
	)
	area_ex.body_exited.connect(func(body):
		if body == player and current_interactable == "door_brujiris_exit":
			_clear_interactable()
	)
	brujiris_office_root.add_child(exit_door)
	
	var cctv_panel = Node2D.new()
	cctv_panel.position = Vector2(320, 38)
	for ci in range(4):
		var screen = ColorRect.new()
		screen.size = Vector2(48, 28)
		screen.position = Vector2(-110 + ci * 58, -14)
		screen.color = Color(0.1, 0.25, 0.3)
		cctv_panel.add_child(screen)
		var screen_inner = ColorRect.new()
		screen_inner.size = Vector2(44, 24)
		screen_inner.position = Vector2(-108 + ci * 58, -12)
		screen_inner.color = Color(0.15, 0.45, 0.4)
		cctv_panel.add_child(screen_inner)
	var cctv_tag = Label.new()
	cctv_tag.offset_left = -120.0
	cctv_tag.offset_top = -24.0
	cctv_tag.offset_right = 120.0
	cctv_tag.offset_bottom = -14.0
	cctv_tag.add_theme_font_size_override("font_size", 7)
	cctv_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cctv_tag.text = "CCTV MONITORING - PISOS 1 A 4"
	cctv_tag.modulate = Color(0.4, 0.9, 0.8)
	cctv_panel.add_child(cctv_tag)
	brujiris_office_root.add_child(cctv_panel)
	
	var desk_node = Node2D.new()
	desk_node.y_sort_enabled = false
	desk_node.position = Vector2(320, 180)
	var desk_vis = ColorRect.new()
	desk_vis.size = Vector2(100, 40)
	desk_vis.position = Vector2(-50, -20)
	desk_vis.color = Color(0.3, 0.18, 0.12)
	desk_node.add_child(desk_vis)
	
	var desk_body = StaticBody2D.new()
	desk_body.collision_layer = 2
	var desk_col = CollisionShape2D.new()
	var desk_shape = RectangleShape2D.new()
	desk_shape.size = Vector2(100, 36)
	desk_col.shape = desk_shape
	desk_body.add_child(desk_col)
	desk_node.add_child(desk_body)
	
	var box_prop = ColorRect.new()
	box_prop.size = Vector2(18, 14)
	box_prop.position = Vector2(35, 12)
	box_prop.color = Color(0.8, 0.65, 0.35)
	desk_node.add_child(box_prop)
	brujiris_office_root.add_child(desk_node)
	
	brujiris_npc_node = Node2D.new()
	brujiris_npc_node.name = "BrujirisNPC"
	brujiris_npc_node.y_sort_enabled = true
	brujiris_npc_node.position = Vector2(320, 140)
	
	var spr_bruj = Sprite2D.new()
	spr_bruj.name = "Sprite2D"
	spr_bruj.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sheet_path_bruj = "res://assets/characters/npc_curly_spritesheet.png"
	if ResourceLoader.exists(sheet_path_bruj):
		spr_bruj.texture = load(sheet_path_bruj)
	spr_bruj.hframes = 4
	spr_bruj.vframes = 12
	spr_bruj.frame = 0
	spr_bruj.scale = Vector2(0.24, 0.24)
	spr_bruj.position = Vector2(0, -10)
	brujiris_npc_node.add_child(spr_bruj)
	
	var tag_bruj = Label.new()
	tag_bruj.name = "NameTag"
	tag_bruj.offset_left = -70.0
	tag_bruj.offset_top = -32.0
	tag_bruj.offset_right = 70.0
	tag_bruj.offset_bottom = -16.0
	tag_bruj.add_theme_font_size_override("font_size", 8)
	tag_bruj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_bruj.text = "[Auditoría] Brujiris"
	tag_bruj.modulate = Color(0.95, 0.45, 0.85)
	brujiris_npc_node.add_child(tag_bruj)
	
	var area_bruj = Area2D.new()
	area_bruj.name = "InteractArea"
	area_bruj.collision_layer = 4
	area_bruj.collision_mask = 1
	var col_bruj = CollisionShape2D.new()
	var circle_bruj = CircleShape2D.new()
	circle_bruj.radius = 32.0
	col_bruj.shape = circle_bruj
	area_bruj.add_child(col_bruj)
	brujiris_npc_node.add_child(area_bruj)
	
	area_bruj.body_entered.connect(func(body):
		if body == player:
			_set_interactable("brujiris")
	)
	area_bruj.body_exited.connect(func(body):
		if body == player and current_interactable == "brujiris":
			_clear_interactable()
	)
	brujiris_office_root.add_child(brujiris_npc_node)
	
	add_child(brujiris_office_root)

func _setup_debug_and_save_ui():
	var top_right_bar = HBoxContainer.new()
	top_right_bar.name = "TopRightBar"
	top_right_bar.anchor_left = 1.0
	top_right_bar.anchor_right = 1.0
	top_right_bar.offset_left = -210.0
	top_right_bar.offset_top = 8.0
	top_right_bar.offset_right = -10.0
	top_right_bar.offset_bottom = 34.0
	top_right_bar.add_theme_constant_override("separation", 6)
	
	btn_save_hud = Button.new()
	btn_save_hud.name = "BtnSaveHUD"
	btn_save_hud.text = "💾 Guardar"
	btn_save_hud.custom_minimum_size = Vector2(95, 26)
	btn_save_hud.add_theme_font_size_override("font_size", 10)
	btn_save_hud.pressed.connect(_on_save_pressed)
	top_right_bar.add_child(btn_save_hud)
	
	btn_debug_hud = Button.new()
	btn_debug_hud.name = "BtnDebugHUD"
	btn_debug_hud.text = "🛠️ Debug"
	btn_debug_hud.custom_minimum_size = Vector2(95, 26)
	btn_debug_hud.add_theme_font_size_override("font_size", 10)
	btn_debug_hud.pressed.connect(_open_debug_modal)
	top_right_bar.add_child(btn_debug_hud)
	
	$CanvasLayer/HUD.add_child(top_right_bar)
	
	save_toast_label = Label.new()
	save_toast_label.name = "SaveToast"
	save_toast_label.anchor_left = 0.5
	save_toast_label.anchor_right = 0.5
	save_toast_label.offset_left = -160.0
	save_toast_label.offset_top = 45.0
	save_toast_label.offset_right = 160.0
	save_toast_label.offset_bottom = 75.0
	save_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	save_toast_label.add_theme_font_size_override("font_size", 11)
	save_toast_label.text = "💾 ¡Partida guardada con éxito!"
	save_toast_label.modulate = Color(0.3, 1.0, 0.5, 0.0)
	$CanvasLayer.add_child(save_toast_label)
	
	_create_debug_modal()

func _create_debug_modal():
	debug_modal = PanelContainer.new()
	debug_modal.name = "DebugModal"
	debug_modal.anchor_left = 0.5
	debug_modal.anchor_top = 0.5
	debug_modal.anchor_right = 0.5
	debug_modal.anchor_bottom = 0.5
	debug_modal.offset_left = -220.0
	debug_modal.offset_top = -160.0
	debug_modal.offset_right = 220.0
	debug_modal.offset_bottom = 160.0
	debug_modal.visible = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_color = Color(0.9, 0.75, 0.2, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	debug_modal.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	debug_modal.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "🛠️ MENÚ DEBUG / PUNTOS DE CONTROL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 12)
	title.modulate = Color(1.0, 0.85, 0.3)
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Inicia directamente desde cualquier jefe terminado o fase:"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.modulate = Color(0.7, 0.7, 0.7)
	vbox.add_child(subtitle)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(390, 210)
	var list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 5)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	vbox.add_child(scroll)
	
	var checkpoints = [
		{"id": "new_game", "label": "▶️ 1. Nueva Partida (Intro con Roberto Huerta)"},
		{"id": "post_printer", "label": "🖨️ 2. Post-Impresora (Capítulo 2: Finanzas abiertas, Tienda Nelly)"},
		{"id": "post_dragon", "label": "🐉 3. Post-Señor del Dragón (Capítulo 3: Huyó, Personaje Seguro)"},
		{"id": "post_server", "label": "💻 4. Post-Servidor 117 (Victoria Total Redes, Nivel 4)"},
		{"id": "paper_quest", "label": "📄 5. Misión Hojas Impresora (Hojas en mano para entregar)"},
		{"id": "brujiris_office", "label": "🚪 6. Teletransportar a Oficina de Brujiris (Auditoría)"}
	]
	
	for cp in checkpoints:
		var btn = Button.new()
		btn.text = cp["label"]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 9)
		var c_id = cp["id"]
		btn.pressed.connect(func():
			_close_debug_modal()
			GameManager.apply_debug_checkpoint(c_id)
			get_tree().reload_current_scene()
		)
		list.add_child(btn)
		
	var sep = HSeparator.new()
	list.add_child(sep)
	
	var btn_buff = Button.new()
	btn_buff.text = "⚡ Buff Stats (+100 HP, +30 ATK a la party)"
	btn_buff.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn_buff.add_theme_font_size_override("font_size", 9)
	btn_buff.pressed.connect(func():
		for p in GameManager.party:
			p["max_hp"] += 100
			p["hp"] = p["max_hp"]
			p["atk"] += 30
		for k in GameManager.characters_data.keys():
			GameManager.characters_data[k]["max_hp"] += 100
			GameManager.characters_data[k]["hp"] = GameManager.characters_data[k]["max_hp"]
			GameManager.characters_data[k]["atk"] += 30
		_update_hud_stats()
		_show_save_toast("⚡ ¡Stats mejorados con éxito!")
	)
	list.add_child(btn_buff)
	
	var btn_del_save = Button.new()
	btn_del_save.text = "🗑️ Borrar Archivo de Guardado"
	btn_del_save.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn_del_save.add_theme_font_size_override("font_size", 9)
	btn_del_save.pressed.connect(func():
		GameManager.delete_save_file()
		_show_save_toast("🗑️ Guardado eliminado")
	)
	list.add_child(btn_del_save)
	
	var btn_close = Button.new()
	btn_close.text = "Cerrar Menú Debug"
	btn_close.add_theme_font_size_override("font_size", 10)
	btn_close.pressed.connect(_close_debug_modal)
	vbox.add_child(btn_close)
	
	$CanvasLayer.add_child(debug_modal)

func _open_debug_modal():
	debug_modal.visible = true
	player.can_move = false

func _close_debug_modal():
	debug_modal.visible = false
	player.can_move = true

func _on_save_pressed():
	if player:
		GameManager.player_saved_position = player.global_position
	var ok = GameManager.save_game()
	if ok:
		_show_save_toast("💾 ¡Partida Guardada con éxito!")
	else:
		_show_save_toast("❌ Error al guardar partida")

func _show_save_toast(msg: String):
	if save_toast_label:
		save_toast_label.text = msg
		save_toast_label.modulate.a = 1.0
		var tw = create_tween()
		tw.tween_interval(1.5)
		tw.tween_property(save_toast_label, "modulate:a", 0.0, 0.6)

func _update_objective_label_for_current_state():
	if GameManager.intro_cutscene_done and not GameManager.office_cutscene_done and GameManager.party.size() < 4:
		objective_label.text = "[!] Recluta tres compañeros en sus escritorios. Equipo: %d/4" % GameManager.party.size()
		return
	if GameManager.inside_brujiris_office:
		objective_label.text = "[!] Oficina de Auditoría - Habla con Brujiris"
	elif GameManager.server_boss_defeated:
		objective_label.text = "[!] ¡Victoria Total! Servidores 100, 245, 189, 122 y 117 conectados. ¡Habla con Roberto!"
	elif GameManager.dragon_boss_defeated:
		objective_label.text = "[!] ¡Ve a la Sala de Servidores al este y resuelve el Servidor 117!"
	elif GameManager.printer_defeated:
		if GameManager.paper_quest_state == 1:
			objective_label.text = "[Misión] Coloca las hojas bond en la Bandeja 1 de la impresora de Finanzas"
		elif GameManager.paper_quest_state == 0 and GameManager.paper_quest_accepted:
			objective_label.text = "[Misión] Recoge las hojas bond del estante de Finanzas y llévalas a la impresora"
		elif GameManager.paper_quest_state == 0:
			objective_label.text = "[Misión] Habla con el Personaje Legalmente Seguro en Finanzas para ayudar con el papel"
		else:
			objective_label.text = obj_victory_text
	elif GameManager.office_cutscene_done:
		objective_label.text = obj_battle_text
	else:
		objective_label.text = obj_follow_text

func _start_dragon_boss_flee_sequence():
	player.can_move = false
	touch_controls.visible = false
	objective_label.text = "[!] ¡El Señor del Dragón huye despavorido de la oficina!"
	
	# Animación chibi corriendo hacia la derecha y desapareciendo
	var tween = create_tween()
	tween.tween_property(dragon_boss, "position:x", 2250.0, 1.1)
	tween.tween_callback(func():
		dragon_boss.visible = false
		GameManager.dragon_flee_cutscene_done = true
		_start_director_incident_dialogue()
	)

func _start_director_incident_dialogue():
	player.can_move = false
	touch_controls.visible = false
	director_censurado.visible = true
	if director_censurado.has_node("NameTag"):
		$DirectorCensurado/NameTag.text = "[!] Personaje Legalmente Seguro"
	
	dialog_queue = [
		{
			"speaker": "Personaje Legalmente Seguro",
			"portrait": "res://assets/characters/director_censurado_portrait.png",
			"color": Color("#fdcb6e"),
			"text": "¡Muchachos de Sistemas! Necesito conectarme al servidor 100 desde el 245 para poder alcanzar el 189..."
		},
		{
			"speaker": "Personaje Legalmente Seguro",
			"portrait": "res://assets/characters/director_censurado_portrait.png",
			"color": Color("#fdcb6e"),
			"text": "...¡pero no puedo porque el 122 no da, y nadie se sabe la contraseña del 117!"
		},
		{
			"speaker": "Personaje Legalmente Seguro",
			"portrait": "res://assets/characters/director_censurado_portrait.png",
			"color": Color("#fdcb6e"),
			"text": "¡Tienen que ir ya mismo a la Sala de Servidores (al este) a resolver el problema del 117 antes de que colapse la red!"
		}
	]
	
	on_dialog_closed_callback = func():
		GameManager.director_cutscene_done = true
		GameManager.password_quest_active = true
		objective_label.text = "[!] ¡Ve a la Sala de Servidores (al este) y resuelve el Servidor 117!"
		
		# Personaje Legalmente Seguro también se va
		var tween_dir = create_tween()
		director_sprite.frame = 2 * 4 + 0 # Mirando a la izquierda al irse
		tween_dir.tween_property(director_censurado, "position:x", director_censurado.position.x - 380.0, 1.0)
		tween_dir.tween_callback(func():
			director_censurado.visible = false
			player.can_move = true
			touch_controls.visible = true
		)
		
	_show_next_in_queue()

func _start_server_site_cutscene():
	player.can_move = false
	roberto.visible = true
	roberto.position = Vector2(player.global_position.x - 70, 180)
	roberto_sprite.frame = 6 * 4 + 0 # Mirando hacia el jugador y el servidor
	
	dialog_queue = [
		{
			"speaker": "Roberto Huerta",
			"portrait": "res://assets/characters/roberto_huerta_portrait.png",
			"color": Color("#0984e3"),
			"text": "¡Tranquilos muchachos, yo ayudo! ¡Dejen le tomo foto a la pantalla del Servidor 117 para ver qué pide!"
		}
	]
	
	on_dialog_closed_callback = func():
		on_photo_closed_callback = func():
			dialog_queue = [
				{
					"speaker": "Roberto Huerta",
					"portrait": "res://assets/characters/roberto_huerta_portrait.png",
					"color": Color("#0984e3"),
					"text": "¡Listo, ya le tomé foto!... Ah caray, la pantalla solo dice 'Usuario' y pide el texto... ¡no sale la contraseña!"
				},
				{
					"speaker": "Roberto Huerta",
					"portrait": "res://assets/characters/roberto_huerta_portrait.png",
					"color": Color("#0984e3"),
					"text": "¡Bueno, yo ya cumplí con avisar y tomar la foto! ¡Ahí se ven, me voy de nuevo!"
				}
			]
			on_dialog_closed_callback = func():
				# Roberto escapa corriendo hacia la izquierda
				var tween = create_tween()
				tween.tween_property(roberto, "position:x", roberto.position.x - 300, 0.7)
				tween.tween_callback(func():
					roberto.visible = false
				)
				# Servidor 117 entra en alerta crítica y desafía al jugador
				dialog_queue = [
					{
						"speaker": "Servidor 117",
						"portrait": "res://assets/enemies/boss_password_portrait.png",
						"color": Color("#e74c3c"),
						"text": "¡ERROR CRÍTICO: FALLA DE ENRUTAMIENTO!\n\nNo se puede conectar al servidor 100 desde el 245 para alcanzar el 189 porque el 122 no da.\n¡La Contraseña Olvidada del 117 se materializa para bloquear el acceso!"
					}
				]
				on_dialog_closed_callback = func():
					_start_server_boss_battle()
				_show_next_in_queue()
			_show_next_in_queue()
		_open_photo_modal()
		
	_show_next_in_queue()

func _open_photo_modal():
	player.can_move = false
	photo_modal.visible = true

func _close_photo_modal():
	photo_modal.visible = false
	if on_photo_closed_callback.is_valid():
		var cb = on_photo_closed_callback
		on_photo_closed_callback = Callable()
		cb.call()
	else:
		player.can_move = true

func _open_server_login_modal():
	player.can_move = false
	server_login_modal.visible = true
	pass_input.text = ""
	hint_label.text = "(Foto de Roberto: 'Solo dice Usuario y pide el texto...')"
	hint_label.modulate = Color(1.0, 0.75, 0.3)
	pass_input.grab_focus()

func _close_server_login_modal():
	server_login_modal.visible = false
	player.can_move = true

func _on_submit_password():
	hint_label.text = "¡ERROR: Texto Incorrecto! ¡El sistema se ha bloqueado!"
	hint_label.modulate = Color(1.0, 0.3, 0.3)
	await get_tree().create_timer(1.2).timeout
	_close_server_login_modal()
	_start_server_boss_battle()

func _start_server_boss_battle():
	GameManager.player_saved_position = player.global_position
	GameManager.current_enemy_id = "server_password_boss"
	var spec = {
		"name": "Contraseña del Servidor 117",
		"type": "password_boss",
		"desc": "Nadie se sabe la contraseña del 117 para llegar al 189 desde el 245 pasando por el 100 porque el 122 no da.",
		"hp": 750,
		"max_hp": 750,
		"atk": 26,
		"def": 15,
		"exp_reward": 450,
		"texture_path": "res://assets/enemies/boss_password_server.png",
		"attacks": [
			"Falla de Ruta (245 -> 100 -> 189)",
			"El 122 No Da (Timeout)",
			"Contraseña Desconocida del 117",
			"Foto Inútil de Roberto",
			"Bloqueo de Acceso Total"
		]
	}
	GameManager.current_enemy_data = spec
	GameManager.change_scene_instant(get_tree(), "res://scenes/battle.tscn")

func _open_demo_modal():
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	var hero_role = leader["role"]
	var hero_title = leader["title"]
	var hero_level = leader.get("level", 1)
	
	if GameManager.server_boss_defeated:
		demo_title.text = "¡HÉROE SUPREMO DE IT!"
		demo_subtitle.text = "¡Felicidades %s! ¡Has salvado el Site y conectado los servidores!" % hero_name
		demo_body.text = ("Has superado todos los desafíos de IT Adventures:\n\n" +
			" 1. Neutralizaste la Impresora Maldita y salvaste la nómina.\n" +
			" 2. Derrotaste a El Señor del Dragón dejándolo hincado.\n" +
			" 3. Resolviste la ruta de red (245 -> 100 -> 189) desbloqueando el Servidor 117 tras la foto de Roberto.\n\n" +
			"Héroe Legendario: %s [Nivel %d - %s]\n" +
			"Fondos de IT Restantes: $%d\n\n" +
			"[!] ¡Has completado con honores toda la Demo de IT Adventures!") % [hero_name, hero_level, hero_role, GameManager.it_budget]
	elif GameManager.dragon_boss_defeated:
		demo_title.text = "¡VICTORIA LEGENDARIA!"
		demo_subtitle.text = "¡Felicidades %s! ¡Has derrotado al Señor del Dragón!" % hero_name
		demo_body.text = ("Has vencido a la Impresora Maldita y derrotado a las Sombras del Pasado.\n\n" +
			"¡El splitter, los discos duros y el Magic Trackpad han sido rescatados para Sistemas!\n\n" +
			"Héroe Legendario: %s [Nivel %d - %s]\n" +
			"Especialidad: %s\n\n" +
			"[!] ¡Avanza a la Sala de Servidores para resolver el Servidor 117 y las rutas de red!") % [hero_name, hero_level, hero_role, hero_title]
	else:
		demo_subtitle.text = "¡Gracias %s, esto solo es un demo!" % hero_name
		demo_body.text = ("Has neutralizado con éxito a la Impresora Maldita y salvado la nómina de Finanzas.\n\n" +
			"Héroe de la Misión: %s [Nivel %d - %s]\n" +
			"Especialidad: %s\n\n" +
			"[!] Novedades del Sistema de TI:\n" +
			" - ¡Batalla contra el Señor del Dragón en el pasillo principal!\n" +
			" - Sistema de turnos 1v1 dinámico y botiquín de oficina\n" +
			" - Habla con el equipo de Finanzas para más misiones") % [hero_name, hero_level, hero_role, hero_title]
		
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
		"director":
			interact_label.text = "[E] Hablar con Personaje Legalmente Seguro"
			btn_interact.text = "[E] Hablar"
		"server_boss":
			if GameManager.server_boss_defeated:
				interact_label.text = "[E] Inspeccionar Servidor 117 (Desbloqueado)"
				btn_interact.text = "[E] Revisar"
			else:
				interact_label.text = "[E] ¡Inspeccionar Servidor 117!"
				btn_interact.text = "[E] Inspeccionar"
		"dragon_boss_kneeling":
			interact_label.text = "[E] Hablar con El Señor del Dragón (Hincado)"
			btn_interact.text = "[E] Hablar"
		"nelly":
			interact_label.text = "[E] Tiendita de Nelly (Suministros IT)"
			btn_interact.text = "[E] Tiendita"
		"usuaria":
			interact_label.text = "[E] Hablar con Jefa de Finanzas"
			btn_interact.text = "[E] Hablar"
		"roberto":
			interact_label.text = "[E] Hablar con Roberto Huerta"
			btn_interact.text = "[E] Hablar"
		"senor_apoyo":
			interact_label.text = "[E] Hablar con El Señor ('¿Me apoyas?')"
			btn_interact.text = "[E] Hablar"
		"dragon_boss":
			interact_label.text = "[E] ¡Pelear con El Señor del Dragón!"
			btn_interact.text = "[E] Pelear"
		"printer":
			if GameManager.printer_defeated:
				if GameManager.paper_quest_state == 1:
					interact_label.text = "[E] Colocar hojas bond en la Bandeja 1"
					btn_interact.text = "[E] Abastecer"
				elif GameManager.paper_quest_state == 2:
					interact_label.text = "[E] Inspeccionar Impresora (Abastecida y Operativa)"
					btn_interact.text = "[E] Revisar"
				else:
					interact_label.text = "[E] Inspeccionar Impresora (Sin papel)"
					btn_interact.text = "[E] Revisar"
			else:
				interact_label.text = "[E] ¡Combatir Impresora Maldita!"
				btn_interact.text = "[E] Batalla"
		"supply_paper_box":
			if GameManager.paper_quest_state == 1:
				interact_label.text = "[E] Estante de Papelería (Ya tienes hojas)"
			elif GameManager.paper_quest_state == 2:
				interact_label.text = "[E] Estante de Papelería (Abastecido)"
			else:
				interact_label.text = "[E] Recoger paquete de hojas bond"
			btn_interact.text = "[E] Tomar"
		"door_brujiris":
			interact_label.text = "[E] Entrar a Oficina de Auditoría"
			btn_interact.text = "[E] Entrar"
		"door_brujiris_exit":
			interact_label.text = "[E] Salir al Pasillo Principal"
			btn_interact.text = "[E] Salir"
		"brujiris":
			if GameManager.brujiris_defeated:
				interact_label.text = "[E] Hablar con Brujiris (Tranquila)"
				btn_interact.text = "[E] Hablar"
			else:
				interact_label.text = "[E] Hablar con Brujiris (¡Exige cámaras!)"
				btn_interact.text = "[E] Hablar"
		_:
			if id.begins_with("companion_"):
				var c_id = id.trim_prefix("companion_")
				var c_data = GameManager.characters_data.get(c_id, {})
				var c_name = c_data.get("name", "Compañero")
				if GameManager.is_hero_in_party(c_id):
					interact_label.text = "[E] 👥 Hablar con %s (En Escuadrón)" % c_name
					btn_interact.text = "[E] Escuadrón"
				else:
					interact_label.text = "[E] 👥 Hablar / Reclutar a %s" % c_name
					btn_interact.text = "[E] Reclutar"

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
		
	if current_interactable.begins_with("companion_"):
		var c_id = current_interactable.trim_prefix("companion_")
		_interact_with_companion(c_id)
		return
		
	var leader = GameManager.get_leader_data()
	var hero_name = leader["name"]
	
	match current_interactable:
		"nelly":
			_open_shop_modal()
		"senor_apoyo":
			_start_senor_apoyo_dialog()
		"dragon_boss":
			_start_dragon_boss_battle()
		"director":
			if not GameManager.dragon_boss_defeated or GameManager.paper_quest_state < 2:
				_start_paper_quest_dialog()
			elif GameManager.server_boss_defeated:
				dialog_queue = [
					{
						"speaker": "Personaje Legalmente Seguro",
						"portrait": "res://assets/characters/director_censurado_portrait.png",
						"color": Color("#fdcb6e"),
						"text": "¡Excelente trabajo muchachos! Gracias a que resolvieron el Servidor 117, ya podemos alcanzar el 189 conectando desde el 245 al 100 sin problemas con el 122."
					}
				]
			else:
				dialog_queue = [
					{
						"speaker": "Personaje Legalmente Seguro",
						"portrait": "res://assets/characters/director_censurado_portrait.png",
						"color": Color("#fdcb6e"),
						"text": "¡Rápido muchachos! Necesito conectarme al servidor 100 desde el 245 para alcanzar el 189, pero el 122 no da y falta la clave del 117. ¡Vayan a la Sala de Servidores al este!"
					}
				]
			on_dialog_closed_callback = func():
				player.can_move = true
			player.can_move = false
			_show_next_in_queue()
		"dragon_boss_kneeling":
			dialog_queue = [
				{
					"speaker": "El Señor del Dragón",
					"portrait": "res://assets/characters/dragon_boss_portrait.png",
					"color": Color("#e17055"),
					"text": "[El Señor del Dragón sigue hincado en el suelo, respirando agitado y fulminándote con la mirada]\n\n'¡Lárguense al site antes de que me levante!... ¡Esto no es la última vez que sabrán de mí! ¡Volveré por mi dragón 3D!'"
				}
			]
			on_dialog_closed_callback = func():
				player.can_move = true
			player.can_move = false
			_show_next_in_queue()
		"roberto":
			if not GameManager.office_cutscene_done and GameManager.party.size() < 4:
				_warn_about_solo_it()
			elif not GameManager.office_cutscene_done:
				_refresh_team_departure()
			elif GameManager.server_boss_defeated:
				_open_demo_modal()
			elif GameManager.dragon_boss_defeated:
				dialog_queue = [
					{
						"speaker": "Roberto Huerta",
						"portrait": "res://assets/characters/roberto_huerta_portrait.png",
						"color": Color("#0984e3"),
						"text": "¡Corre a la Sala de Servidores al este, %s! ¡Apóyale a Personaje Legalmente Seguro con el Servidor 117!" % hero_name
					}
				]
				on_dialog_closed_callback = func():
					player.can_move = true
				player.can_move = false
				_show_next_in_queue()
			else:
				_open_demo_modal()
		"server_boss":
			if GameManager.server_boss_defeated:
				dialog_queue = [
					{
						"speaker": "Servidor 117",
						"portrait": "res://assets/enemies/boss_password_portrait.png",
						"color": Color("#4ade80"),
						"text": "El Servidor 117 funciona con normalidad. La ruta desde el 245 pasando por el 100 hasta el 189 ha sido establecida con éxito.\n\nAcceso concedido: root@srv-117-prod (Enrutamiento OK, 122 restablecido)."
					}
				]
				on_dialog_closed_callback = func():
					player.can_move = true
				player.can_move = false
				_show_next_in_queue()
			else:
				_start_server_site_cutscene()
		"usuaria":
			dialog_queue = [
				{
					"speaker": "Jefa de Finanzas",
					"portrait": "res://assets/characters/usuaria_portrait.png",
					"color": Color("#fd79a8"),
					"text": (jefa_chat_post % hero_name) if GameManager.printer_defeated else usuaria_office_1
				}
			]
			on_dialog_closed_callback = func():
				player.can_move = true
			player.can_move = false
			_show_next_in_queue()
		"door_brujiris":
			player.global_position = Vector2(3260, 200)
			GameManager.inside_brujiris_office = true
			$Player/Camera2D.limit_left = 3200
			$Player/Camera2D.limit_right = 3840
			objective_label.text = "[!] Oficina de Auditoría - Habla con Brujiris"
			_clear_interactable()
		"door_brujiris_exit":
			player.global_position = Vector2(1280, 90)
			GameManager.inside_brujiris_office = false
			$Player/Camera2D.limit_left = 0
			$Player/Camera2D.limit_right = 3072
			_update_objective_label_for_current_state()
			_clear_interactable()
		"supply_paper_box":
			var b_text = ""
			if not GameManager.paper_quest_accepted and GameManager.paper_quest_state == 0:
				b_text = "Primero habla con el Personaje Legalmente Seguro en Finanzas: él te encargará entregar las hojas a la impresora."
			elif GameManager.paper_quest_state == 0:
				GameManager.paper_quest_state = 1
				b_text = "¡Has recogido un paquete sellado de 500 hojas de papel bond blanco (75g)!\n\nLlévalas a la impresora en Finanzas para abastecerla."
				objective_label.text = "[Misión] Coloca las hojas bond en la Bandeja 1 de la impresora en Finanzas"
				_show_save_toast("📄 ¡Obtuviste 500 Hojas Bond!")
			elif GameManager.paper_quest_state == 1:
				b_text = "Ya tienes un paquete de 500 hojas bond en tu inventario. Llévalo a la impresora de Finanzas."
			else:
				b_text = "El estante de suministros está en orden. Ya abasteciste a la impresora de Finanzas."
			dialog_queue = [
				{
					"speaker": "Estante de Suministros",
					"portrait": "res://assets/props/printer.png",
					"color": Color("#ffeaa7"),
					"text": b_text
				}
			]
			on_dialog_closed_callback = func():
				player.can_move = true
			player.can_move = false
			_show_next_in_queue()
		"brujiris":
			if GameManager.brujiris_defeated:
				dialog_queue = [
					{
						"speaker": "Brujiris",
						"portrait": "res://assets/characters/npc_curly_portrait.png",
						"color": Color("#fd79a8"),
						"text": "¡Qué pena con ustedes, muchachos! La caja con las pólizas y documentos fiscales estaba aquí abajo del escritorio detrás del bote de basura. ¡Ya no revisen las cámaras, gracias por la paciencia!"
					}
				]
				on_dialog_closed_callback = func():
					player.can_move = true
				player.can_move = false
				_show_next_in_queue()
			else:
				dialog_queue = [
					{
						"speaker": "Brujiris",
						"portrait": "res://assets/characters/npc_curly_portrait.png",
						"color": Color("#fd79a8"),
						"text": "necesito revisen las camaras no encuetro una caja con documentacion muy importate"
					}
				]
				on_dialog_closed_callback = func():
					_start_brujiris_battle()
				player.can_move = false
				_show_next_in_queue()
		"printer":
			if GameManager.printer_defeated:
				if GameManager.paper_quest_state == 1:
					GameManager.paper_quest_state = 2
					var exp_reward = 150
					var coins_reward = 150
					GameManager.it_budget += coins_reward
					var _lvl_ups = GameManager.add_exp_to_party(exp_reward)
					_update_hud_stats()
					GameManager.save_game()
					_show_save_toast("✅ ¡Misión cumplida: +150 EXP, +$150!")
					
					dialog_queue = [
						{
							"speaker": "Impresora",
							"portrait": "res://assets/props/printer.png",
							"color": Color("#55efc4"),
							"text": "¡Colocas cuidadosamente las 500 hojas bond en la Bandeja 1!\n\nLos rodillos se alinean con un clic suave, la pantalla muestra 'BANDEJA 1: 100% LISTA' y una luz verde constante parpadea. ¡La nómina comienza a imprimirse con éxito!\n\n(Recompensa: +150 EXP para el escuadrón, +$150 Presupuesto IT)"
						}
					]
				elif GameManager.paper_quest_state == 2:
					dialog_queue = [
						{
							"speaker": "Impresora",
							"portrait": "res://assets/props/printer.png",
							"color": Color("#55efc4"),
							"text": "La impresora está abastecida de papel y trabajando de forma silenciosa. Cartel pegado: 'OPERATIVA - ABASTECIDA POR SISTEMAS'."
						}
					]
				else:
					dialog_queue = [
						{
							"speaker": "Impresora",
							"portrait": "res://assets/props/printer.png",
							"color": Color("#4ade80"),
							"text": printer_neutralized_text + "\n(Nota: La bandeja de papel está completamente vacía. Habla con el Personaje Legalmente Seguro en Finanzas)."
						}
					]
				on_dialog_closed_callback = func():
					player.can_move = true
				player.can_move = false
				_show_next_in_queue()
			else:
				_start_printer_battle()

func _start_printer_battle():
	GameManager.player_saved_position = player.global_position
	GameManager.current_enemy_id = "enemy_printer_boss"
	var spec = {
		"name": "Impresora Maldita",
		"type": "printer",
		"desc": "Tiene atasco de papel, no tiene tóner y huele a quemado.",
		"hp": 420,
		"max_hp": 420,
		"atk": 22,
		"def": 12,
		"exp_reward": 150,
		"texture_path": "res://assets/printer_enemy.png",
		"attacks": [
			"Atasco de Papel en Bandeja 2",
			"Falta Tinta Magenta (Error Crítico)",
			"Ráfaga de Tóner Hirviendo",
			"Sobrecalentamiento del Rodillo Fusor",
			"Error 0x80070057 de Windows"
		]
	}
	GameManager.current_enemy_data = spec
	GameManager.change_scene_instant(get_tree(), "res://scenes/battle.tscn")

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
	
	if data.get("portrait_texture") is Texture2D:
		dialog_portrait.texture = data["portrait_texture"]
		dialog_portrait.visible = true
	elif ResourceLoader.exists(data["portrait"]):
		dialog_portrait.texture = load(data["portrait"])
		dialog_portrait.visible = true
	else:
		dialog_portrait.visible = false
		
	dialog_box.visible = true

func _advance_dialog():
	_show_next_in_queue()

func _unhandled_input(event):
	if modal_control_options.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_control_options()
			get_viewport().set_input_as_handled()
		return
		
	if photo_modal.visible:
		if event.is_action_pressed("ui_cancel") \
		or (event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E)) \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
			_close_photo_modal()
			get_viewport().set_input_as_handled()
		return
		
	if server_login_modal.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_server_login_modal()
			get_viewport().set_input_as_handled()
		return
		
	if shop_modal.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_shop_modal()
			get_viewport().set_input_as_handled()
		return
		
	if demo_modal.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			_close_demo_modal()
			get_viewport().set_input_as_handled()
		return
		
	if dialog_box.visible:
		if event.is_action_pressed("ui_accept") \
		or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E)) \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed):
			get_viewport().set_input_as_handled()
			_advance_dialog()
	else:
		if not current_interactable.is_empty():
			if event.is_action_pressed("ui_accept") \
			or (event is InputEventKey and event.pressed and (event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
				get_viewport().set_input_as_handled()
				_trigger_current_interaction()
				return
				
		# Modo Point and Click: tocar en el suelo para caminar automáticamente
		if GameManager.control_type == "point_and_click" and player and player.can_move:
			if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or (event is InputEventScreenTouch and event.pressed):
				var target_pos = get_global_mouse_position()
				player.navigate_to(target_pos)
				if click_marker:
					click_marker.trigger_at(target_pos)

# --- Tiendita de Nelly & Sistema de Economía ---
func _update_hud_stats():
	var leader = GameManager.get_leader_data()
	hud_hero_name.text = leader["name"]
	hud_hero_role.text = leader["role"]
	hud_stats.text = "Nv. %d  |  HP: %d/%d  |  ATQ: %d  |  EXP: %d/%d" % [
		leader.get("level", 1),
		leader["hp"],
		leader["max_hp"],
		leader["atk"],
		leader.get("exp", 0),
		leader.get("exp_to_next", 50)
	]
	hud_hero_name.modulate = leader["color"]
	_update_hud_budget()

func _update_hud_budget():
	if hud_hero_budget:
		hud_hero_budget.text = "Fondos: $%d" % GameManager.it_budget

func _open_shop_modal():
	player.can_move = false
	shop_modal.visible = true
	shop_feedback_label.text = "¡Bienvenido a la Tiendita de Nelly! Elige consumibles y certificaciones para tu equipo."
	shop_feedback_label.modulate = Color(1.0, 1.0, 1.0)
	_update_shop_ui()

func _close_shop_modal():
	shop_modal.visible = false
	player.can_move = true

func _update_shop_ui():
	shop_budget_label.text = "Fondos IT: $%d" % GameManager.it_budget
	_update_hud_budget()
	
	for child in shop_items_list.get_children():
		child.queue_free()
		
	var item_defs = [
		{"key": "pepsi", "name": "Pepsi Helada", "desc": "Restaura +40 HP a un compañero en combate.", "price": GameManager.item_prices.get("pepsi", 15)},
		{"key": "cafe", "name": "Café de Olla", "desc": "Restaura +75 HP a un compañero en combate.", "price": GameManager.item_prices.get("cafe", 25)},
		{"key": "predator", "name": "Bebida Predator", "desc": "Restaura +120 HP a un compañero en combate.", "price": GameManager.item_prices.get("predator", 35)},
		{"key": "foto", "name": "Foto de Familia", "desc": "Cura +200 HP y elimina estrés a un compañero.", "price": GameManager.item_prices.get("foto", 50)},
		{"key": "dia_libre", "name": "Día Libre (Pase RH)", "desc": "¡Revive a un compañero caído en batalla con 50% HP!", "price": GameManager.item_prices.get("dia_libre", 90)},
		{"key": "certificacion", "name": "Certificación IT (Voucher RH)", "desc": "¡Otorga +160 EXP a todo el escuadrón IT para subir de nivel rápidamente y vencer al Dragón!", "price": GameManager.item_prices.get("certificacion", 45)}
	]
	
	for item in item_defs:
		var panel = PanelContainer.new()
		var pstyle = StyleBoxFlat.new()
		pstyle.bg_color = Color(0.12, 0.15, 0.22, 0.9)
		pstyle.set_corner_radius_all(4)
		panel.add_theme_stylebox_override("panel", pstyle)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var current_qty_str = ""
		if item["key"] == "certificacion":
			var ldr = GameManager.get_leader_data()
			current_qty_str = "Nv. Equipo: %d (EXP: %d/%d)" % [ldr.get("level", 1), ldr.get("exp", 0), ldr.get("exp_to_next", 50)]
		else:
			var bitem = GameManager.battle_items.get(item["key"], {})
			current_qty_str = "Tienes: %d" % bitem.get("count", 0)
			
		var title_label = Label.new()
		title_label.text = "%s ($%d) [%s]" % [item["name"], item["price"], current_qty_str]
		title_label.add_theme_font_size_override("font_size", 12)
		title_label.modulate = Color(1.0, 0.85, 0.3) if item["key"] != "certificacion" else Color(0.4, 1.0, 0.5)
		info_vbox.add_child(title_label)
		
		var desc_label = Label.new()
		desc_label.text = item["desc"]
		desc_label.add_theme_font_size_override("font_size", 10)
		desc_label.modulate = Color(0.75, 0.8, 0.9)
		info_vbox.add_child(desc_label)
		
		hbox.add_child(info_vbox)
		
		var buy_btn = Button.new()
		buy_btn.text = "Comprar ($%d)" % item["price"]
		buy_btn.custom_minimum_size = Vector2(100, 26)
		buy_btn.disabled = (GameManager.it_budget < item["price"])
		var key = item["key"]
		var iname = item["name"]
		var iprice = item["price"]
		buy_btn.pressed.connect(func():
			if GameManager.buy_item(key):
				if key == "certificacion":
					shop_feedback_label.text = "¡Acreditada Certificación IT (+160 EXP al equipo)! Salud y estadísticas aumentadas."
				else:
					shop_feedback_label.text = "¡Compraste 1 %s por $%d!" % [iname, iprice]
				shop_feedback_label.modulate = Color(0.3, 0.9, 0.4)
				_update_hud_stats()
				_update_shop_ui()
			else:
				shop_feedback_label.text = "¡Fondos insuficientes para comprar %s!" % iname
				shop_feedback_label.modulate = Color(1.0, 0.4, 0.4)
		)
		hbox.add_child(buy_btn)
		
		panel.add_child(hbox)
		shop_items_list.add_child(panel)

# --- Sistema de Configuración de Controles ---
func _update_touch_controls_mode():
	var cur = GameManager.control_type
	var mode_info = GameManager.control_modes.get(cur, {})
	var short_name = mode_info.get("short", "D-Pad")
	btn_control_mode.text = "[⚙] " + short_name
	
	if not touch_controls.visible:
		dpad_box.visible = false
		joystick_box.visible = false
	else:
		match cur:
			"dpad":
				dpad_box.visible = true
				joystick_box.visible = false
			"joystick":
				dpad_box.visible = false
				joystick_box.visible = true
			"point_and_click":
				dpad_box.visible = false
				joystick_box.visible = false
				
	_format_overworld_mode_btn(btn_mode_dpad, "dpad", "1. D-Pad Clásico (Botones Fijos)")
	_format_overworld_mode_btn(btn_mode_joystick, "joystick", "2. Análogo Arrastrable (Joystick Táctil)")
	_format_overworld_mode_btn(btn_mode_point_click, "point_and_click", "3. Point and Click (Tocar para Moverse)")

func _format_overworld_mode_btn(btn: Button, mode_key: String, base_title: String):
	var is_selected = (GameManager.control_type == mode_key)
	if is_selected:
		btn.text = "  [✓] " + base_title + "  <ACTIVO>"
		btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.7, 1.0))
	else:
		btn.text = "  [  ] " + base_title
		btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))

func _open_control_options():
	player.can_move = false
	modal_control_options.visible = true
	_update_touch_controls_mode()

func _close_control_options():
	modal_control_options.visible = false
	player.can_move = true
	_update_touch_controls_mode()

func _select_overworld_control_mode(new_mode: String):
	GameManager.set_control_type(new_mode)
	if player:
		player.joystick_vector = Vector2.ZERO
		player.cancel_navigation()
	_update_touch_controls_mode()

# --- Sistema de Compañeros y Gestor de Escuadrón IT ---

func _setup_companions():
	if not companions_root:
		return
	for c in companions_root.get_children():
		c.queue_free()
	companion_nodes.clear()
	
	var office_desk_slots = [
		Vector2(160, 118),
		Vector2(250, 238),
		Vector2(360, 238),
		Vector2(450, 118)
	]
	
	var slot_idx = 0
	for hero_id in GameManager.characters_data.keys():
		if hero_id == GameManager.selected_hero_id:
			continue
		var data = GameManager.characters_data[hero_id]
		var desk_pos = office_desk_slots[slot_idx % office_desk_slots.size()]
		slot_idx += 1
		
		var node = Node2D.new()
		node.name = "Companion_" + hero_id
		node.y_sort_enabled = false
		node.set_meta("hero_id", hero_id)
		node.set_meta("office_pos", desk_pos)
		
		# Sprite
		var spr = Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(data.get("spritesheet_path", "")):
			spr.texture = load(data["spritesheet_path"])
		spr.hframes = 4
		spr.vframes = 12
		spr.frame = 0 # Mirando al frente
		spr.scale = Vector2(0.24, 0.24)
		spr.position = Vector2(0, -10)
		node.add_child(spr)
		
		# NameTag
		var tag = Label.new()
		tag.name = "NameTag"
		tag.text = data["name"]
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.position = Vector2(-40, -34)
		tag.size = Vector2(80, 13)
		tag.add_theme_font_size_override("font_size", 8)
		tag.add_theme_color_override("font_color", data["color"])
		tag.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		tag.add_theme_constant_override("outline_size", 2)
		node.add_child(tag)
		
		# Interact Area
		var area = Area2D.new()
		area.name = "InteractArea"
		area.collision_layer = 4
		area.collision_mask = 1
		var col = CollisionShape2D.new()
		var cshape = CircleShape2D.new()
		cshape.radius = 24.0
		col.shape = cshape
		area.add_child(col)
		
		var c_id = hero_id
		area.body_entered.connect(func(body):
			if body == player:
				_set_interactable("companion_" + c_id)
		)
		area.body_exited.connect(func(body):
			if body == player and current_interactable == ("companion_" + c_id):
				_clear_interactable()
		)
		node.add_child(area)
		
		node.position = desk_pos

		companions_root.add_child(node)
		companion_nodes[hero_id] = node
		
	_update_squad_hud()
	_update_stationed_companions()

func _update_stationed_companions():
	for hero_id in companion_nodes:
		var node = companion_nodes[hero_id]
		node.position = node.get_meta("office_pos")
		var recruited = GameManager.is_hero_in_party(hero_id)
		node.visible = not recruited
		var interaction = node.get_node("InteractArea") as Area2D
		interaction.set_deferred("monitoring", not recruited)
		interaction.collision_layer = 0 if recruited else 4
		if recruited and current_interactable == "companion_" + hero_id:
			_clear_interactable()
		var tag = node.get_node("NameTag") as Label
		tag.text = ("[✓] " if GameManager.is_hero_in_party(hero_id) else "[+] ") + GameManager.characters_data[hero_id]["name"]
		# Recruited heroes join combat without leaving a second visible body on the map.
		node.get_node("Sprite2D").frame = 0


func _interact_with_companion(hero_id: String):
	var data = GameManager.characters_data.get(hero_id, {})
	var c_name = data.get("name", hero_id)
	var portrait = data.get("portrait_path", "")
	var color = data.get("color", Color(1, 1, 1))
	var is_in_party = GameManager.is_hero_in_party(hero_id)
	var p_size = GameManager.party.size()
	
	player.can_move = false
	
	if is_in_party:
		dialog_queue = [
			{
				"speaker": c_name,
				"portrait": portrait,
				"color": color,
				"text": "¡Listo para partir madres y salvar servidores, jefe! ¿Quieres que me quede aquí en la oficina para darle espacio a alguien más o revisar el escuadrón?"
			}
		]
		on_dialog_closed_callback = func():
			_open_squad_modal()
	else:
		var greeting = ""
		match hero_id:
			"javier":
				greeting = "¡Qué onda! ¿Se cayó el sistema o la impresora empezó a morder de nuevo? Dime si nos lanzamos a la batalla."
			"tonazo":
				greeting = "Traigo la USB azul milagrosa y parches listos. ¿Vamos a partirle la madre a esos bugs y fallas?"
			"juan_carlos":
				greeting = "Es hora de meter orden financiero y de sistemas. Nadie factura sin mi visto bueno. ¿Nos vamos?"
			"alejandro":
				greeting = "Resiliencia total, compa. Un verdadero técnico de TI no se rinde ante ninguna pantalla azul. ¿Marchamos?"
			"israel":
				greeting = "He visto pasar 10 generaciones de servidores y gerentes. Dime si nos vamos al frente de batalla."
			_:
				greeting = "¡Listo para apoyar en lo que haga falta en el departamento de TI!"
				
		if p_size < 4:
			dialog_queue = [
				{
					"speaker": c_name,
					"portrait": portrait,
					"color": color,
					"text": greeting + "\n\n[✓] ¡Me uniré a tu escuadrón de aventura!"
				}
			]
			on_dialog_closed_callback = func():
				GameManager.add_hero_to_party(hero_id)
				_update_squad_hud()
				player.can_move = true
		else:
			dialog_queue = [
				{
					"speaker": c_name,
					"portrait": portrait,
					"color": color,
					"text": greeting + "\n\n(Tu escuadrón ya está lleno con 4 miembros. Abriendo el Gestor de Escuadrón para relevar a alguien)."
				}
			]
			on_dialog_closed_callback = func():
				_open_squad_modal()
				
	_show_next_in_queue()

func _open_squad_modal():
	player.can_move = false
	squad_modal.visible = true
	_update_squad_ui()

func _close_squad_modal():
	squad_modal.visible = false
	player.can_move = true
	_update_squad_hud()

func _update_squad_hud():
	if btn_squad:
		btn_squad.text = "[👥] Squad IT (%d/4)" % GameManager.party.size()

func _update_squad_ui():
	squad_slot_count_label.text = "Squad: %d/4" % GameManager.party.size()
	_update_squad_hud()
	
	for child in squad_heroes_list.get_children():
		child.queue_free()
		
	var party_full = (GameManager.party.size() >= 4)
	
	for hero_id in GameManager.characters_data.keys():
		var data = GameManager.characters_data[hero_id]
		var is_leader = (hero_id == GameManager.selected_hero_id)
		var is_in_party = GameManager.is_hero_in_party(hero_id)
		
		var panel = PanelContainer.new()
		var pstyle = StyleBoxFlat.new()
		pstyle.bg_color = Color(0.12, 0.16, 0.24, 0.95)
		pstyle.set_corner_radius_all(6)
		pstyle.set_border_width_all(1)
		pstyle.border_color = data["color"] if is_in_party else Color(0.3, 0.35, 0.45, 0.6)
		panel.add_theme_stylebox_override("panel", pstyle)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		
		# Portrait
		var port_rect = TextureRect.new()
		port_rect.custom_minimum_size = Vector2(36, 36)
		port_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		port_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		port_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(data.get("portrait_path", "")):
			port_rect.texture = load(data["portrait_path"])
		hbox.add_child(port_rect)
		
		# Info VBox
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var title_lbl = Label.new()
		title_lbl.text = "%s - %s" % [data["name"], data["role"]]
		title_lbl.add_theme_font_size_override("font_size", 10)
		title_lbl.modulate = data["color"]
		info_vbox.add_child(title_lbl)
		
		var sub_lbl = Label.new()
		sub_lbl.text = "Nv. %d | HP: %d/%d | ATQ: %d | DEF: %d | \"%s\"" % [data.get("level", 1), data["hp"], data["max_hp"], data["atk"], data.get("def", 15), data.get("title", "")]
		sub_lbl.add_theme_font_size_override("font_size", 8)
		sub_lbl.modulate = Color(0.8, 0.85, 0.95)
		info_vbox.add_child(sub_lbl)
		
		hbox.add_child(info_vbox)
		
		# Action Button
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(110, 24)
		btn.add_theme_font_size_override("font_size", 9)
		
		if is_leader:
			btn.text = "👑 Líder (Fijo)"
			btn.disabled = true
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		elif is_in_party:
			btn.text = "✓ En Escuadrón (Quitar)"
			btn.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
			var h_id = hero_id
			btn.pressed.connect(func():
				GameManager.remove_hero_from_party(h_id)
				_update_squad_ui()
			)
		else:
			if party_full:
				btn.text = "Lleno (4/4)"
				btn.disabled = true
				btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			else:
				btn.text = "+ Reclutar"
				btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
				var h_id = hero_id
				btn.pressed.connect(func():
					GameManager.add_hero_to_party(h_id)
					_update_squad_ui()
				)
		hbox.add_child(btn)
		
		panel.add_child(hbox)
		squad_heroes_list.add_child(panel)

