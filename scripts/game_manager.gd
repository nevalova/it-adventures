extends Node

# Autoload GameManager (Singleton)

var characters_data = {
	"javier": {
		"name": "Javier",
		"role": "Soporte Técnico",
		"title": "El Procrastinador de Servidores",
		"description": "Ataca un turno sí y otro no (un turno descansa o ve memes, al siguiente pega brutal).",
		"max_hp": 160,
		"hp": 160,
		"atk": 42,
		"def": 18,
		"color": Color("#3498db"), # Azul
		"special_mechanic": "one_turn_skip", # Ataca un turno si y otro no
		"special_move_name": "Reinicio Forzado al Rack",
		"avatar_symbol": "[J]",
		"portrait_path": "res://assets/characters/javier_portrait.png",
		"spritesheet_path": "res://assets/characters/javier_spritesheet.png"
	},
	"tonazo": {
		"name": "Toñazo",
		"role": "Soporte Técnico",
		"title": "El de la USB Azul Milagrosa",
		"description": "Lleva la memoria USB booteable en el cuello. Parchea cables y revive cualquier PC.",
		"max_hp": 125,
		"hp": 125,
		"atk": 25,
		"def": 15,
		"color": Color("#2ecc71"), # Verde
		"special_mechanic": "healer",
		"special_move_name": "USB Booteable con Linux Milagroso",
		"avatar_symbol": "[T]",
		"portrait_path": "res://assets/characters/tonazo_portrait.png",
		"spritesheet_path": "res://assets/characters/tonazo_spritesheet.png"
	},
	"juan_carlos": {
		"name": "Juan Carlos",
		"role": "El Top Gun",
		"title": "Es la mera reata hasta arriba",
		"description": "Elegante, implacable y con autoridad absoluta. Cuando Juan habla, todos los servidores se alinean.",
		"max_hp": 140,
		"hp": 140,
		"atk": 30,
		"def": 22,
		"color": Color("#9b59b6"), # Morado
		"special_mechanic": "shield_tank",
		"special_move_name": "Ataque DDoS con la Cafetera",
		"avatar_symbol": "[JC]",
		"portrait_path": "res://assets/characters/juan_carlos_portrait.png",
		"spritesheet_path": "res://assets/characters/juan_carlos_spritesheet.png"
	},
	"alejandro": {
		"name": "Alejandro",
		"role": "Soporte Técnico",
		"title": "Resiliencia Total",
		"description": "La leyenda dice que estuvo 20 horas esperando por un iPhone que ni era de él. Sobrevive a base de Pepsi y el odio que le tiene al mundo.",
		"max_hp": 130,
		"hp": 130,
		"atk": 38,
		"def": 18,
		"color": Color("#e67e22"), # Naranja
		"special_mechanic": "critical_dev",
		"special_move_name": "Mañana no vengo, voy a Chilpancingo",
		"avatar_symbol": "[A]",
		"portrait_path": "res://assets/characters/alejandro_portrait.png",
		"spritesheet_path": "res://assets/characters/alejandro_spritesheet.png"
	},
	"israel": {
		"name": "Israel",
		"role": "Soporte Técnico",
		"title": "El Guardián Veterano",
		"description": "El sabio de la barba plateada. Maestro del SQL cuyo comando DROP DATABASE causa pánico.",
		"max_hp": 130,
		"hp": 130,
		"atk": 40,
		"def": 16,
		"color": Color("#e74c3c"), # Rojo
		"special_mechanic": "high_damage",
		"special_move_name": "DROP DATABASE CON ROOT",
		"avatar_symbol": "[I]",
		"portrait_path": "res://assets/characters/israel_portrait.png",
		"spritesheet_path": "res://assets/characters/israel_spritesheet.png"
	}
}

var selected_hero_id: String = "javier"
var party: Array = []
var player_saved_position: Vector2 = Vector2(140, 200)
var current_enemy_data: Dictionary = {}
var victorious_count: int = 0
var intro_cutscene_done: bool = false
var office_cutscene_done: bool = false
var printer_defeated: bool = false

var battle_items = {
	"cafe": {"name": "Café Espresso Doble", "heal": 45, "count": 4, "desc": "Cura 45 HP"},
	"dona": {"name": "Dona Glaseada RH", "heal": 85, "count": 3, "desc": "Cura 85 HP"},
	"monster": {"name": "Bebida Energética 500ml", "heal": 140, "count": 2, "desc": "Cura 140 HP"}
}

func reset_battle_items():
	battle_items["cafe"]["count"] = 4
	battle_items["dona"]["count"] = 3
	battle_items["monster"]["count"] = 2

func _ready():
	# Party por defecto con los héroes principales
	init_party("javier")

func init_party(leader_id: String):
	selected_hero_id = leader_id
	party.clear()
	reset_battle_items()
	printer_defeated = false
	# El líder va de primero
	party.append(characters_data[leader_id].duplicate(true))
	
	# Agregamos a los otros compañeros para formar el squad de IT
	for id in characters_data.keys():
		if id != leader_id and party.size() < 4:
			party.append(characters_data[id].duplicate(true))

func get_leader_data() -> Dictionary:
	return characters_data.get(selected_hero_id, characters_data["javier"])
