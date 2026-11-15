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
		"user_name": "Mario (Compras)",
		"user_color": Color("#f59e0b"),
		"user_spritesheet": "res://assets/characters/npc_veterano_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_veterano_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con el procesador! La máquina huele a tostada y se congela cada que abro las cotizaciones.",
		"name": "Microprocesador Hirviendo",
		"type": "chip_cpu",
		"desc": "El procesador alcanzó 105°C por falta de pasta térmica y polvo acumulado.",
		"hp": 90,
		"max_hp": 90,
		"atk": 19,
		"def": 8,
		"exp_reward": 50,
		"texture_path": "res://assets/enemies/enemy_chip_cpu.png",
		"attacks": [
			"Thermal Throttling a 105°C",
			"Pasta Térmica Cristalizada",
			"Ventilador Bloqueado con Pelusa",
			"Kernel Panic por Temperatura"
		]
	},
	"usuario_red": {
		"user_name": "Diego (Desarrollo)",
		"user_color": Color("#38bdf8"),
		"user_spritesheet": "res://assets/characters/npc_coleta_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_coleta_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con mi conexión de red! Se me cayó el internet por completo tras un jalón con la silla.",
		"name": "Cable Ethernet Roto",
		"type": "cable_roto",
		"desc": "Arrancó el cable ethernet con la silla con ruedas y dejó los hilos de cobre al aire.",
		"hp": 95,
		"max_hp": 95,
		"atk": 20,
		"def": 10,
		"exp_reward": 50,
		"texture_path": "res://assets/enemies/enemy_cable_roto.png",
		"attacks": [
			"Arrancar Cable con la Silla",
			"Pisar el Patchcord",
			"Pares de Cobre Expuestos",
			"Cero Conectividad"
		]
	},
	"teclado": {
		"user_name": "Doña Brenda (Facturación)",
		"user_color": Color("#a855f7"),
		"user_spritesheet": "res://assets/characters/npc_curly_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_curly_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con el Wi-Fi! Se desconectó toda la oficina y no puedo timbrar las facturas del cierre.",
		"name": "Señal Wi-Fi Caída",
		"type": "nowifi",
		"desc": "La señal inalámbrica colapsó dejando a Facturación completamente desconectada.",
		"hp": 85,
		"max_hp": 85,
		"atk": 17,
		"def": 8,
		"exp_reward": 45,
		"texture_path": "res://assets/enemies/enemy_nowifi.png",
		"attacks": [
			"Sin Acceso a Internet",
			"Conflicto de Puerta de Enlace",
			"Router Sobrecalentado",
			"SSID Oculto Inaccesible"
		]
	},
	"cpu": {
		"user_name": "Laura (Archivo)",
		"user_color": Color("#f97316"),
		"user_spritesheet": "res://assets/characters/npc_pelirroja_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_pelirroja_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con mi CPU! Llegué hoy y solo veo la pantalla negra, ¡mi máquina no prende!",
		"name": "Gabinete PC Inerte",
		"type": "cpu_tower",
		"desc": "El gabinete no da señal de vida tras aplastarse debajo de tres cajas de archivo muerto.",
		"hp": 110,
		"max_hp": 110,
		"atk": 22,
		"def": 14,
		"exp_reward": 60,
		"texture_path": "res://assets/enemies/enemy_cpu_tower.png",
		"attacks": [
			"Botón de Encendido Atorado",
			"Polvo Acumulado de una Década",
			"Desconectar Cable de Poder con el Zapato",
			"Corto en Fuente Genérica"
		]
	},
	"wifi_phone": {
		"user_name": "Lic. de color serio (RH)",
		"user_color": Color("#10b981"),
		"user_spritesheet": "res://assets/characters/npc_techlead_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_techlead_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con mi celular! ¿Me lo conectan a la red de la empresa para ver mis mensajes?",
		"name": "Smartphone sin Wi-Fi",
		"type": "smartphone",
		"desc": "Exige que le configuren el celular personal para ver videos en el trabajo.",
		"hp": 80,
		"max_hp": 80,
		"atk": 17,
		"def": 9,
		"exp_reward": 45,
		"texture_path": "res://assets/enemies/enemy_smartphone.png",
		"attacks": [
			"Notificaciones de 50 Grupos de Chismes",
			"Olvido de Contraseña WPA2",
			"Descargar Serie en 4K en Red Corporativa",
			"Batería en 2% Pidiendo Cargador Tipo C"
		]
	},
	"bsod": {
		"user_name": "Ing. Fernando (Tech Lead)",
		"user_color": Color("#818cf8"),
		"user_spritesheet": "res://assets/characters/npc_ejecutivo_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_ejecutivo_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema crítico! Justo al compilar el release me saltó una pantalla azul de la muerte.",
		"name": "Pantalla Azul (BSOD)",
		"type": "bsod",
		"desc": "Falla de kernel catastrófica que reinicia la estación en bucle.",
		"hp": 115,
		"max_hp": 115,
		"atk": 23,
		"def": 12,
		"exp_reward": 65,
		"texture_path": "res://assets/enemies/enemy_bsod.png",
		"attacks": [
			"CRITICAL_PROCESS_DIED",
			"Kernel Security Check Failure",
			"Dump de Memoria al 100%",
			"Reinicio Infinito en Bucle"
		]
	}
}

