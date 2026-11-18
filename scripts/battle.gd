extends Control

# Battle System - Chrono Trigger / FF6 Style with Animated 16-Bit Sprites

@onready var enemy_name_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyName
@onready var enemy_hp_bar = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPBar
@onready var enemy_hp_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPText
@onready var enemy_sprite = $MainBox/BattleArena/EnemySide/Center/EnemySprite
@onready var boss_target_arrow = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/BossTargetArrow
@onready var enemy_panel = $MainBox/BattleArena/EnemySide/EnemyPanel

@onready var hero_sprites_container = $MainBox/BattleArena/BattlersArena/HeroSpritesContainer
@onready var party_container = $MainBox/BattleArena/PartySide/PartyContainer
@onready var log_label = $MainBox/LogPanel/Margin/LogLabel

@onready var commands_box = $MainBox/CommandPanel/Margin/HBox/Commands
@onready var btn_attack = $MainBox/CommandPanel/Margin/HBox/Commands/BtnAttack
@onready var btn_skill = $MainBox/CommandPanel/Margin/HBox/Commands/BtnSkill
@onready var btn_item = $MainBox/CommandPanel/Margin/HBox/Commands/BtnItem
@onready var btn_flee = $MainBox/CommandPanel/Margin/HBox/Commands/BtnFlee
@onready var btn_cycle_target = $MainBox/CommandPanel/Margin/HBox/Commands/BtnCycleTarget

@onready var items_menu = $MainBox/CommandPanel/Margin/HBox/ItemsMenu
@onready var btn_item_pepsi = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemPepsi
@onready var btn_item_cafe = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemCafe
@onready var btn_item_predator = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemPredator
@onready var btn_item_foto = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemFoto
@onready var btn_item_dia_libre = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemDiaLibre
@onready var btn_item_back = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemBack

@onready var party_target_menu = $MainBox/CommandPanel/Margin/HBox/PartyTargetMenu
@onready var btn_target_h0 = $MainBox/CommandPanel/Margin/HBox/PartyTargetMenu/BtnTargetH0
@onready var btn_target_h1 = $MainBox/CommandPanel/Margin/HBox/PartyTargetMenu/BtnTargetH1
@onready var btn_target_h2 = $MainBox/CommandPanel/Margin/HBox/PartyTargetMenu/BtnTargetH2
@onready var btn_target_h3 = $MainBox/CommandPanel/Margin/HBox/PartyTargetMenu/BtnTargetH3
@onready var btn_target_cancel = $MainBox/CommandPanel/Margin/HBox/PartyTargetMenu/BtnTargetCancel

@onready var active_hero_portrait = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/ActiveHeroPortrait
@onready var active_hero_name = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/VBox/HeroName
@onready var active_hero_status = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/VBox/HeroStatus

# Enemy Data
var enemy = {}
var enemy_max_hp: int = 420
var enemy_current_hp: int = 420

# Party State
var battle_party: Array = []
var battler_sprites: Array = [] # Sprite2D nodes for each hero
var active_party_index: int = 0
var is_player_turn: bool = true
var is_battle_over: bool = false

# Alineación sin escalonado (Línea recta vertical)
const PARTY_LINE_X: float = 125.0
const PARTY_FORWARD_X: float = 85.0

# Javier mechanic: ataca un turno si y otro no
var javier_can_attack: bool = true
var javier_first_attack: bool = true
var boss_has_red_aura: bool = false

# Printer Minions & Target State (4 CMYK Toners + Boss)
enum TargetType { BOSS, MINION }
var current_target_type: TargetType = TargetType.BOSS
var printer_minions_spawned: bool = false
var selected_minion_index: int = 0
var printer_minions: Array = []
var minion_card_nodes: Array = []
var target_arrow_timer: float = 0.0
var current_item_in_use: String = ""

# Boss Spritesheet Animation State (16-bit Battler)
var boss_atlas: AtlasTexture = null
var boss_anim_timer: float = 0.0
var boss_frame_row: int = 4 # Row 4: postura de combate hacia la derecha
var boss_frame_col: int = 0
var boss_cell_size: int = 128
var boss_is_special_anim: bool = false

func _process(delta):
	target_arrow_timer += delta * 6.0
	var bob = sin(target_arrow_timer) * 2.0
	if boss_target_arrow != null and boss_target_arrow.visible:
		boss_target_arrow.position.y = -14.0 + bob
	for card in minion_card_nodes:
		if card.has("arrow") and card["arrow"].visible:
			card["arrow"].position.y = -2.0 + bob

	if boss_atlas != null and not is_battle_over:
		if not boss_is_special_anim:
			boss_anim_timer += delta
			if boss_anim_timer >= 0.4:
				boss_anim_timer = 0.0
				boss_frame_col = 1 if boss_frame_col == 0 else 0
			boss_atlas.region = Rect2(boss_frame_col * boss_cell_size, boss_frame_row * boss_cell_size, boss_cell_size, boss_cell_size)

func _ready():
	get_viewport().canvas_transform = Transform2D.IDENTITY
	$Camera2D.make_current()
	setup_battle()
	btn_attack.pressed.connect(_on_attack_pressed)
	btn_skill.pressed.connect(_on_skill_pressed)
	btn_item.pressed.connect(_on_item_pressed)
	btn_flee.pressed.connect(_on_flee_pressed)
	
	btn_item_pepsi.pressed.connect(func(): _prepare_item_target("pepsi"))
	btn_item_cafe.pressed.connect(func(): _prepare_item_target("cafe"))
	btn_item_predator.pressed.connect(func(): _prepare_item_target("predator"))
	btn_item_foto.pressed.connect(func(): _prepare_item_target("foto"))
	btn_item_dia_libre.pressed.connect(func(): _prepare_item_target("dia_libre"))
	btn_item_back.pressed.connect(_on_item_back_pressed)
	
	btn_target_h0.pressed.connect(func(): _apply_item_to_target(0))
	btn_target_h1.pressed.connect(func(): _apply_item_to_target(1))
	btn_target_h2.pressed.connect(func(): _apply_item_to_target(2))
	btn_target_h3.pressed.connect(func(): _apply_item_to_target(3))
	btn_target_cancel.pressed.connect(_on_target_cancel_pressed)
	
	btn_cycle_target.pressed.connect(cycle_next_target)
	enemy_panel.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			select_boss_target()
	)
	enemy_sprite.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			select_boss_target()
	)
	GameManager.preload_scene("res://scenes/overworld.tscn")

