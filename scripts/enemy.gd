extends Area2D

const SpriteLayout = preload("res://scripts/sprite_layout.gd")
var home_position: Vector2
var wander_target: Vector2
var walk_clock: float = 0.0
var facing_row: int = 0

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
		"exp_reward": 250,
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
		"user_spritesheet": "res://assets/characters/npc_pelirroja_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_pelirroja_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con el procesador! La máquina huele a tostada y se congela cada que abro las cotizaciones.",
		"name": "Microprocesador Hirviendo",
		"type": "chip_cpu",
		"desc": "El procesador alcanzó 105°C por falta de pasta térmica y polvo acumulado.",
		"hp": 55,
		"max_hp": 55,
		"atk": 14,
		"def": 4,
		"exp_reward": 160,
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
		"hp": 55,
		"max_hp": 55,
		"atk": 15,
		"def": 4,
		"exp_reward": 160,
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
		"user_spritesheet": "res://assets/characters/npc_ejecutivo_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_ejecutivo_portrait.png",
		"problem_dialog": "¡Ayuda muchachos de TI! No puedo timbrar las facturas del cierre porque la máquina se quedó sin señal de red...",
		"name": "Señal Wi-Fi Caída",
		"type": "nowifi",
		"desc": "La señal inalámbrica colapsó dejando a Facturación completamente desconectada.",
		"hp": 50,
		"max_hp": 50,
		"atk": 12,
		"def": 4,
		"exp_reward": 150,
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
		"user_spritesheet": "res://assets/characters/npc_veterano_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_veterano_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con mi CPU! Llegué hoy y solo veo la pantalla negra, ¡mi máquina no prende!",
		"name": "Gabinete PC Inerte",
		"type": "cpu_tower",
		"desc": "El gabinete no da señal de vida tras aplastarse debajo de tres cajas de archivo muerto.",
		"hp": 65,
		"max_hp": 65,
		"atk": 15,
		"def": 5,
		"exp_reward": 180,
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
		"user_spritesheet": "res://assets/characters/npc_curly_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_curly_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema con mi celular! ¿Me lo conectan a la red de la empresa para ver mis mensajes?",
		"name": "Smartphone sin Wi-Fi",
		"type": "smartphone",
		"desc": "Exige que le configuren el celular personal para ver videos en el trabajo.",
		"hp": 50,
		"max_hp": 50,
		"atk": 13,
		"def": 4,
		"exp_reward": 150,
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
		"user_spritesheet": "res://assets/characters/npc_coleta_spritesheet.png",
		"user_portrait": "res://assets/characters/npc_coleta_portrait.png",
		"problem_dialog": "¡Ayuda, tengo un problema crítico! Justo al compilar el release me saltó una pantalla azul de la muerte.",
		"name": "Pantalla Azul (BSOD)",
		"type": "bsod",
		"desc": "Falla de kernel catastrófica que reinicia la estación en bucle.",
		"hp": 70,
		"max_hp": 70,
		"atk": 16,
		"def": 5,
		"exp_reward": 200,
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
	home_position = global_position
	wander_target = home_position
	change_timer = randf_range(1.0, 3.0)
	y_sort_enabled = false

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
			sprite.position = Vector2(0, -19)
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
			sprite.scale = Vector2(0.48, 0.48)
			sprite.position = Vector2(0, -20)
			name_tag.position.y = -38.0
		else:
			sprite.scale = Vector2(0.24, 0.24)
			sprite.position = Vector2(0, -10)
			name_tag.position.y = -34.0
		
		if enemy_id != "" and GameManager.defeated_enemies.has(enemy_id):
			name_tag.text = "[V] " + spec.get("user_name", "Usuario")
			name_tag.modulate = Color(0.3, 0.9, 0.5)
			sprite.frame = 8 * 4 + 0 # Frame relajado / alegre
		else:
			name_tag.text = spec.get("user_name", "Usuario")
			name_tag.modulate = spec.get("user_color", Color(1.0, 0.9, 0.4))
			sprite.frame = 0 * 4 + 0 # Mirando al frente atento
		move_speed = 22.0
		SpriteLayout.configure(sprite, name_tag)

func _process(delta):
	if enemy_type == "printer":
		if GameManager.printer_defeated:
			sprite.position = Vector2(0, -19)
			return
		var shake = sin(Time.get_ticks_msec() * 0.04) * 1.8
		sprite.position.x = shake
		return

func pick_random_direction():
	# Short trips around the workstation; never leave the office corridor.
	var choices = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	wander_direction = choices[randi() % choices.size()]
	wander_target = home_position + wander_direction * randf_range(24.0, 48.0)
	wander_target.y = clampf(wander_target.y, 65.0, 300.0)
	change_timer = randf_range(2.0, 4.0)

func _physics_process(delta: float):
	if enemy_type == "printer":
		return
	var world = get_parent()
	if not world.has_method("can_ambient_npcs_walk") or not world.can_ambient_npcs_walk():
		return
	var leader = world.get_node_or_null("Player")
	if is_instance_valid(leader) and global_position.distance_to(leader.global_position) < 34.0:
		return
	change_timer -= delta
	if change_timer <= 0.0:
		pick_random_direction()
	var offset = wander_target - global_position
	if offset.length() < 2.0:
		sprite.frame = facing_row * 4
		return
	var direction = offset.normalized()
	var step = direction * minf(move_speed * delta, offset.length())
	var query = PhysicsShapeQueryParameters2D.new()
	var feet = CircleShape2D.new()
	feet.radius = 8.0
	query.shape = feet
	query.transform = Transform2D(0.0, global_position + Vector2(0, 4))
	query.motion = step
	query.collision_mask = 2
	var safe_motion = get_world_2d().direct_space_state.cast_motion(query)
	query.transform.origin += step
	if safe_motion[0] < 1.0 or not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
		wander_target = global_position
		change_timer = 0.5
		sprite.frame = facing_row * 4
		return
	global_position += step
	facing_row = (6 if direction.x > 0 else 2) if absf(direction.x) > absf(direction.y) else (0 if direction.y > 0 else 4)
	walk_clock += delta * 6.0
	sprite.frame = facing_row * 4 + int(walk_clock) % 4

func _on_body_entered(body):
	if body.name == "Player":
		if enemy_type == "printer":
			if GameManager.printer_defeated:
				return
			var overworld = get_tree().current_scene
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
					"¡Muchas gracias por arreglar mi problema con %s! Su equipo de TI subió de nivel y ahora tienen más vida y fuerza para derrotar al Señor del Dragón." % spec.get("name", "el equipo")
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
