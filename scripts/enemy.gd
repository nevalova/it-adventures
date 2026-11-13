extends Area2D

@export var enemy_type: String = "printer" # "printer", "outlook", "usuario_red", "teclado", "cpu", "wifi_phone"
@export var enemy_id: String = ""
@export var move_speed: float = 30.0

var wander_direction: Vector2 = Vector2.ZERO
var change_timer: float = 0.0

@onready var sprite = $Sprite2D
@onready var name_tag = $NameTag

var enemy_specs = {
	"printer": {
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
	},
	"outlook": {
		"name": "Outlook Congelado",
		"type": "outlook",
		"desc": "No recibe correos. Lleva 3 horas sincronizando y la barra no avanza.",
		"hp": 85,
		"max_hp": 85,
		"atk": 18,
		"def": 8,
		"exp_reward": 45,
		"texture_path": "res://assets/enemies/enemy_outlook.png",
		"attacks": [
			"Sincronizando 1 de 48,000 Correos",
			"Archivo PST Corrupto de 35 GB",
			"Ventana (No Responde)",
			"Spam Masivo con Tarjetas de Cumpleaños"
		]
	},
	"usuario_red": {
		"name": "Usuario Desconectado",
		"type": "usuario_red",
		"desc": "Arrancó el cable ethernet con la silla con ruedas y jura que 'el internet se cayó solo'.",
		"hp": 95,
		"max_hp": 95,
		"atk": 20,
		"def": 10,
		"exp_reward": 50,
		"texture_path": "res://assets/enemies/enemy_usuario_red.png",
		"attacks": [
			"Arrancar Cable de Red con la Silla",
			"Pisar el Patchcord",
			"Exigir que le conecten el celular al Wi-Fi",
			"Conflicto de IP 192.168.1.1"
		]
	},
	"teclado": {
		"name": "Teclado Sin Batería",
		"type": "teclado",
		"desc": "El usuario lo azota contra la mesa porque no escribe la contraseña.",
		"hp": 75,
		"max_hp": 75,
		"atk": 16,
		"def": 7,
		"exp_reward": 40,
		"texture_path": "res://assets/enemies/enemy_teclado.png",
		"attacks": [
			"Pila AA Sulfatada desde 2019",
			"Letra 'E' Atascada con Migajas de Pan",
			"Golpe Frustrado a la Barra Espaciadora",
			"Desconexión Bluetooth Fantasma"
		]
	},
	"cpu": {
		"name": "CPU Desaparecido",
		"type": "cpu",
		"desc": "El usuario jura que se lo robaron. Estaba debajo de tres cajas de archivo muerto.",
		"hp": 110,
		"max_hp": 110,
		"atk": 22,
		"def": 14,
		"exp_reward": 60,
		"texture_path": "res://assets/enemies/enemy_cpu.png",
		"attacks": [
			"Confundir el Monitor con el CPU",
			"Apagar con el Botón Directo a la Pared",
			"Polvo Acumulado de una Década",
			"Desconectar Cable de Poder con el Zapato"
		]
	},
	"wifi_phone": {
		"name": "Smartphone sin Wi-Fi",
		"type": "wifi_phone",
		"desc": "Exige que le configuren el celular personal para ver videos en el baño.",
		"hp": 80,
		"max_hp": 80,
		"atk": 17,
		"def": 9,
		"exp_reward": 45,
		"texture_path": "res://assets/enemies/enemy_wifi_phone.png",
		"attacks": [
			"Notificaciones de 50 Grupos de Chismes",
			"Olvido de Contraseña WPA2",
			"Descargar Serie en 4K en Red Corporativa",
			"Batería en 2% Pidiendo Cargador Tipo C"
		]
	}
}

func _ready():
	# Si este enemigo específico ya fue derrotado, eliminarlo
	if enemy_id != "" and GameManager.defeated_enemies.has(enemy_id):
		queue_free()
		return
		
	body_entered.connect(_on_body_entered)
	apply_spec()
	pick_random_direction()

func apply_spec():
	var spec = enemy_specs.get(enemy_type, enemy_specs["printer"])
	name_tag.text = spec["name"]
	if ResourceLoader.exists(spec["texture_path"]):
		sprite.texture = load(spec["texture_path"])
		
	if enemy_type == "printer":
		sprite.scale = Vector2(0.2, 0.2)
		name_tag.text = "[!] IMPRESORA MALDITA"
		name_tag.modulate = Color(1.0, 0.3, 0.3)
	else:
		sprite.scale = Vector2(0.48, 0.48)
		name_tag.modulate = Color(1.0, 0.6, 0.4)
		if enemy_type == "usuario_red":
			move_speed = 50.0
		elif enemy_type == "cpu":
			move_speed = 18.0

func _process(delta):
	if enemy_type == "printer":
		# La impresora vibra peligrosamente sobrecalentada
		var shake = sin(Time.get_ticks_msec() * 0.04) * 1.8
		sprite.position.x = shake
		return
		
	# Efecto visual sutil de flotación o vibración según el tipo
	if enemy_type == "outlook":
		sprite.position.y = sin(Time.get_ticks_msec() * 0.005) * 2.0
	elif enemy_type == "teclado":
		sprite.position.x = sin(Time.get_ticks_msec() * 0.03) * 0.8
		
	change_timer -= delta
	if change_timer <= 0:
		pick_random_direction()
	
	position += wander_direction * move_speed * delta
	
	# Mantener al enemigo dentro de los límites del mapa (0 a 1280, 40 a 330)
	position.x = clamp(position.x, 30.0, 1250.0)
	position.y = clamp(position.y, 40.0, 320.0)

func pick_random_direction():
	change_timer = randf_range(1.5, 3.5)
	var dirs = [Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	wander_direction = dirs[randi() % dirs.size()]

func _on_body_entered(body):
	if body.name == "Player":
		if enemy_type == "printer" and GameManager.printer_defeated:
			return # Ya fue derrotada, no reanudar combate
			
		GameManager.player_saved_position = body.global_position
		GameManager.current_enemy_id = enemy_id
		var spec = enemy_specs.get(enemy_type, enemy_specs["printer"]).duplicate(true)
		GameManager.current_enemy_data = spec
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
