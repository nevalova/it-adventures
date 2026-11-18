extends Node

# Autoload GameManager (Singleton)

var characters_data = {
	"javier": {
		"id": "javier",
		"name": "Javier",
		"role": "Soporte Técnico",
		"title": "El Procrastinador de Servidores",
		"description": "Ataca un turno sí y otro no (un turno descansa o ve memes, al siguiente pega brutal).",
		"max_hp": 160,
		"hp": 160,
		"atk": 42,
		"def": 18,
		"level": 1,
		"exp": 0,
		"exp_to_next": 60,
		"color": Color("#3498db"), # Azul
		"special_mechanic": "one_turn_skip", # Ataca un turno si y otro no
		"special_move_name": "Reinicio Forzado al Rack",
		"avatar_symbol": "[J]",
		"portrait_path": "res://assets/characters/javier_portrait.png",
		"spritesheet_path": "res://assets/characters/javier_spritesheet.png",
		"overworld_scale": Vector2(0.24, 0.24),
		"battle_scale": Vector2(0.32, 0.32)
	},
	"tonazo": {
		"id": "tonazo",
		"name": "Toñazo",
		"role": "Soporte Técnico",
		"title": "El de la USB Azul Milagrosa",
		"description": "Lleva la memoria USB booteable en el cuello. Parchea cables y revive cualquier PC.",
		"max_hp": 125,
		"hp": 125,
		"atk": 25,
		"def": 15,
		"level": 1,
		"exp": 0,
		"exp_to_next": 60,
		"color": Color("#2ecc71"), # Verde
		"special_mechanic": "healer",
		"special_move_name": "USB Booteable con Linux Milagroso",
		"avatar_symbol": "[T]",
		"portrait_path": "res://assets/characters/tonazo_portrait.png",
		"spritesheet_path": "res://assets/characters/tonazo_spritesheet.png",
		"overworld_scale": Vector2(0.24, 0.24),
		"battle_scale": Vector2(0.32, 0.32)
	},
	"juan_carlos": {
		"id": "juan_carlos",
		"name": "Juan Carlos",
		"role": "El Top Gun",
		"title": "Es la mera reata hasta arriba",
		"description": "Elegante, implacable y con autoridad absoluta. Cuando Juan habla, todos los servidores se alinean.",
		"max_hp": 140,
		"hp": 140,
		"atk": 30,
		"def": 22,
		"level": 1,
		"exp": 0,
		"exp_to_next": 60,
		"color": Color("#9b59b6"), # Morado
		"special_mechanic": "shield_tank",
		"special_move_name": "Ataque DDoS con la Cafetera",
		"avatar_symbol": "[JC]",
		"portrait_path": "res://assets/characters/juan_carlos_portrait.png",
		"spritesheet_path": "res://assets/characters/juan_carlos_spritesheet.png",
		"overworld_scale": Vector2(0.28, 0.28),
		"battle_scale": Vector2(0.365, 0.365)
	},
	"alejandro": {
		"id": "alejandro",
		"name": "Alejandro",
		"role": "Soporte Técnico",
		"title": "Resiliencia Total",
		"description": "La leyenda dice que estuvo 20 horas esperando por un iPhone que ni era de él. Sobrevive a base de Pepsi y el odio que le tiene al mundo.",
		"max_hp": 130,
		"hp": 130,
		"atk": 38,
		"def": 18,
		"level": 1,
		"exp": 0,
		"exp_to_next": 60,
		"color": Color("#e67e22"), # Naranja
		"special_mechanic": "critical_dev",
		"special_move_name": "Mañana no vengo, voy a Chilpancingo",
		"avatar_symbol": "[A]",
		"portrait_path": "res://assets/characters/alejandro_portrait.png",
		"spritesheet_path": "res://assets/characters/alejandro_spritesheet.png",
		"overworld_scale": Vector2(0.24, 0.24),
		"battle_scale": Vector2(0.32, 0.32)
	},
	"israel": {
		"id": "israel",
		"name": "Israel",
		"role": "Soporte Técnico",
		"title": "El Guardián Veterano",
		"description": "El sabio de la barba plateada. Maestro del SQL cuyo comando DROP DATABASE causa pánico.",
		"max_hp": 130,
		"hp": 130,
		"atk": 40,
		"def": 16,
		"level": 1,
		"exp": 0,
		"exp_to_next": 60,
		"color": Color("#e74c3c"), # Rojo
		"special_mechanic": "high_damage",
		"special_move_name": "DROP DATABASE CON ROOT",
		"avatar_symbol": "[I]",
		"portrait_path": "res://assets/characters/israel_portrait.png",
		"spritesheet_path": "res://assets/characters/israel_spritesheet.png",
		"overworld_scale": Vector2(0.23, 0.23),
		"battle_scale": Vector2(0.31, 0.31)
	}
}

