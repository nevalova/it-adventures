extends Control

# Battle System - Chrono Trigger / FF6 Style

@onready var enemy_name_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyName
@onready var enemy_hp_bar = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPBar
@onready var enemy_hp_label = $MainBox/BattleArena/EnemySide/EnemyPanel/VBox/EnemyHPText
@onready var enemy_sprite = $MainBox/BattleArena/EnemySide/EnemySprite

@onready var party_container = $MainBox/BattleArena/PartySide/PartyContainer
@onready var log_label = $MainBox/LogPanel/Margin/LogLabel

@onready var btn_attack = $MainBox/CommandPanel/Margin/HBox/Commands/BtnAttack
@onready var btn_skill = $MainBox/CommandPanel/Margin/HBox/Commands/BtnSkill
@onready var btn_item = $MainBox/CommandPanel/Margin/HBox/Commands/BtnItem
@onready var btn_flee = $MainBox/CommandPanel/Margin/HBox/Commands/BtnFlee

@onready var turn_indicator = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/TurnIndicator
@onready var active_hero_name = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/HeroName
@onready var active_hero_status = $MainBox/CommandPanel/Margin/HBox/ActiveHeroBox/HeroStatus

# Enemy Data
var enemy = {}
var enemy_max_hp: int = 100
var enemy_current_hp: int = 100

# Party State
var battle_party: Array = []
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
	render_party_ui()
	
	set_log("¡Un " + enemy.get("name", "problema") + " salvaje ha detenido los servidores!")
	start_turn()

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
		card.custom_minimum_size = Vector2(180, 50)
		var vb = VBoxContainer.new()
		
		var name_lbl = Label.new()
		name_lbl.text = member["name"] + " (" + member["role"].substr(0, 8) + ")"
		name_lbl.modulate = member["color"]
		vb.add_child(name_lbl)
		
		var hp_bar = ProgressBar.new()
		hp_bar.max_value = member["max_hp"]
		hp_bar.value = max(0, member["hp"])
		hp_bar.custom_minimum_size = Vector2(160, 14)
		vb.add_child(hp_bar)
		
		var hp_txt = Label.new()
		hp_txt.text = "%d/%d HP" % [max(0, member["hp"]), member["max_hp"]]
		hp_txt.add_theme_font_size_override("font_size", 10)
		vb.add_child(hp_txt)
		
		card.add_child(vb)
		party_container.add_child(card)

func get_active_member() -> Dictionary:
	return battle_party[active_party_index]

func start_turn():
	if is_battle_over:
		return
		
	# Verificar si el héroe actual está vivo
	var member = get_active_member()
	if member["hp"] <= 0:
		advance_to_next_hero()
		return
		
	is_player_turn = true
	active_hero_name.text = member["name"].to_upper()
	active_hero_name.modulate = member["color"]
	
	# REGLA CLAVE DE JAVIER:
	# Javier ataca un turno sí y otro no
	if member["name"] == "Javier":
		if javier_can_attack:
			active_hero_status.text = "¡LISTO PARA ATACAR! (Turno Sí)"
			active_hero_status.modulate = Color(0.4, 1.0, 0.4)
			btn_attack.disabled = false
			btn_attack.text = "⚔ Atacar (Reinicio Forzado)"
		else:
			active_hero_status.text = "💤 Tomando Café & Memes (Turno No)"
			active_hero_status.modulate = Color(1.0, 0.8, 0.2)
			btn_attack.disabled = false
			btn_attack.text = "☕ Procrastinar / Descansar"
	else:
		active_hero_status.text = "Listo para actuar"
		active_hero_status.modulate = Color(1, 1, 1)
		btn_attack.disabled = false
		btn_attack.text = "⚔ Atacar"

func advance_to_next_hero():
	active_party_index += 1
	if active_party_index >= battle_party.size():
		# Fin del turno de todos los héroes vivos -> Turno del enemigo
		active_party_index = 0
		enemy_turn()
	else:
		start_turn()

func _on_attack_pressed():
	if not is_player_turn or is_battle_over:
		return
		
	var member = get_active_member()
	
	# CASO JAVIER: "atacara un turno si y otro no"
	if member["name"] == "Javier":
		if not javier_can_attack:
			# Turno NO: descansa y procrastina
			javier_can_attack = true # el siguiente turno SÍ podrá
			set_log("☕ ¡Javier está procrastinando y tomando café! (Ataca un turno sí y otro no). Javier recarga energías para el próximo turno.")
			# Pequeña curación por el café
			member["hp"] = min(member["max_hp"], member["hp"] + 15)
			render_party_ui()
			end_hero_action()
			return
		else:
			# Turno SÍ: ataca con daño aumentado por haber descansado
			javier_can_attack = false # el siguiente turno descansará
			var dmg = member["atk"] + randi_range(5, 12)
			deal_damage_to_enemy(dmg, "⚡ ¡Javier le propinó un REINICIO FORZADO al enemigo!")
			return
			
	# Otros miembros atacan normalmente
	var dmg = member["atk"] + randi_range(-3, 5)
	deal_damage_to_enemy(dmg, "¡%s lanzó un ataque certero!" % member["name"])

func _on_skill_pressed():
	if not is_player_turn or is_battle_over:
		return
	var member = get_active_member()
	var skill_name = member.get("special_move_name", "Habilidad Especial")
	
	if member["name"] == "Javier":
		if not javier_can_attack:
			set_log("Javier bosteza: 'No puedo usar skills, estoy leyendo Reddit'.")
			javier_can_attack = true
			end_hero_action()
			return
		else:
			javier_can_attack = false
			var dmg = int(member["atk"] * 1.6)
			deal_damage_to_enemy(dmg, "💥 ¡Javier usó %s! ¡El rack tembló!" % skill_name)
			return
			
	var dmg = int(member["atk"] * 1.4)
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

func deal_damage_to_enemy(damage: int, message: String):
	enemy_current_hp -= damage
	update_enemy_ui()
	set_log("%s (%d de daño)." % [message, damage])
	
	# Efecto visual en el enemigo
	var tween = create_tween()
	tween.tween_property(enemy_sprite, "modulate", Color(2.5, 0.2, 0.2), 0.1)
	tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.1)
	
	if enemy_current_hp <= 0:
		enemy_defeated()
	else:
		end_hero_action()

func end_hero_action():
	is_player_turn = false
	await get_tree().create_timer(0.9).timeout
	advance_to_next_hero()

func enemy_turn():
	if is_battle_over or enemy_current_hp <= 0:
		return
		
	# Elegir un objetivo vivo de la party
	var alive_heroes = []
	for member in battle_party:
		if member["hp"] > 0:
			alive_heroes.append(member)
			
	if alive_heroes.is_empty():
		game_over()
		return
		
	var target = alive_heroes[randi() % alive_heroes.size()]
	var attacks = enemy.get("attacks", ["Ataque genérico"])
	var chosen_atk = attacks[randi() % attacks.size()]
	var dmg = max(5, enemy.get("atk", 15) + randi_range(-2, 4) - int(target["def"] * 0.4))
	
	target["hp"] = max(0, target["hp"] - dmg)
	render_party_ui()
	set_log("👹 ¡%s atacó a %s con '%s'! (%d de daño)" % [enemy.get("name", "Enemigo"), target["name"], chosen_atk, dmg])
	
	# Verificar game over
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
	set_log("🎉 ¡VICTORIA! ¡El " + enemy.get("name") + " fue derrotado! El servidor opera con normalidad.")
	
	# Sincronizar vida de los héroes de vuelta
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
