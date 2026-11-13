extends Control

# Battle System - Chrono Trigger / FF6 Style with Animated 16-Bit Sprites

@onready var enemy_name_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyName
@onready var enemy_hp_bar = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPBar
@onready var enemy_hp_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPText
@onready var enemy_sprite = $MainBox/BattleArena/EnemySide/Center/EnemySprite

@onready var hero_sprites_container = $MainBox/BattleArena/BattlersArena/HeroSpritesContainer
@onready var party_container = $MainBox/BattleArena/PartySide/PartyContainer
@onready var log_label = $MainBox/LogPanel/Margin/LogLabel

@onready var btn_attack = $MainBox/CommandPanel/Margin/HBox/Commands/BtnAttack
@onready var btn_skill = $MainBox/CommandPanel/Margin/HBox/Commands/BtnSkill
@onready var btn_item = $MainBox/CommandPanel/Margin/HBox/Commands/BtnItem
@onready var btn_flee = $MainBox/CommandPanel/Margin/HBox/Commands/BtnFlee

@onready var active_hero_portrait = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/ActiveHeroPortrait
@onready var active_hero_name = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/VBox/HeroName
@onready var active_hero_status = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/VBox/HeroStatus

# Enemy Data
var enemy = {}
var enemy_max_hp: int = 100
var enemy_current_hp: int = 100

# Party State
var battle_party: Array = []
var battler_sprites: Array = [] # Sprite2D nodes for each hero
var active_party_index: int = 0
var is_player_turn: bool = true
var is_battle_over: bool = false

# Javier mechanic: ataca un turno si y otro no
var javier_can_attack: bool = true

func _ready():
	setup_battle()
	btn_attack.pressed.connect(_on_attack_pressed)
	btn_skill.pressed.connect(_on_skill_pressed)
	btn_item.pressed.connect(_on_item_pressed)
	btn_flee.pressed.connect(_on_flee_pressed)

func setup_battle():
	# Cargar enemigo
	if GameManager.current_enemy_data.is_empty():
		enemy = {
			"name": "Impresora Maldita",
			"hp": 90,
			"max_hp": 90,
			"atk": 18,
			"def": 8,
			"texture_path": "res://assets/printer_enemy.png",
			"attacks": ["Tóner en los ojos", "Atasco de Papel", "Error Desconocido"]
		}
	else:
		enemy = GameManager.current_enemy_data
		
	enemy_max_hp = enemy.get("max_hp", 90)
	enemy_current_hp = enemy.get("hp", enemy_max_hp)
	enemy_name_label.text = enemy.get("name", "Enemigo")
	if ResourceLoader.exists(enemy.get("texture_path", "")):
		enemy_sprite.texture = load(enemy.get("texture_path"))
	update_enemy_ui()
	
	# Cargar party desde GameManager
	battle_party = GameManager.party.duplicate(true)
	create_battler_sprites()
	render_party_ui()
	
	set_log("¡Un " + enemy.get("name", "problema") + " salvaje ha detenido los servidores!")
	start_turn()

