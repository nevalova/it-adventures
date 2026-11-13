extends Area2D

@export var enemy_type: String = "printer" # "printer", "outlook", "usuario_red", "teclado", "cpu", "wifi_phone"
@export var enemy_id: String = ""
@export var move_speed: float = 30.0

var wander_direction: Vector2 = Vector2.ZERO
var change_timer: float = 0.0
var anim_timer: float = 0.0
var is_encounter_triggered: bool = false

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
		"user_name": "Lic. Sofía (Compras)",
		"user_color": Color("#f472b6"),
		"user_spritesheet": "res://assets/characters/usuaria_spritesheet.png",
		"user_portrait": "res://assets/characters/mariana_portrait.png",
		"problem_dialog": "¡Sistemas, qué bueno que pasas por aquí! Tengo que enviar las cotizaciones del mes y este Outlook no responde, ¡la barra lleva horas pegada en 'Sincronizando'!",
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
		"user_name": "Luis (Ventas)",
		"user_color": Color("#f59e0b"),
		"user_spritesheet": "res://assets/characters/roberto_huerta_spritesheet.png",
		"user_portrait": "res://assets/characters/carlos_portrait.png",
		"problem_dialog": "¡Auxilio Sistemas! ¡Se me fue el internet por completo y estoy en medio de cerrar una venta! Bueno... di un giro rápido con la silla de ruedas y sentí un jalón abajo del escritorio...",
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
		"user_name": "Hugo (Cobranza)",
		"user_color": Color("#38bdf8"),
		"user_spritesheet": "res://assets/characters/novato_spritesheet.png",
		"user_portrait": "res://assets/characters/carlos_portrait.png",
		"problem_dialog": "¡Hermano de Sistemas, sálvame! Estaba capturando las pólizas y de repente el teclado dejó de escribir. ¡Ya le pegué contra el escritorio y sigue sin prender el foquito!",
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
		"user_name": "Don Fernando (Archivo)",
		"user_color": Color("#c084fc"),
		"user_spritesheet": "res://assets/characters/israel_spritesheet.png",
		"user_portrait": "res://assets/characters/don_ramiro_portrait.png",
		"problem_dialog": "¡Oficial de Sistemas! ¡Me robaron el CPU de la oficina! ¡Llegué hoy y solo veo la pantalla negra, mi máquina desapareció! (Estaba sepultada bajo 4 cajas de carpetas)",
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
		"user_name": "Valeria (Marketing)",
		"user_color": Color("#34d399"),
		"user_spritesheet": "res://assets/characters/usuaria_spritesheet.png",
		"user_portrait": "res://assets/characters/usuaria_portrait.png",
		"problem_dialog": "¡Hola Sistemas! Oigan, una duda súper rápida... ¿me conectan mi celular personal a la red secreta de la empresa? Es que en el baño no me cargan los videos de TikTok...",
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
	if enemy_id != "" and GameManager.defeated_enemies.has(enemy_id):
		queue_free()
		return
		
	body_entered.connect(_on_body_entered)
	apply_spec()
	pick_random_direction()

func apply_spec():
	var spec = enemy_specs.get(enemy_type, enemy_specs["printer"])
	
	if enemy_type == "printer":
		if ResourceLoader.exists(spec["texture_path"]):
			sprite.texture = load(spec["texture_path"])
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame = 0
		sprite.scale = Vector2(0.2, 0.2)
		name_tag.text = "[!] IMPRESORA MALDITA"
		name_tag.modulate = Color(1.0, 0.3, 0.3)
	else:
		# En freeroam, el enemigo se ve como un USUARIO de oficina
		name_tag.text = spec.get("user_name", "Usuario")
		name_tag.modulate = spec.get("user_color", Color(1.0, 0.9, 0.4))
		if ResourceLoader.exists(spec.get("user_spritesheet", "")):
			sprite.texture = load(spec["user_spritesheet"])
		sprite.hframes = 4
		sprite.vframes = 12
		sprite.frame = 0
		sprite.scale = Vector2(0.24, 0.24)
		if enemy_type == "usuario_red":
			move_speed = 45.0
		elif enemy_type == "cpu":
			move_speed = 20.0

func _process(delta):
	if enemy_type == "printer":
		var shake = sin(Time.get_ticks_msec() * 0.04) * 1.8
		sprite.position.x = shake
		return
		
	if is_encounter_triggered:
		return
		
	change_timer -= delta
	if change_timer <= 0:
		pick_random_direction()
	
	position += wander_direction * move_speed * delta
	
	# Animación de pasos del usuario mientras camina
	anim_timer += delta
	var walk_frame = int(anim_timer * 6.0) % 4
	if wander_direction == Vector2.ZERO:
		sprite.frame = 0 * 4 + 0
	elif wander_direction.y > 0:
		sprite.frame = 0 * 4 + walk_frame # abajo
	elif wander_direction.x < 0:
		sprite.frame = 1 * 4 + walk_frame # izquierda
	elif wander_direction.x > 0:
		sprite.frame = 2 * 4 + walk_frame # derecha
	elif wander_direction.y < 0:
		sprite.frame = 3 * 4 + walk_frame # arriba
		
	position.x = clamp(position.x, 30.0, 1250.0)
	position.y = clamp(position.y, 40.0, 320.0)

func pick_random_direction():
	change_timer = randf_range(1.5, 3.5)
	var dirs = [Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	wander_direction = dirs[randi() % dirs.size()]

func _on_body_entered(body):
	if body.name == "Player":
		if enemy_type == "printer":
			if GameManager.printer_defeated:
				return
			# La impresora se maneja por su propio trigger / escena en overworld
			return
			
		if is_encounter_triggered:
			return
			
		is_encounter_triggered = true
		wander_direction = Vector2.ZERO
		
		# Mirar hacia el jugador
		var diff = body.global_position - global_position
		if abs(diff.x) > abs(diff.y):
			sprite.frame = (2 if diff.x > 0 else 1) * 4 + 0
		else:
			sprite.frame = (0 if diff.y > 0 else 3) * 4 + 0
			
		var spec = enemy_specs.get(enemy_type, enemy_specs["outlook"]).duplicate(true)
		var overworld = get_parent()
		if overworld and overworld.has_method("start_encounter_dialog"):
			overworld.start_encounter_dialog(
				spec.get("user_name", "Usuario"),
				spec.get("user_portrait", "res://assets/characters/usuaria_portrait.png"),
				spec.get("user_color", Color.WHITE),
				spec.get("problem_dialog", "¡Tengo un problema técnico!"),
				spec,
				enemy_id
			)
		else:
			# Fallback directo
			GameManager.player_saved_position = body.global_position
			GameManager.current_enemy_id = enemy_id
			GameManager.current_enemy_data = spec
			get_tree().change_scene_to_file("res://scenes/battle.tscn")