func setup_battle():
	javier_first_attack = true
	printer_minions_spawned = false
	current_target_type = TargetType.BOSS
	selected_minion_index = 0
	if boss_target_arrow:
		boss_target_arrow.visible = false
	if btn_cycle_target:
		btn_cycle_target.visible = false
	if btn_flee:
		btn_flee.visible = true
	printer_minions.clear()
	minion_card_nodes.clear()
	if has_node("MainBox/BattleArena/EnemySide/MinionsContainer"):
		var mc = $MainBox/BattleArena/EnemySide/MinionsContainer
		mc.visible = false
		for c in mc.get_children():
			c.queue_free()
	# Cargar enemigo
	if GameManager.current_enemy_data.is_empty():
		enemy = {
			"name": "Impresora Maldita",
			"type": "printer",
			"hp": 420,
			"max_hp": 420,
			"atk": 22,
			"def": 12,
			"texture_path": "res://assets/printer_enemy.png",
			"attacks": [
				"Atasco de Papel en Bandeja 2",
				"Falta Tinta Magenta (Error Crítico)",
				"Ráfaga de Tóner Hirviendo",
				"Sobrecalentamiento del Rodillo Fusor",
				"Error 0x80070057 de Windows"
			]
		}
	else:
		enemy = GameManager.current_enemy_data
		
	enemy_max_hp = enemy.get("max_hp", 420)
	enemy_current_hp = enemy.get("hp", enemy_max_hp)
	enemy_name_label.text = enemy.get("name", "Enemigo")
	boss_has_red_aura = false
	boss_atlas = null
	
	if enemy.get("type") == "dragon_boss" or enemy.has("spritesheet_path"):
		$Background.color = Color(0.03, 0.01, 0.05, 1.0)
		enemy_name_label.text = "[JEFE] El Señor del Dragón"
		enemy_name_label.modulate = Color(1.0, 0.25, 0.25)
		
		var sheet_path = enemy.get("spritesheet_path", "res://assets/characters/dragon_boss_battle_spritesheet.png")
		if ResourceLoader.exists(sheet_path):
			boss_atlas = AtlasTexture.new()
			boss_atlas.atlas = load(sheet_path)
			# Spritesheet 8 columnas x 7 filas (1024x896), cada celda 128x128
			boss_cell_size = 128
			boss_frame_row = 4 # Row 4: postura de combate hacia los héroes
			boss_frame_col = 0
			boss_is_special_anim = false
			boss_atlas.region = Rect2(0, 4 * 128, 128, 128)
			enemy_sprite.texture = boss_atlas
			enemy_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			enemy_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			enemy_sprite.custom_minimum_size = Vector2(140, 140)
	elif enemy.get("type") == "password_boss":
		$Background.color = Color(0.01, 0.04, 0.1, 1.0)
		enemy_name_label.text = "[JEFE SITE] " + enemy.get("name", "Contraseña Olvidada")
		enemy_name_label.modulate = Color(0.3, 0.85, 1.0)
		if ResourceLoader.exists(enemy.get("texture_path", "")):
			enemy_sprite.texture = load(enemy.get("texture_path"))
		enemy_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		enemy_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		enemy_sprite.custom_minimum_size = Vector2(160, 150)
	else:
		if ResourceLoader.exists(enemy.get("texture_path", "")):
			enemy_sprite.texture = load(enemy.get("texture_path"))
		enemy_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		enemy_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	update_enemy_ui()
	
	# Cargar party desde GameManager
	battle_party = GameManager.party.duplicate(true)
	create_battler_sprites()
	render_party_ui()
	
	if enemy.get("type") == "dragon_boss":
		set_log("¡SOMBRAS DEL PASADO! ¡El Señor del Dragón exige su dragón!")
	elif enemy.get("type") == "password_boss":
		set_log("¡FALLA DE ENRUTAMIENTO! ¡Nadie se sabe la contraseña del Servidor 117!")
	else:
		set_log("¡Un " + enemy.get("name", "problema") + " salvaje ha detenido las operaciones!")
	start_turn()

func create_battler_sprites():
	for c in hero_sprites_container.get_children():
		c.queue_free()
	battler_sprites.clear()
	
	# Alineación en línea vertical recta (sin escalonado)
	var start_y = 22.0
	var step_y = 42.0
	
	for i in range(battle_party.size()):
		var member = battle_party[i]
		var spr = Sprite2D.new()
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(member.get("spritesheet_path", "")):
			spr.texture = load(member["spritesheet_path"])
		spr.hframes = 4
		spr.vframes = 12
		spr.scale = member.get("battle_scale", Vector2(0.32, 0.32))
		spr.position = Vector2(PARTY_LINE_X, start_y + i * step_y)
		# Row 2 (mirando a la izquierda hacia el enemigo)
		spr.frame = 2 * 4 + 0
		hero_sprites_container.add_child(spr)
		battler_sprites.append(spr)

func update_enemy_ui():
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = max(0, enemy_current_hp)
	enemy_hp_label.text = "%d / %d HP" % [max(0, enemy_current_hp), enemy_max_hp]

func render_party_ui():
	for c in party_container.get_children():
		c.queue_free()
		
	for i in range(battle_party.size()):
		var member = battle_party[i]
		var card = PanelContainer.new()
		var hb = HBoxContainer.new()
		hb.add_theme_constant_override("separation", 6)
		
		# Mini portrait
		var port = TextureRect.new()
		port.custom_minimum_size = Vector2(24, 24)
		port.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		port.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		port.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(member.get("portrait_path", "")):
			port.texture = load(member["portrait_path"])
		hb.add_child(port)
		
		var vb = VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.add_theme_constant_override("separation", 1)
		
		var name_lbl = Label.new()
		name_lbl.text = "%s [Nv. %d]" % [member["name"], member.get("level", 1)]
		name_lbl.modulate = member["color"]
		name_lbl.add_theme_font_size_override("font_size", 9)
		vb.add_child(name_lbl)
		
		var hp_bar = ProgressBar.new()
		hp_bar.max_value = member["max_hp"]
		hp_bar.value = max(0, member["hp"])
		hp_bar.custom_minimum_size = Vector2(100, 7)
		hp_bar.show_percentage = false
		vb.add_child(hp_bar)
		
		var hp_txt = Label.new()
		hp_txt.text = "%d/%d HP" % [max(0, member["hp"]), member["max_hp"]]
		hp_txt.add_theme_font_size_override("font_size", 8)
		vb.add_child(hp_txt)
		
		hb.add_child(vb)
		card.add_child(hb)
		party_container.add_child(card)
		
		# Actualizar animación de desmayado si está muerto
		if i < battler_sprites.size():
			if member["hp"] <= 0:
				battler_sprites[i].frame = 11 * 4 + 3 # Desmayado en el piso