func create_battler_sprites():
	for c in hero_sprites_container.get_children():
		c.queue_free()
	battler_sprites.clear()
	
	# Posiciones diagonales estilo Chrono Trigger / FF6
	var base_x = 70.0
	var base_y = 30.0
	var step_x = 24.0
	var step_y = 38.0
	
	for i in range(battle_party.size()):
		var member = battle_party[i]
		var spr = Sprite2D.new()
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(member.get("spritesheet_path", "")):
			spr.texture = load(member["spritesheet_path"])
		spr.hframes = 4
		spr.vframes = 12
		spr.scale = Vector2(0.32, 0.32)
		spr.position = Vector2(base_x + i * step_x, base_y + i * step_y)
		# Row 6 (mirando a la izquierda hacia el enemigo)
		spr.frame = 6 * 4 + 0
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
		port.custom_minimum_size = Vector2(30, 30)
		port.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		port.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		port.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if ResourceLoader.exists(member.get("portrait_path", "")):
			port.texture = load(member["portrait_path"])
		hb.add_child(port)
		
		var vb = VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var name_lbl = Label.new()
		name_lbl.text = member["name"]
		name_lbl.modulate = member["color"]
		name_lbl.add_theme_font_size_override("font_size", 10)
		vb.add_child(name_lbl)
		
		var hp_bar = ProgressBar.new()
		hp_bar.max_value = member["max_hp"]
		hp_bar.value = max(0, member["hp"])
		hp_bar.custom_minimum_size = Vector2(130, 10)
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
	active_hero_name.text = member["name"].to_upper()
	active_hero_name.modulate = member["color"]
	
	if ResourceLoader.exists(member.get("portrait_path", "")):
		active_hero_portrait.texture = load(member["portrait_path"])
		
	# Resaltar sprite activo (dar un paso al frente)
	var spr = get_active_sprite()
	if spr:
		spr.position.x -= 8.0
		spr.modulate = Color(1.2, 1.2, 1.2)
	
	# REGLA CLAVE DE JAVIER:
	if member["name"] == "Javier":
		if javier_can_attack:
			active_hero_status.text = "¡LISTO PARA ATACAR! (Turno Sí)"
			active_hero_status.modulate = Color(0.4, 1.0, 0.4)
			btn_attack.disabled = false
			btn_attack.text = "⚔ Atacar (Reinicio Forzado)"
			if spr: spr.frame = 6 * 4 + 0 # Listo mirando al enemigo
		else:
			active_hero_status.text = "💤 Tomando Café & Memes (Turno No)"
			active_hero_status.modulate = Color(1.0, 0.8, 0.2)
			btn_attack.disabled = false
			btn_attack.text = "☕ Procrastinar / Descansar"
			if spr: spr.frame = 8 * 4 + 0 # Mirando al frente descansando
	else:
		active_hero_status.text = "Listo para actuar"
		active_hero_status.modulate = Color(1, 1, 1)
		btn_attack.disabled = false
		btn_attack.text = "⚔ Atacar"
		if spr: spr.frame = 6 * 4 + 0

func reset_active_sprite_position():
	var spr = get_active_sprite()
	if spr:
		var base_x = 70.0
		var step_x = 24.0
		spr.position.x = base_x + active_party_index * step_x
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
			set_log("☕ ¡Javier está procrastinando y tomando café! (Ataca un turno sí y otro no). Javier recarga energías para el próximo turno.")
			member["hp"] = min(member["max_hp"], member["hp"] + 15)
			render_party_ui()
			end_hero_action()
			return
		else:
			javier_can_attack = false # el siguiente turno descansará
			var dmg = member["atk"] + randi_range(6, 14)
			play_attack_anim(spr)
			deal_damage_to_enemy(dmg, "⚡ ¡Javier le propinó un REINICIO FORZADO al enemigo!")
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
			set_log("Javier bosteza: 'No puedo usar skills, estoy leyendo Reddit'.")
			javier_can_attack = true
			end_hero_action()
			return
		else:
			javier_can_attack = false
			var dmg = int(member["atk"] * 1.6)
			play_attack_anim(spr)
			deal_damage_to_enemy(dmg, "💥 ¡Javier usó %s! ¡El rack tembló!" % skill_name)
			return
			
	var dmg = int(member["atk"] * 1.4)
	play_attack_anim(spr)
	deal_damage_to_enemy(dmg, "✨ ¡%s usó %s!" % [member["name"], skill_name])

func _on_item_pressed():
	if not is_player_turn or is_battle_over:
		return
	var member = get_active_member()
	var heal = 35
	member["hp"] = min(member["max_hp"], member["hp"] + heal)
	render_party_ui()
	set_log("☕ ¡%s tomó un espresso doble bien cargado! Recuperó %d HP." % [member["name"], heal])
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
	tween.tween_callback(func(): spr.frame = 6 * 4 + 0)

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
	if is_battle_over or enemy_current_hp <= 0:
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
	var dmg = max(5, enemy.get("atk", 15) + randi_range(-2, 4) - int(target["def"] * 0.4))
	
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
			set_log("💀 ¡%s ha caído desmayado!" % target["name"])
	
	render_party_ui()
	set_log("👹 ¡%s atacó a %s con '%s'! (%d de daño)" % [enemy.get("name", "Enemigo"), target["name"], chosen_atk, dmg])
	
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
	set_log("🎉 ¡VICTORIA! ¡El " + enemy.get("name") + " fue resuelto! El servidor vuelve a la normalidad.")
	
	for i in range(min(GameManager.party.size(), battle_party.size())):
		GameManager.party[i]["hp"] = battle_party[i]["hp"]
		
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func game_over():
	is_battle_over = true
	set_log("☠ GAME OVER: Caída catastrófica de servidores. Todo IT fue despedido.")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")

func set_log(text: String):
	log_label.text = text