var selected_hero_id: String = "javier"
var party: Array = []
var player_saved_position: Vector2 = Vector2(140, 200)
var current_enemy_data: Dictionary = {}
var current_enemy_id: String = ""
var defeated_enemies: Array = []
var victorious_count: int = 0
var intro_cutscene_done: bool = false
var office_cutscene_done: bool = false
var printer_defeated: bool = false
var victory_dialogue_shown: bool = false
var dragon_boss_cutscene_done: bool = false
var dragon_boss_fled: bool = false
var dragon_boss_defeated: bool = false
var director_cutscene_done: bool = false
var server_site_cutscene_done: bool = false
var password_quest_active: bool = false
var server_boss_defeated: bool = false

var it_budget: int = 200 # Presupuesto de caja chica de IT para la tiendita de Nelly

# Sistema de Configuración de Controles
# Tipos: "dpad" (Botones Fijos), "joystick" (Análogo Arrastrable), "point_and_click" (Tocar para Moverse)
var control_type: String = "dpad"

var control_modes = {
	"dpad": {
		"title": "D-Pad Clásico (Botones Fijos)",
		"short": "D-Pad",
		"desc": "Cruceta direccional tradicional de 4 direcciones fija en pantalla táctil (y teclas WASD / Flechas en PC). Movimiento ortogonal clásico con máxima precisión retro."
	},
	"joystick": {
		"title": "Análogo Arrastrable (Joystick Táctil)",
		"short": "Joystick",
		"desc": "Stick análogo táctil arrastrable con el pulgar. Deslizamiento fluido y suave en 360° en cualquier dirección e inclinación. Ideal para celulares y pantallas táctiles."
	},
	"point_and_click": {
		"title": "Point and Click (Tocar para Moverse)",
		"short": "Point & Click",
		"desc": "Toca o haz clic con el ratón en cualquier punto del suelo y tu personaje caminará automáticamente hacia allí. Ideal para jugar con mouse en PC o con una sola mano en móvil."
	}
}

func set_control_type(new_type: String):
	if control_modes.has(new_type):
		control_type = new_type
		save_settings()

func cycle_control_type() -> String:
	match control_type:
		"dpad":
			set_control_type("joystick")
		"joystick":
			set_control_type("point_and_click")
		"point_and_click":
			set_control_type("dpad")
		_:
			set_control_type("dpad")
	return control_type

func save_settings():
	var config = ConfigFile.new()
	config.set_value("controls", "type", control_type)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var saved_mode = config.get_value("controls", "type", "dpad")
		if control_modes.has(saved_mode):
			control_type = saved_mode

var initial_characters_data: Dictionary = {}

var item_prices = {
	"pepsi": 15,
	"cafe": 25,
	"predator": 35,
	"foto": 50,
	"dia_libre": 90,
	"certificacion": 45
}

var battle_items = {
	"pepsi": {"name": "Lata de Pepsi", "count": 4, "desc": "Cura 20 HP (50 HP a Alejandro)"},
	"cafe": {"name": "Taza de Café", "count": 4, "desc": "Cura 50 HP (0 HP a Alex y Javier)"},
	"predator": {"name": "Lata de Predator", "count": 3, "desc": "Cura 50 HP (100 HP a Toño)"},
	"foto": {"name": "Foto de Sra. Limpieza", "count": 2, "desc": "Cura 0 a todos (100 HP a Juan Carlos)"},
	"dia_libre": {"name": "Día Libre", "count": 2, "desc": "Revive a un compañero caído y restaura 70 HP."}
}

func buy_item(item_key: String) -> bool:
	var price = item_prices.get(item_key, 25)
	if it_budget >= price:
		it_budget -= price
		if item_key == "certificacion":
			add_exp_to_party(120)
			return true
		if battle_items.has(item_key):
			battle_items[item_key]["count"] += 1
		return true
	return false

func reset_battle_items():
	it_budget = 200
	battle_items["pepsi"]["count"] = 4
	battle_items["cafe"]["count"] = 4
	battle_items["predator"]["count"] = 3
	battle_items["foto"]["count"] = 2
	battle_items["dia_libre"]["count"] = 2

func reset_game():
	if not initial_characters_data.is_empty():
		characters_data = initial_characters_data.duplicate(true)
	intro_cutscene_done = false
	office_cutscene_done = false
	printer_defeated = false
	victory_dialogue_shown = false
	dragon_boss_cutscene_done = false
	dragon_boss_fled = false
	dragon_boss_defeated = false
	director_cutscene_done = false
	server_site_cutscene_done = false
	password_quest_active = false
	server_boss_defeated = false
	defeated_enemies.clear()
	current_enemy_id = ""
	player_saved_position = Vector2(140, 200)
	victorious_count = 0
	init_party(selected_hero_id)