func get_active_member() -> Dictionary:
	return battle_party[active_party_index]

func get_active_sprite() -> Sprite2D:
	if active_party_index < battler_sprites.size():
		return battler_sprites[active_party_index]
	return null

func start_turn():
	if is_battle_over:
		return
		
	var member = get_active_member()
	if member["hp"] <= 0:
		advance_to_next_hero()
		return
		
	is_player_turn = true
	commands_box.visible = true
	items_menu.visible = false
	
	active_hero_name.text = member["name"].to_upper()
	active_hero_name.modulate = member["color"]
	
	if ResourceLoader.exists(member.get("portrait_path", "")):
		active_hero_portrait.texture = load(member["portrait_path"])
		
	# Resaltar sprite activo (dar un paso al frente en línea recta)
	var spr = get_active_sprite()
	if spr:
		spr.position.x = PARTY_FORWARD_X
		spr.modulate = Color(1.2, 1.2, 1.2)
	
	# REGLA CLAVE DE JAVIER:
	if member["name"] == "Javier":
		if javier_can_attack:
			active_hero_status.text = "¡LISTO PARA ATACAR! (Turno Sí)"
			active_hero_status.modulate = Color(0.4, 1.0, 0.4)
			btn_attack.disabled = false
			btn_attack.text = "[ATQ] Atacar"
			if spr: spr.frame = 2 * 4 + 0 # Listo mirando al enemigo
		else:
			active_hero_status.text = "[Zz] Tomando Café & Memes (Turno No)"
			active_hero_status.modulate = Color(1.0, 0.8, 0.2)
			btn_attack.disabled = false
			btn_attack.text = "[CAFE] Procrastinar / Descansar"
			if spr: spr.frame = 8 * 4 + 0 # Mirando al frente descansando
	else:
		active_hero_status.text = "Listo para actuar"
		active_hero_status.modulate = Color(1, 1, 1)
		btn_attack.disabled = false
		btn_attack.text = "[ATQ] Atacar"
		if spr: spr.frame = 2 * 4 + 0

func reset_active_sprite_position():
	var spr = get_active_sprite()
	if spr:
		spr.position.x = PARTY_LINE_X
		spr.modulate = Color.WHITE

func advance_to_next_hero():
	reset_active_sprite_position()
	var attempts = 0
	while attempts < battle_party.size():
		active_party_index = (active_party_index + 1) % battle_party.size()
		attempts += 1
		if battle_party[active_party_index]["hp"] > 0:
			break
			
	if battle_party[active_party_index]["hp"] > 0:
		start_turn()
	else:
		game_over()

func _on_attack_pressed():
	if not is_player_turn or is_battle_over:
		return
		
	var member = get_active_member()
	var spr = get_active_sprite()
	
	# CASO JAVIER: "atacara un turno si y otro no"
	if member["name"] == "Javier":
		if not javier_can_attack:
			javier_can_attack = true # el siguiente turno SÍ podrá
			set_log("[CAFE] ¡Javier está procrastinando y tomando café! Javier recarga energías para el próximo turno.")
			member["hp"] = min(member["max_hp"], member["hp"] + 20)
			render_party_ui()
			end_hero_action()
			return
		else:
			javier_can_attack = false # el siguiente turno descansará
			var dmg = member["atk"] + randi_range(6, 14)
			play_attack_anim(spr)
			var atk_msg = ""
			if javier_first_attack:
				javier_first_attack = false
				atk_msg = "Javier grita: '¡Esto es por no dejarme disfrutar de este atardecer tequilero!'"
			else:
				atk_msg = "[ESP] ¡Javier le propinó un REINICIO FORZADO al enemigo!"
			deal_damage_to_enemy(dmg, atk_msg)
			return
			
	# Otros miembros
	var dmg = member["atk"] + randi_range(-3, 5)
	play_attack_anim(spr)
	deal_damage_to_enemy(dmg, "¡%s lanzó un ataque certero!" % member["name"])

func _on_skill_pressed():
	if not is_player_turn or is_battle_over:
		return
	var member = get_active_member()
	var skill_name = member.get("special_move_name", "Habilidad Especial")
	var spr = get_active_sprite()
	
	if member["name"] == "Javier":
		if not javier_can_attack:
			set_log("Javier bosteza: 'No puedo usar skills, estoy viendo memes'.")
			javier_can_attack = true
			end_hero_action()
			return
		else:
			javier_can_attack = false
			var dmg = int(member["atk"] * 1.6)
			play_attack_anim(spr)
			var atk_msg = ""
			if javier_first_attack:
				javier_first_attack = false
				atk_msg = "Javier grita: '¡Esto es por no dejarme disfrutar de este atardecer tequilero!' (%s)" % skill_name
			else:
				atk_msg = "[BOM] ¡Javier usó %s! ¡El rack tembló!" % skill_name
			deal_damage_to_enemy(dmg, atk_msg)
			return
			
	if member["name"] == "Juan Carlos" and has_alive_minions():
		var aoe_dmg = int(member["atk"] * 1.3)
		play_attack_anim(spr)
		deal_aoe_damage_to_minions(aoe_dmg, "[BOM] ¡Juan Carlos sobrecargó la red con DDoS! ¡Impactó a todos los cartuchos de tóner!")
		return
		
	var dmg = int(member["atk"] * 1.4)
	play_attack_anim(spr)
	deal_damage_to_enemy(dmg, "[*] ¡%s usó %s!" % [member["name"], skill_name])

# --- MENÚ DE ITEMS DE CURACIÓN ---
func _on_item_pressed():
	if not is_player_turn or is_battle_over:
		return
	commands_box.visible = false
	items_menu.visible = true
	update_items_ui()
	set_log("Selecciona un ítem de tu inventario.")

