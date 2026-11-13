extends Control

# Battle System - Chrono Trigger / FF6 Style with Animated 16-Bit Sprites

@onready var enemy_name_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyName
@onready var enemy_hp_bar = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPBar
@onready var enemy_hp_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPText
@onready var enemy_sprite = $MainBox/BattleArena/EnemySide/Center/EnemySprite

@onready var hero_sprites_container = $MainBox/BattleArena/BattlersArena/HeroSpritesContainer
@onready var party_container = $MainBox/BattleArena/PartySide/PartyContainer
@onready var log_label = $MainBox/LogPanel/Margin/LogLabel

@onready var commands_box = $MainBox/CommandPanel/Margin/HBox/Commands
@onready var btn_attack = $MainBox/CommandPanel/Margin/HBox/Commands/BtnAttack
@onready var btn_skill = $MainBox/CommandPanel/Margin/HBox/Commands/BtnSkill
@onready var btn_item = $MainBox/CommandPanel/Margin/HBox/Commands/BtnItem
@onready var btn_flee = $MainBox/CommandPanel/Margin/HBox/Commands/BtnFlee

@onready var items_menu = $MainBox/CommandPanel/Margin/HBox/ItemsMenu
@onready var btn_item_pepsi = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemPepsi
@onready var btn_item_cafe = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemCafe
@onready var btn_item_predator = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemPredator
@onready var btn_item_foto = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemFoto
@onready var btn_item_back = $MainBox/CommandPanel/Margin/HBox/ItemsMenu/BtnItemBack

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

func _ready():
	get_viewport().canvas_transform = Transform2D.IDENTITY
	$Camera2D.make_current()
	setup_battle()
	btn_attack.pressed.connect(_on_attack_pressed)
	btn_skill.pressed.connect(_on_skill_pressed)
	btn_item.pressed.connect(_on_item_pressed)
	btn_flee.pressed.connect(_on_flee_pressed)
	
	btn_item_pepsi.pressed.connect(func(): _use_item("pepsi"))
	btn_item_cafe.pressed.connect(func(): _use_item("cafe"))
	btn_item_predator.pressed.connect(func(): _use_item("predator"))
	btn_item_foto.pressed.connect(func(): _use_item("foto"))
	btn_item_back.pressed.connect(_on_item_back_pressed)

func setup_battle():
	javier_first_attack = true
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
	if ResourceLoader.exists(enemy.get("texture_path", "")):
		enemy_sprite.texture = load(enemy.get("texture_path"))
	enemy_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	enemy_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	update_enemy_ui()
	
	# Cargar party desde GameManager
	battle_party = GameManager.party.duplicate(true)
	create_battler_sprites()
	render_party_ui()
	
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
		spr.scale = Vector2(0.32, 0.32)
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
	active_party_index += 1
	if active_party_index >= battle_party.size():
		active_party_index = 0
		enemy_turn()
	else:
		start_turn()

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

func update_items_ui():
	var pepsi = GameManager.battle_items["pepsi"]
	var cafe = GameManager.battle_items["cafe"]
	var predator = GameManager.battle_items["predator"]
	var foto = GameManager.battle_items["foto"]
	
	btn_item_pepsi.text = "Pepsi (+20/50) x%d" % pepsi["count"]
	btn_item_pepsi.disabled = pepsi["count"] <= 0
	
	btn_item_cafe.text = "Café (+50/0) x%d" % cafe["count"]
	btn_item_cafe.disabled = cafe["count"] <= 0
	
	btn_item_predator.text = "Predator (+50/100) x%d" % predator["count"]
	btn_item_predator.disabled = predator["count"] <= 0
	
	btn_item_foto.text = "Foto Sra. Limpieza x%d" % foto["count"]
	btn_item_foto.disabled = foto["count"] <= 0

func _on_item_back_pressed():
	items_menu.visible = false
	commands_box.visible = true

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
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

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

func deal_damage_to_enemy(damage: int, message: String):
	enemy_current_hp -= damage
	update_enemy_ui()
	set_log("%s (%d de daño)." % [message, damage])
	
	# Efecto visual en el enemigo
	var tween = create_tween()
	tween.tween_property(enemy_sprite, "modulate", Color(3.0, 0.2, 0.2), 0.1)
	tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.1)
	
	if enemy_current_hp <= 0:
		enemy_defeated()
	else:
		end_hero_action()

func end_hero_action():
	is_player_turn = false
	reset_active_sprite_position()
	await get_tree().create_timer(0.9).timeout
	advance_to_next_hero()

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
	var dmg = max(5, enemy.get("atk", 20) + randi_range(-2, 5) - int(target["def"] * 0.4))
	
	target["hp"] = max(0, target["hp"] - dmg)
	
	# Efecto visual de golpe en el héroe objetivo
	if target_index < battler_sprites.size():
		var spr = battler_sprites[target_index]
		var tween = create_tween()
		tween.tween_property(spr, "modulate", Color.RED, 0.1)
		tween.tween_property(spr, "modulate", Color.WHITE, 0.1)
		if target["hp"] <= 0:
			# Animación de desmayado (Row 11 frame 3)
			spr.frame = 11 * 4 + 3
			set_log("[KO] ¡%s ha caído desmayado!" % target["name"])
	
	render_party_ui()
	set_log("[!] ¡%s atacó a %s con '%s'! (%d de daño)" % [enemy.get("name", "Enemigo"), target["name"], chosen_atk, dmg])
	
	var all_dead = true
	for m in battle_party:
		if m["hp"] > 0:
			all_dead = false
			break
			
	await get_tree().create_timer(1.2).timeout
	
	if all_dead:
		game_over()
	else:
		start_turn()

func enemy_defeated():
	is_battle_over = true
	GameManager.victorious_count += 1
	
	if GameManager.current_enemy_id != "" and not GameManager.defeated_enemies.has(GameManager.current_enemy_id):
		GameManager.defeated_enemies.append(GameManager.current_enemy_id)
		
	var enemy_type_str = enemy.get("type", "printer")
	var exp_gained = enemy.get("exp_reward", 45)
	
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
		set_log("[!] ¡VICTORIA TOTAL! ¡La Impresora Maldita fue neutralizada! (+%d EXP)" % exp_gained)
	else:
		set_log("[!] ¡Ticket resuelto! '%s' ha sido neutralizado. (+%d EXP)" % [enemy.get("name", "Enemigo"), exp_gained])
		
	if level_ups.size() > 0:
		await get_tree().create_timer(1.2).timeout
		var names = []
		for lup in level_ups:
			names.append("%s (Nv. %d)" % [lup["name"], lup["level"]])
		set_log("[LEVEL UP!] ¡%s subió de nivel! (+25 HP Max, +6 ATQ, +4 DEF, HP restaurado)" % ", ".join(names))
		
	await get_tree().create_timer(2.2).timeout
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func game_over():
	is_battle_over = true
	set_log("[KO] GAME OVER: Caída catastrófica de servidores. Todo IT fue despedido.")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")

func set_log(text: String):
	log_label.text = text