func add_exp_to_party(exp_amount: int) -> Array:
	var level_ups = []
	for char_id in characters_data.keys():
		var char_data = characters_data[char_id]
		var current_exp = char_data.get("exp", 0) + exp_amount
		var current_level = char_data.get("level", 1)
		var exp_needed = char_data.get("exp_to_next", 70)
		var did_level_up = false
		
		while current_exp >= exp_needed:
			current_exp -= exp_needed
			current_level += 1
			exp_needed = int(exp_needed * 1.35)
			char_data["max_hp"] += 35
			char_data["hp"] = char_data["max_hp"] # Cura completa al subir de nivel
			char_data["atk"] += 9
			char_data["def"] += 5
			did_level_up = true
			
		char_data["exp"] = current_exp
		char_data["level"] = current_level
		char_data["exp_to_next"] = exp_needed
		
		# Sincronizar de inmediato con party si el personaje está en el equipo activo
		for member in party:
			if member.get("id", "") == char_id:
				member["max_hp"] = char_data["max_hp"]
				member["hp"] = char_data["hp"]
				member["atk"] = char_data["atk"]
				member["def"] = char_data["def"]
				member["level"] = char_data["level"]
				member["exp"] = char_data["exp"]
				member["exp_to_next"] = char_data["exp_to_next"]
		
		if did_level_up:
			level_ups.append({
				"id": char_id,
				"name": char_data["name"],
				"level": current_level,
				"max_hp": char_data["max_hp"],
				"atk": char_data["atk"],
				"def": char_data["def"]
			})
	return level_ups

# Background Preloading System
var preloaded_scenes: Dictionary = {}

func preload_scene(path: String) -> void:
	if preloaded_scenes.has(path):
		return
	if ResourceLoader.has_cached(path):
		preloaded_scenes[path] = ResourceLoader.load(path)
		return
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(path)

func get_preloaded_scene(path: String) -> PackedScene:
	if preloaded_scenes.has(path):
		return preloaded_scenes[path]
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(path) as PackedScene
		preloaded_scenes[path] = scene
		return scene
	# Fallback synchronous load if threaded load has not finished
	var scene = load(path) as PackedScene
	preloaded_scenes[path] = scene
	return scene

func change_scene_instant(tree: SceneTree, path: String) -> void:
	var packed = get_preloaded_scene(path)
	if packed != null:
		tree.change_scene_to_packed(packed)
	else:
		tree.change_scene_to_file(path)

func _ready():
	load_settings()
	initial_characters_data = characters_data.duplicate(true)
	# Iniciar precarga asincrona en segundo plano de las escenas principales
	preload_scene("res://scenes/character_select.tscn")
	preload_scene("res://scenes/overworld.tscn")
	preload_scene("res://scenes/battle.tscn")
	
	# Party por defecto con los héroes principales
	init_party("javier")

func init_party(leader_id: String):
	selected_hero_id = leader_id
	party.clear()
	reset_battle_items()
	printer_defeated = false
	# El líder va de primero
	var leader_data = characters_data[leader_id].duplicate(true)
	leader_data["id"] = leader_id
	party.append(leader_data)
	
	# Por defecto, sumamos 2 compañeros iniciales (dejando 2 libres en la oficina)
	# para que el squad tenga 3 miembros y el jugador pueda hablar con los demás y elegir
	var companion_count = 0
	for id in characters_data.keys():
		if id != leader_id and companion_count < 2:
			var member = characters_data[id].duplicate(true)
			member["id"] = id
			party.append(member)
			companion_count += 1

func is_hero_in_party(hero_id: String) -> bool:
	for member in party:
		if member.get("id", "") == hero_id:
			return true
	return false

func add_hero_to_party(hero_id: String) -> bool:
	if party.size() >= 4:
		return false
	if is_hero_in_party(hero_id):
		return false
	if characters_data.has(hero_id):
		var member = characters_data[hero_id].duplicate(true)
		member["id"] = hero_id
		party.append(member)
		return true
	return false

func remove_hero_from_party(hero_id: String) -> bool:
	if hero_id == selected_hero_id:
		return false # El líder nunca puede ser removido
	for i in range(party.size()):
		if party[i].get("id", "") == hero_id:
			party.remove_at(i)
			return true
	return false

func toggle_hero_party(hero_id: String) -> bool:
	if is_hero_in_party(hero_id):
		return remove_hero_from_party(hero_id)
	else:
		return add_hero_to_party(hero_id)

func get_leader_data() -> Dictionary:
	return characters_data.get(selected_hero_id, characters_data["javier"])