func update_items_ui():
	var pepsi = GameManager.battle_items["pepsi"]
	var cafe = GameManager.battle_items["cafe"]
	var predator = GameManager.battle_items["predator"]
	var foto = GameManager.battle_items["foto"]
	var dia_libre = GameManager.battle_items["dia_libre"]
	
	btn_item_pepsi.text = "Pepsi (+20/50) x%d" % pepsi["count"]
	btn_item_pepsi.disabled = pepsi["count"] <= 0
	
	btn_item_cafe.text = "Café (+50/0) x%d" % cafe["count"]
	btn_item_cafe.disabled = cafe["count"] <= 0
	
	btn_item_predator.text = "Predator (+50/100) x%d" % predator["count"]
	btn_item_predator.disabled = predator["count"] <= 0
	
	btn_item_foto.text = "Foto Limpieza x%d" % foto["count"]
	btn_item_foto.disabled = foto["count"] <= 0
	
	btn_item_dia_libre.text = "Día Libre x%d" % dia_libre["count"]
	btn_item_dia_libre.disabled = dia_libre["count"] <= 0

func _prepare_item_target(item_key: String):
	if not is_player_turn or is_battle_over:
		return
	var item = GameManager.battle_items.get(item_key, {"count": 0, "name": "Item"})
	if item["count"] <= 0:
		set_log("[!] ¡Ya no te quedan unidades de %s!" % item["name"])
		return
	current_item_in_use = item_key
	items_menu.visible = false
	party_target_menu.visible = true
	var target_btns = [btn_target_h0, btn_target_h1, btn_target_h2, btn_target_h3]
	for i in range(target_btns.size()):
		var btn = target_btns[i]
		if i < battle_party.size():
			btn.visible = true
			var mem = battle_party[i]
			if mem["hp"] <= 0:
				btn.text = "[KO] %s" % mem["name"]
				btn.modulate = Color(1.0, 0.4, 0.4)
			else:
				btn.text = "%s (%d/%d HP)" % [mem["name"], mem["hp"], mem["max_hp"]]
				btn.modulate = Color.WHITE
		else:
			btn.visible = false
	set_log("[?] ¿En qué compañero deseas usar '%s'?" % item["name"])

func _on_target_cancel_pressed():
	party_target_menu.visible = false
	items_menu.visible = true
	current_item_in_use = ""
	update_items_ui()
	set_log("Selecciona un ítem o pulsa Volver.")

func _apply_item_to_target(target_idx: int):
	if not is_player_turn or is_battle_over:
		return
	if target_idx >= battle_party.size() or current_item_in_use.is_empty():
		return
	var item = GameManager.battle_items[current_item_in_use]
	if item["count"] <= 0:
		set_log("[!] ¡No quedan unidades de %s!" % item["name"])
		party_target_menu.visible = false
		commands_box.visible = true
		return
		
	var mem = battle_party[target_idx]
	if current_item_in_use == "dia_libre":
		item["count"] -= 1
		party_target_menu.visible = false
		commands_box.visible = true
		var was_dead = mem["hp"] <= 0
		if was_dead:
			mem["hp"] = max(70, int(mem["max_hp"] * 0.5))
			if target_idx < battler_sprites.size():
				var spr = battler_sprites[target_idx]
				spr.frame = 2 * 4 + 0 # Volver a ponerse de pie
				var tween = create_tween()
				tween.tween_property(spr, "modulate", Color(0.2, 2.2, 0.5), 0.25)
				tween.tween_property(spr, "modulate", Color.WHITE, 0.25)
			set_log("[¡REVIVIDO!] ¡RH concedió un DÍA LIBRE a %s! Regresa con %d HP." % [mem["name"], mem["hp"]])
		else:
			var heal = 70
			mem["hp"] = min(mem["max_hp"], mem["hp"] + heal)
			if target_idx < battler_sprites.size():
				var spr = battler_sprites[target_idx]
				var tween = create_tween()
				tween.tween_property(spr, "modulate", Color(0.2, 2.2, 0.5), 0.2)
				tween.tween_property(spr, "modulate", Color.WHITE, 0.2)
			set_log("[+] ¡%s se tomó su DÍA LIBRE y recuperó salud (+%d HP)!" % [mem["name"], heal])
		render_party_ui()
		end_hero_action()
		return

	# Items de curación normales (no aplican si el compañero está desmayado)
	if mem["hp"] <= 0:
		set_log("[!] ¡%s está desmayado! Usa un 'Día Libre' para revivirlo." % mem["name"])
		return

	item["count"] -= 1
	party_target_menu.visible = false
	commands_box.visible = true
	var heal_amt = get_item_heal_amount(current_item_in_use, mem)
	mem["hp"] = min(mem["max_hp"], mem["hp"] + heal_amt)
	if target_idx < battler_sprites.size():
		var spr = battler_sprites[target_idx]
		var tween = create_tween()
		tween.tween_property(spr, "modulate", Color(0.3, 1.8, 0.4), 0.15)
		tween.tween_property(spr, "modulate", Color.WHITE, 0.15)
	render_party_ui()
	var msg = get_item_log_message(current_item_in_use, mem, heal_amt)
	set_log(msg)
	end_hero_action()

func _on_item_back_pressed():
	items_menu.visible = false
	commands_box.visible = true
	set_log("¡Elige una acción para tu turno!")

func get_item_heal_amount(item_key: String, member: Dictionary) -> int:
	var name_lower = member.get("name", "").to_lower()
	match item_key:
		"pepsi":
			# Cura 20 puntos en todos, en Alejandro cura 50
			if "alejandro" in name_lower or "alex" in name_lower:
				return 50
			return 20
		"cafe":
			# Cura 50 en todos menos en Alex y en Javier (cura 0)
			if "alejandro" in name_lower or "alex" in name_lower or "javier" in name_lower:
				return 0
			return 50
		"predator":
			# Cura 50 a todos, a Toño 100
			if "toño" in name_lower or "toñazo" in name_lower:
				return 100
			return 50
		"foto":
			# Foto de la señora de la limpieza cura 0 a todos menos a Juan Carlos (cura 100)
			if "juan" in name_lower:
				return 100
			return 0
		_:
			return 20