func _ready():
	body_entered.connect(_on_body_entered)
	apply_spec()
	wander_direction = Vector2.ZERO

func apply_spec():
	var spec = enemy_specs.get(enemy_type, enemy_specs["printer"])
	
	if enemy_type == "printer":
		if ResourceLoader.exists(spec["texture_path"]):
			sprite.texture = load(spec["texture_path"])
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame = 0
		sprite.scale = Vector2(0.2, 0.2)
		if GameManager.printer_defeated:
			sprite.position = Vector2.ZERO
			name_tag.text = "[V] Neutralizada"
			name_tag.modulate = Color(0.3, 0.9, 0.6)
		else:
			name_tag.text = "[!] IMPRESORA MALDITA"
			name_tag.modulate = Color(1.0, 0.3, 0.3)
	else:
		if ResourceLoader.exists(spec.get("user_spritesheet", "")):
			sprite.texture = load(spec["user_spritesheet"])
		sprite.hframes = 4
		sprite.vframes = 12
		var tex = sprite.texture
		if tex and tex.get_height() < 1500:
			sprite.scale = Vector2(0.51, 0.51)
			name_tag.position.y = -28.0
		else:
			sprite.scale = Vector2(0.24, 0.24)
			name_tag.position.y = -24.0
		
		if enemy_id != "" and GameManager.defeated_enemies.has(enemy_id):
			name_tag.text = "[V] " + spec.get("user_name", "Usuario")
			name_tag.modulate = Color(0.3, 0.9, 0.5)
			sprite.frame = 8 * 4 + 0 # Frame relajado / alegre
		else:
			name_tag.text = spec.get("user_name", "Usuario")
			name_tag.modulate = spec.get("user_color", Color(1.0, 0.9, 0.4))
			sprite.frame = 0 * 4 + 0 # Mirando al frente atento
		move_speed = 0.0

func _process(delta):
	if enemy_type == "printer":
		if GameManager.printer_defeated:
			sprite.position = Vector2.ZERO
			return
		var shake = sin(Time.get_ticks_msec() * 0.04) * 1.8
		sprite.position.x = shake
		return

func pick_random_direction():
	wander_direction = Vector2.ZERO

func _on_body_entered(body):
	if body.name == "Player":
		if enemy_type == "printer":
			if GameManager.printer_defeated:
				return
			var overworld = get_parent()
			if overworld and overworld.has_method("_start_printer_battle"):
				overworld._start_printer_battle()
			return
			
		if is_encounter_triggered:
			return
			
		var overworld = get_parent()
		if not overworld:
			return
			
		var spec = enemy_specs.get(enemy_type, enemy_specs["outlook"]).duplicate(true)
		
		# Mirar hacia el jugador con la rotación exacta
		var diff = body.global_position - global_position
		if abs(diff.x) > abs(diff.y):
			sprite.frame = (6 if diff.x > 0 else 2) * 4 + 0
		else:
			sprite.frame = (0 if diff.y > 0 else 4) * 4 + 0
			
		# Si ya fue resuelto:
		if GameManager.defeated_enemies.has(enemy_id):
			is_encounter_triggered = true
			if overworld.has_method("show_solved_dialog"):
				overworld.show_solved_dialog(
					spec.get("user_name", "Usuario"),
					spec.get("user_portrait", ""),
					spec.get("user_color", Color.WHITE),
					"¡Muchas gracias por arreglar mi problema con %s! Ahora todo funciona excelente." % spec.get("name", "el equipo")
				)
			get_tree().create_timer(1.2).timeout.connect(func(): is_encounter_triggered = false)
			return
			
		is_encounter_triggered = true
		if overworld.has_method("start_encounter_dialog"):
			overworld.start_encounter_dialog(
				spec.get("user_name", "Usuario"),
				spec.get("user_portrait", ""),
				spec.get("user_color", Color.WHITE),
				spec.get("problem_dialog", "¡Ayuda, tengo un problema!"),
				spec,
				enemy_id
			)
		else:
			GameManager.player_saved_position = body.global_position
			GameManager.current_enemy_id = enemy_id
			GameManager.current_enemy_data = spec
			get_tree().change_scene_to_file("res://scenes/battle.tscn")
