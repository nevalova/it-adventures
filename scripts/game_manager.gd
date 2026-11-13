extends Node

# Autoload GameManager (Singleton)

var characters_data = {
	"javier": {
		"name": "Javier",
		"role": "Sysadmin Senior",
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
		"role": "Soporte Técnico Nivel 1",
		"title": "Pregunta: '¿Ya lo reinició?'",
		"description": "El salvador de usuarios despistados. Puede parchar cables y curar al equipo.",
		"max_hp": 125,
		"hp": 125,
		"atk": 22,
		"def": 14,
		"color": Color("#2ecc71"), # Verde
		"special_mechanic": "healer",
		"special_move_name": "Parche con Cinta y Cable UTP",
		"avatar_symbol": "[T]",
		"portrait_path": "res://assets/characters/tonazo_portrait.png",
		"spritesheet_path": "res://assets/characters/tonazo_spritesheet.png"
	},
	"israel": {
		"name": "Israel",
		"role": "Programador Fullstack",
		"title": "Commit Directo a Main",
		"description": "Consume litros de café. Lanza código espagueti con alto daño crítico.",
		"max_hp": 115,
		"hp": 115,
		"atk": 36,
		"def": 12,
		"color": Color("#e67e22"), # Naranja
		"special_mechanic": "critical_dev",
		"special_move_name": "Push a Producción en Viernes",
		"avatar_symbol": "[I]",
		"portrait_path": "res://assets/characters/israel_portrait.png",
		"spritesheet_path": "res://assets/characters/israel_spritesheet.png"
	},
	"juan_carlos": {
		"name": "Juan Carlos",
		"role": "Ciberseguridad & Redes",
		"title": "El Firewall Viviente",
		"description": "Excelente defensa, bloquea malware y satura al enemigo con DDoS.",
		"max_hp": 135,
		"hp": 135,
		"atk": 26,
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
		"role": "DBA & Datos",
		"title": "El Destructor de Tablas",
		"description": "Maestro del SQL. Su comando prohibido puede destruir servidores enteros.",
		"max_hp": 120,
		"hp": 120,
		"atk": 38,
		"def": 13,
		"color": Color("#e74c3c"), # Rojo
		"special_mechanic": "high_damage",
		"special_move_name": "DROP DATABASE CON ROOT",
		"avatar_symbol": "[A]",
		"portrait_path": "res://assets/characters/alejandro_portrait.png",
		"spritesheet_path": "res://assets/characters/alejandro_spritesheet.png"
	}
}

var selected_hero_id: String = "javier"
var party: Array = []
var player_saved_position: Vector2 = Vector2(320, 240)
var current_enemy_data: Dictionary = {}
var victorious_count: int = 0

func _ready():
	# Party por defecto con los héroes principales
	init_party("javier")

func init_party(leader_id: String):
	selected_hero_id = leader_id
	party.clear()
	# El líder va de primero
	party.append(characters_data[leader_id].duplicate(true))
	
	# Agregamos a los otros compañeros para formar el squad de IT
	for id in characters_data.keys():
		if id != leader_id and party.size() < 4:
			party.append(characters_data[id].duplicate(true))

func get_leader_data() -> Dictionary:
	return characters_data.get(selected_hero_id, characters_data["javier"])