func get_item_log_message(item_key: String, member: Dictionary, heal: int) -> String:
	var name = member["name"]
	var name_lower = name.to_lower()
	match item_key:
		"pepsi":
			if "alejandro" in name_lower or "alex" in name_lower:
				return "[+] ¡%s abrió una lata de Pepsi bien fría y su odio al mundo se convirtió en salud (+50 HP)!" % name
			return "[+] ¡%s se tomó una lata de Pepsi (+%d HP)!" % [name, heal]
		"cafe":
			if "alejandro" in name_lower or "alex" in name_lower:
				return "[!] A %s el café no le hace efecto, ¡él vive a base de Pepsi (+0 HP)!" % name
			elif "javier" in name_lower:
				return "[!] %s ya tiene tolerancia sobrehumana al café, necesita algo más fuerte (+0 HP)." % name
			return "[+] ¡%s se tomó una buena taza de café caliente (+%d HP)!" % [name, heal]
		"predator":
			if "toño" in name_lower or "toñazo" in name_lower:
				return "[+] ¡A %s el Predator le activó el modo turbo junto a su USB azul milagrosa (+100 HP)!" % name
			return "[+] ¡%s se tomó una lata de Predator (+%d HP)!" % [name, heal]
		"foto":
			if "juan" in name_lower:
				return "[+] ¡Juan Carlos contempla con devoción la foto de la señora de la limpieza y siente una paz absoluta (+100 HP)!" % name
			return "[!] %s miró la foto de la señora de la limpieza con respeto, pero no le curó nada (+0 HP)." % name
		_:
			return "[+] ¡%s usó el item (+%d HP)!" % [name, heal]

func _use_item(item_key: String):
	if not is_player_turn or is_battle_over:
		return
	var item = GameManager.battle_items[item_key]
	if item["count"] <= 0:
		set_log("[!] ¡Ya no quedan unidades de %s!" % item["name"])
		return
		
	item["count"] -= 1
	var member = get_active_member()
	var heal_amt = get_item_heal_amount(item_key, member)
	if heal_amt > 0:
		member["hp"] = min(member["max_hp"], member["hp"] + heal_amt)
		render_party_ui()
		# Destello verde en sprite
		var spr = get_active_sprite()
		if spr:
			var tween = create_tween()
			tween.tween_property(spr, "modulate", Color(0.3, 1.8, 0.4), 0.15)
			tween.tween_property(spr, "modulate", Color.WHITE, 0.15)
	else:
		render_party_ui()
		
	var msg = get_item_log_message(item_key, member, heal_amt)
	set_log(msg)
	
	items_menu.visible = false
	commands_box.visible = true
	end_hero_action()

func _on_flee_pressed():
	set_log("¡El equipo de IT huyó al comedor a comer donas!")
	is_battle_over = true
	await get_tree().create_timer(1.2).timeout
	GameManager.change_scene_instant(get_tree(), "res://scenes/overworld.tscn")

func play_attack_anim(spr: Sprite2D):
	if not spr:
		return
	# Animación de ataque (Row 9: slash effect)
	var original_x = spr.position.x
	var tween = create_tween()
	tween.tween_property(spr, "position:x", original_x - 20.0, 0.1)
	tween.tween_callback(func(): spr.frame = 9 * 4 + 1)
	tween.tween_interval(0.1)
	tween.tween_callback(func(): spr.frame = 9 * 4 + 2) # Frame con efecto cortante azul
	tween.tween_interval(0.15)
	tween.tween_property(spr, "position:x", original_x, 0.1)
	tween.tween_callback(func(): spr.frame = 2 * 4 + 0)

func has_alive_minions() -> bool:
	if not printer_minions_spawned:
		return false
	for m in printer_minions:
		if m.get("alive", false):
			return true
	return false

func select_boss_target():
	current_target_type = TargetType.BOSS
	update_target_selection_ui()
	set_log("[🎯] Objetivo fijado: Impresora Maldita.")

func select_minion_target(idx: int):
	if idx >= 0 and idx < printer_minions.size() and printer_minions[idx]["alive"]:
		current_target_type = TargetType.MINION
		selected_minion_index = idx
		update_target_selection_ui()
		set_log("[🎯] Objetivo fijado: %s." % printer_minions[idx]["name"])

func cycle_next_target():
	var valid_targets = []
	if enemy_current_hp > 0:
		valid_targets.append({"type": TargetType.BOSS, "index": -1})
	for i in range(printer_minions.size()):
		if printer_minions[i]["alive"]:
			valid_targets.append({"type": TargetType.MINION, "index": i})
	
	if valid_targets.size() <= 1:
		return
		
	var cur_idx = -1
	for i in range(valid_targets.size()):
		var vt = valid_targets[i]
		if vt["type"] == current_target_type:
			if vt["type"] == TargetType.BOSS or vt["index"] == selected_minion_index:
				cur_idx = i
				break
				
	var next_idx = (cur_idx + 1) % valid_targets.size()
	var nxt = valid_targets[next_idx]
	current_target_type = nxt["type"]
	if current_target_type == TargetType.MINION:
		selected_minion_index = nxt["index"]
		set_log("[🎯] Objetivo: %s." % printer_minions[selected_minion_index]["name"])
	else:
		set_log("[🎯] Objetivo: Impresora Maldita.")
	update_target_selection_ui()

func update_target_selection_ui():
	if current_target_type == TargetType.BOSS:
		if boss_target_arrow:
			boss_target_arrow.visible = (printer_minions_spawned and has_alive_minions())
		if btn_cycle_target:
			btn_cycle_target.text = "[🎯] Obj: Impresora ▼"
	else:
		if boss_target_arrow:
			boss_target_arrow.visible = false
		if btn_cycle_target:
			btn_cycle_target.text = "[🎯] Obj: %s ▼" % printer_minions[selected_minion_index]["short"]
	
	update_minions_ui()

func spawn_printer_minions():
	printer_minions_spawned = true
	current_target_type = TargetType.MINION
	selected_minion_index = 0
	if btn_cycle_target:
		btn_cycle_target.visible = true
	if btn_flee:
		btn_flee.visible = false
	printer_minions = [
		{
			"id": "toner_k",
			"name": "Tóner K (Negro)",
			"short": "Negro",
			"hp": 35,
			"max_hp": 35,
			"atk": 8,
			"def": 3,
			"color": Color("#94a3b8"),
			"texture_path": "res://assets/enemies/minion_toner_k.png",
			"atk_name": "Polvo de Tóner Negro",
			"alive": true
		},
		{
			"id": "toner_c",
			"name": "Tóner C (Cyan)",
			"short": "Cyan",
			"hp": 28,
			"max_hp": 28,
			"atk": 7,
			"def": 2,
			"color": Color("#38bdf8"),
			"texture_path": "res://assets/enemies/minion_toner_c.png",
			"atk_name": "Chorro de Tinta Cyan",
			"alive": true
		},
		{
			"id": "toner_m",
			"name": "Tóner M (Magenta)",
			"short": "Magenta",
			"hp": 28,
			"max_hp": 28,
			"atk": 7,
			"def": 2,
			"color": Color("#f43f5e"),
			"texture_path": "res://assets/enemies/minion_toner_m.png",
			"atk_name": "Tinta Magenta Hirviente",
			"alive": true
		},
		{
			"id": "toner_y",
			"name": "Tóner Y (Amarillo)",
			"short": "Amarillo",
			"hp": 28,
			"max_hp": 28,
			"atk": 7,
			"def": 2,
			"color": Color("#facc15"),
			"texture_path": "res://assets/enemies/minion_toner_y.png",
			"atk_name": "Pigmento Amarillo a Presión",
			"alive": true
		}
	]
	render_minions_ui()
	update_target_selection_ui()
	set_log("[!] ¡La Impresora eyecta 4 Tóners! Elige tu objetivo con la flechita.")

func render_minions_ui():
	if not has_node("MainBox/BattleArena/EnemySide/MinionsContainer"):
		return
	var container = $MainBox/BattleArena/EnemySide/MinionsContainer
	container.visible = true
	for c in container.get_children():
		c.queue_free()
	minion_card_nodes.clear()
	
	for i in range(printer_minions.size()):
		var m = printer_minions[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(38, 70)
		btn.focus_mode = Control.FOCUS_NONE
		btn.flat = true
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var arrow_lbl = Label.new()
		arrow_lbl.text = "▼"
		arrow_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arrow_lbl.add_theme_font_size_override("font_size", 9)
		arrow_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.1))
		arrow_lbl.visible = (current_target_type == TargetType.MINION and i == selected_minion_index)
		vbox.add_child(arrow_lbl)
		
		var tag = Label.new()
		tag.text = m["short"]
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.add_theme_font_size_override("font_size", 7)
		tag.add_theme_color_override("font_color", Color.YELLOW if (current_target_type == TargetType.MINION and i == selected_minion_index) else m["color"])
		vbox.add_child(tag)
		
		var img = TextureRect.new()
		img.custom_minimum_size = Vector2(22, 44)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if ResourceLoader.exists(m["texture_path"]):
			img.texture = load(m["texture_path"])
		vbox.add_child(img)
		
		var hp_bar = ProgressBar.new()
		hp_bar.custom_minimum_size = Vector2(34, 4)
		hp_bar.max_value = m["max_hp"]
		hp_bar.value = m["hp"]
		hp_bar.show_percentage = false
		vbox.add_child(hp_bar)
		
		var hp_txt = Label.new()
		hp_txt.text = "%d HP" % m["hp"]
		hp_txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_txt.add_theme_font_size_override("font_size", 7)
		vbox.add_child(hp_txt)
		
		btn.add_child(vbox)
		var minion_idx = i
		btn.pressed.connect(func():
			select_minion_target(minion_idx)
		)
		container.add_child(btn)
		minion_card_nodes.append({
			"btn": btn,
			"arrow": arrow_lbl,
			"tag": tag,
			"img": img,
			"hp_bar": hp_bar,
			"hp_txt": hp_txt
		})

func update_minions_ui():
	for i in range(printer_minions.size()):
		var m = printer_minions[i]
		if i < minion_card_nodes.size():
			var card = minion_card_nodes[i]
			card["hp_bar"].value = m["hp"]
			card["hp_txt"].text = "%d HP" % m["hp"]
			var is_selected = (current_target_type == TargetType.MINION and i == selected_minion_index)
			if card.has("arrow"):
				card["arrow"].visible = is_selected and m["alive"]
			if not m["alive"]:
				card["btn"].modulate = Color(0.4, 0.4, 0.4, 0.3)
				card["tag"].text = "[X]"
				card["tag"].add_theme_color_override("font_color", Color.GRAY)
			else:
				card["btn"].modulate = Color.WHITE
				card["tag"].text = m["short"]
				card["tag"].add_theme_color_override("font_color", Color.YELLOW if is_selected else m["color"])

func deal_aoe_damage_to_minions(damage: int, message: String):
	set_log("%s (%d de daño en área)." % [message, damage])
	for i in range(printer_minions.size()):
		var m = printer_minions[i]
		if m["alive"]:
			m["hp"] = max(0, m["hp"] - damage)
			if i < minion_card_nodes.size():
				var spr_node = minion_card_nodes[i]["img"]
				var tw = create_tween()
				tw.tween_property(spr_node, "modulate", Color.CYAN, 0.1)
				tw.tween_property(spr_node, "modulate", Color.WHITE, 0.1)
			if m["hp"] <= 0:
				m["alive"] = false
				set_log("¡El %s explotó por sobrecarga!" % m["name"])
	update_minions_ui()
	if not has_alive_minions():
		set_log("[!] ¡TODOS LOS CARTUCHOS NEUTRALIZADOS! ¡La Impresora Maldita quedó vulnerable!")
		select_boss_target()
	else:
		cycle_next_target()
	end_hero_action()

func deal_damage_to_enemy(damage: int, message: String):
	# Si se tiene como objetivo a un minion con vida:
	if current_target_type == TargetType.MINION and has_alive_minions():
		var m = printer_minions[selected_minion_index]
		m["hp"] = max(0, m["hp"] - damage)
		update_minions_ui()
		set_log("%s -> Impactó a %s (%d daño)." % [message, m["name"], damage])
		
		if selected_minion_index < minion_card_nodes.size():
			var spr_node = minion_card_nodes[selected_minion_index]["img"]
			var tw = create_tween()
			tw.tween_property(spr_node, "modulate", Color.RED, 0.1)
			tw.tween_property(spr_node, "modulate", Color.WHITE, 0.1)
			
		if m["hp"] <= 0:
			m["alive"] = false
			update_minions_ui()
			set_log("¡El %s explotó y se quedó sin tinta!" % m["name"])
			if not has_alive_minions():
				set_log("[!] ¡TODOS LOS CARTUCHOS NEUTRALIZADOS! ¡La Impresora Maldita quedó vulnerable!")
				select_boss_target()
			else:
				cycle_next_target()
		end_hero_action()
		return

	# Daño normal al enemigo principal
	enemy_current_hp -= damage
	update_enemy_ui()
	set_log("%s (%d de daño)." % [message, damage])
	
	# Efecto visual y cambio de pose al recibir daño
	if boss_atlas != null and enemy_current_hp > 0 and not boss_is_special_anim:
		boss_frame_row = 5 # Postura de impacto / dolor
		boss_frame_col = 0
		boss_atlas.region = Rect2(0, 5 * boss_cell_size, boss_cell_size, boss_cell_size)
		get_tree().create_timer(0.35).timeout.connect(func():
			if boss_atlas != null and not is_battle_over and not boss_is_special_anim:
				boss_frame_row = 4
				boss_frame_col = 0
				boss_atlas.region = Rect2(0, 4 * boss_cell_size, boss_cell_size, boss_cell_size)
		)
		
	var tween = create_tween()
	tween.tween_property(enemy_sprite, "modulate", Color(3.0, 0.2, 0.2), 0.1)
	tween.tween_property(enemy_sprite, "modulate", Color.WHITE if not boss_has_red_aura else Color(2.5, 0.4, 0.4), 0.1)
	
	# Chequeo de minions de la impresora al bajar del 10% (<= 45 HP de 420):
	if enemy.get("type") == "printer" and enemy_current_hp <= 45 and not printer_minions_spawned:
		if enemy_current_hp <= 0:
			enemy_current_hp = 18 # No muere antes de sacar sus minions
		update_enemy_ui()
		spawn_printer_minions()
		end_hero_action()
		return
		
	if enemy_current_hp <= 0:
		enemy_defeated()
	else:
		end_hero_action()

func end_hero_action():
	is_player_turn = false
	reset_active_sprite_position()
	await get_tree().create_timer(0.8).timeout
	if is_battle_over:
		return
	enemy_turn()

func play_dragon_special_anim(target_name: String) -> void:
	boss_is_special_anim = true
	boss_frame_row = 4
	
	# Frame 4: Carga energía cian en la mano
	boss_frame_col = 4
	boss_atlas.region = Rect2(4 * boss_cell_size, 4 * boss_cell_size, boss_cell_size, boss_cell_size)
	var tween_charge = create_tween()
	tween_charge.tween_property(enemy_sprite, "modulate", Color(0.2, 2.5, 3.5), 0.25)
	set_log("[¡ALERTA MÁXIMA!] ¡El Señor del Dragón acumula una inmensa energía mística cian en sus manos...!")
	await get_tree().create_timer(0.35).timeout
	
	# Frame 5: Proyecta la cabeza del dragón
	boss_frame_col = 5
	boss_atlas.region = Rect2(5 * boss_cell_size, 4 * boss_cell_size, boss_cell_size, boss_cell_size)
	set_log("¡El Señor del Dragón ruge a todo pulmón: '¡¿DÓNDE ESTÁ MI DRAGÓN IMPRESO EN 3D?!'!")
	await get_tree().create_timer(0.35).timeout
	
	# Frame 6: ¡EL DRAGÓN CIAN COMPLETO SURCA LA SALA HACIA LOS HÉROES!
	boss_frame_col = 6
	boss_atlas.region = Rect2(6 * boss_cell_size, 4 * boss_cell_size, boss_cell_size, boss_cell_size)
	var cam = $Camera2D
	var orig_cam_offset = cam.offset
	var tween_shake = create_tween()
	for s in range(5):
		tween_shake.tween_property(cam, "offset", Vector2(randf_range(-7, 7), randf_range(-7, 7)), 0.05)
	tween_shake.tween_property(cam, "offset", orig_cam_offset, 0.05)
	await get_tree().create_timer(0.5).timeout
	
	# Frame 7: Recoil y disipación de energía
	boss_frame_col = 7
	boss_atlas.region = Rect2(7 * boss_cell_size, 4 * boss_cell_size, boss_cell_size, boss_cell_size)
	enemy_sprite.modulate = Color.WHITE if not boss_has_red_aura else Color(2.5, 0.4, 0.4)
	await get_tree().create_timer(0.3).timeout
	
	# Restaurar postura normal
	boss_frame_row = 4
	boss_frame_col = 0
	boss_atlas.region = Rect2(0, 4 * boss_cell_size, boss_cell_size, boss_cell_size)
	boss_is_special_anim = false

func enemy_turn():
	if is_battle_over:
		return
		
	var alive_heroes_indices = []
	for i in range(battle_party.size()):
		if battle_party[i]["hp"] > 0:
			alive_heroes_indices.append(i)
			
	if alive_heroes_indices.is_empty():
		game_over()
		return
		
	var target_index = alive_heroes_indices[randi() % alive_heroes_indices.size()]
	var target = battle_party[target_index]
	var attacks = enemy.get("attacks", ["Ataque genérico"])
	var chosen_atk = attacks[randi() % attacks.size()]
	var is_dragon_boss = enemy.get("type") == "dragon_boss"
	var dmg = max(5, enemy.get("atk", 20) + randi_range(-2, 5) - int(target["def"] * 0.4))
	var log_msg = ""
	
	if is_dragon_boss:
		if not boss_has_red_aura and randf() < 0.25:
			chosen_atk = "Emputarse por nada"
		elif randf() < 0.45 or chosen_atk == "DONDE ESTA MI DRAGON IMPRESO EN 3D":
			chosen_atk = "DONDE ESTA MI DRAGON IMPRESO EN 3D"
		else:
			chosen_atk = "La Cólera del Dragón"

		if chosen_atk == "DONDE ESTA MI DRAGON IMPRESO EN 3D":
			dmg = 150 # Baja 150 de vida como pidió el usuario
			await play_dragon_special_anim(target["name"])
			log_msg = "¡¡DONDE ESTA MI DRAGON IMPRESO EN 3D!! ¡El Señor del Dragón desató toda su furia acumulada invocando al dragón espectral e infligió 150 de daño directo a %s!" % target["name"]
		elif chosen_atk == "Emputarse por nada":
			boss_has_red_aura = true
			enemy["atk"] = enemy.get("atk", 25) + 12 # Boost de 5 niveles
			dmg = max(14, enemy["atk"] + randi_range(2, 6) - int(target["def"] * 0.4))
			var aura_tween = create_tween().set_loops()
			aura_tween.tween_property(enemy_sprite, "modulate", Color(3.5, 0.3, 0.3), 0.3)
			aura_tween.tween_property(enemy_sprite, "modulate", Color(1.8, 0.6, 0.6), 0.3)
			log_msg = "¡¡EMPUTARSE POR NADA!! El Señor del Dragón estalla de ira sin motivo, activa un AURA ROJA (+5 niveles, +12 ATQ) y golpea a %s por %d de daño." % [target["name"], dmg]
		elif chosen_atk == "La Cólera del Dragón":
			dmg = int(dmg * 1.5)
			log_msg = "¡¡LA CÓLERA DEL DRAGÓN!! ¡Un rugido draconiano hace temblar la sala! %s recibió %d de daño." % [target["name"], dmg]
		else:
			chosen_atk = "Acoso"
			log_msg = "¡El Señor del Dragón lanzó 'Acoso'! Mensajes y llamadas pasivo-agresivas a deshoras. %s recibió %d de daño." % [target["name"], dmg]
	else:
		log_msg = "[!] ¡%s atacó a %s con '%s'! (%d de daño)" % [enemy.get("name", "Enemigo"), target["name"], chosen_atk, dmg]
	
	target["hp"] = max(0, target["hp"] - dmg)
	
	# Efecto visual de golpe en el héroe objetivo
	if target_index < battler_sprites.size():
		var spr = battler_sprites[target_index]
		var tween = create_tween()
		tween.tween_property(spr, "modulate", Color.RED, 0.1)
		tween.tween_property(spr, "modulate", Color.WHITE, 0.1)
		if target["hp"] <= 0:
			spr.frame = 11 * 4 + 3
			
	render_party_ui()
	set_log(log_msg)
	
	await get_tree().create_timer(0.7).timeout
	
	# Ataques de los cartuchos de tóner (uno a uno con pausa breve para no saturar la pantalla)
	if printer_minions_spawned and has_alive_minions() and not is_battle_over:
		for m in printer_minions:
			if m["alive"] and not is_battle_over:
				var m_alive = []
				for h_i in range(battle_party.size()):
					if battle_party[h_i]["hp"] > 0:
						m_alive.append(h_i)
				if not m_alive.is_empty():
					var m_tgt_idx = m_alive[randi() % m_alive.size()]
					var m_tgt = battle_party[m_tgt_idx]
					var m_dmg = max(2, m["atk"] + randi_range(-1, 2) - int(m_tgt["def"] * 0.3))
					m_tgt["hp"] = max(0, m_tgt["hp"] - m_dmg)
					if m_tgt_idx < battler_sprites.size():
						var spr_h = battler_sprites[m_tgt_idx]
						var tw = create_tween()
						tw.tween_property(spr_h, "modulate", Color(1.8, 0.3, 0.3), 0.1)
						tw.tween_property(spr_h, "modulate", Color.WHITE, 0.1)
						if m_tgt["hp"] <= 0:
							spr_h.frame = 11 * 4 + 3
					render_party_ui()
					set_log("¡%s disparó %s! (%d daño a %s)" % [m["name"], m["atk_name"], m_dmg, m_tgt["name"]])
					await get_tree().create_timer(0.45).timeout
	
	var all_dead = true
	for m in battle_party:
		if m["hp"] > 0:
			all_dead = false
			break
			
	await get_tree().create_timer(0.5).timeout
	
	if all_dead:
		game_over()
	else:
		advance_to_next_hero()

func enemy_defeated():
	is_battle_over = true
	GameManager.victorious_count += 1
	
	if boss_atlas != null:
		boss_is_special_anim = true
		boss_frame_row = 5 # Row 5: Col 5 = Hincado en pose de derrota
		boss_frame_col = 5
		boss_atlas.region = Rect2(5 * boss_cell_size, 5 * boss_cell_size, boss_cell_size, boss_cell_size)
	
	if GameManager.current_enemy_id != "" and not GameManager.defeated_enemies.has(GameManager.current_enemy_id):
		GameManager.defeated_enemies.append(GameManager.current_enemy_id)
		
	var enemy_type_str = enemy.get("type", "printer")
	var exp_gained = enemy.get("exp_reward", 45)
	var coins_reward = 80
	if enemy_type_str == "printer":
		coins_reward = 250
	elif enemy_type_str == "dragon_boss":
		coins_reward = 500
	GameManager.it_budget += coins_reward
	
	for i in range(min(GameManager.party.size(), battle_party.size())):
		GameManager.party[i]["hp"] = battle_party[i]["hp"]
		
	# Entregar EXP y calcular subidas de nivel
	var level_ups = GameManager.add_exp_to_party(exp_gained)
	
	# Sincronizar datos de la party con GameManager
	battle_party = GameManager.party.duplicate(true)
	render_party_ui()
	
	if enemy_type_str == "printer":
		GameManager.printer_defeated = true
		GameManager.player_saved_position = Vector2(980, 200)
		set_log("[!] ¡VICTORIA TOTAL! ¡La Impresora Maldita fue neutralizada! (+%d EXP, +$%d Presupuesto)" % [exp_gained, coins_reward])
	elif enemy_type_str == "dragon_boss":
		GameManager.dragon_boss_defeated = true
		GameManager.player_saved_position = Vector2(1820, 180)
		set_log("[VICTORIA!] El Señor del Dragón cae hincado exhausto: '¡Maldita sea... no es la última vez que sabrán de mí!...' (+%d EXP, +$%d Presupuesto)" % [exp_gained, coins_reward])
	elif enemy_type_str == "password_boss":
		GameManager.server_boss_defeated = true
		GameManager.player_saved_position = Vector2(2560, 180)
		set_log("[SITE SALVADO] ¡Ruta establecida al 189 y Servidor 117 desbloqueado! (+%d EXP, +$%d Presupuesto)" % [exp_gained, coins_reward])
	else:
		set_log("[!] ¡Ticket resuelto! '%s' neutralizado. (+%d EXP, +$%d Presupuesto)" % [enemy.get("name", "Enemigo"), exp_gained, coins_reward])
		
	if level_ups.size() > 0:
		await get_tree().create_timer(1.2).timeout
		var names = []
		for lup in level_ups:
			names.append("%s (Nv. %d)" % [lup["name"], lup["level"]])
		set_log("[⭐ LEVEL UP!] ¡%s subió de nivel! (+35 HP Max, +9 ATQ, +5 DEF, ¡Salud al 100%!)" % ", ".join(names))
		
	await get_tree().create_timer(2.2).timeout
	GameManager.change_scene_instant(get_tree(), "res://scenes/overworld.tscn")

func game_over():
	is_battle_over = true
	set_log("[KO] GAME OVER: Caída catastrófica de servidores. Todo IT fue despedido.")
	await get_tree().create_timer(2.0).timeout
	GameManager.change_scene_instant(get_tree(), "res://scenes/character_select.tscn")

func set_log(text: String):
	log_label.text = text
