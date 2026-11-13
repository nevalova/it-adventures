extends CharacterBody2D

@export var speed: float = 140.0
@export var walk_anim_speed: float = 8.0

var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var anim_timer: float = 0.0
var current_row: int = 0

# Controles táctiles móviles
var dpad_up: bool = false
var dpad_down: bool = false
var dpad_left: bool = false
var dpad_right: bool = false

@onready var sprite = $Sprite2D
@onready var name_tag = $NameTag

func _ready():
	var leader = GameManager.get_leader_data()
	name_tag.text = leader["name"]
	
	if ResourceLoader.exists(leader.get("spritesheet_path", "")):
		sprite.texture = load(leader["spritesheet_path"])
		sprite.hframes = 4
		sprite.vframes = 12
		sprite.scale = Vector2(0.24, 0.24)
		sprite.frame = 0 # Fila 0, frame 0 = Mirando al frente hacia abajo

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Compatibilidad con teclado (WASD y flechas)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x = -1.0
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x = 1.0
		
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y = -1.0
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y = 1.0

	# Compatibilidad con controles táctiles móviles
	if dpad_left:
		input_vector.x = -1.0
	elif dpad_right:
		input_vector.x = 1.0
		
	if dpad_up:
		input_vector.y = -1.0
	elif dpad_down:
		input_vector.y = 1.0

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		facing_direction = input_vector
		current_row = get_direction_row(input_vector)
		velocity = input_vector * speed
		is_moving = true
		
		anim_timer += delta * walk_anim_speed
		var col = int(anim_timer) % 4
		sprite.frame = current_row * 4 + col
	else:
		velocity = Vector2.ZERO
		is_moving = false
		anim_timer = 0.0
		sprite.frame = current_row * 4 + 0

	move_and_slide()
	GameManager.player_saved_position = global_position

func get_direction_row(dir: Vector2) -> int:
	var dx = 0
	var dy = 0
	if dir.x > 0.3: dx = 1
	elif dir.x < -0.3: dx = -1
	
	if dir.y > 0.3: dy = 1
	elif dir.y < -0.3: dy = -1
	
	# Mapeo visual de 8 direcciones del tileset (Rotación horaria):
	# Row 0: Sur (Abajo / Frente)
	# Row 1: Sur-Oeste (Abajo-Izquierda)
	# Row 2: Oeste (Izquierda)
	# Row 3: Nor-Oeste (Arriba-Izquierda)
	# Row 4: Norte (Arriba / Espalda)
	# Row 5: Nor-Este (Arriba-Derecha)
	# Row 6: Este (Derecha)
	# Row 7: Sur-Este (Abajo-Derecha)
	if dy > 0:
		if dx < 0: return 1   # Abajo-Izquierda
		elif dx > 0: return 7  # Abajo-Derecha
		else: return 0        # Abajo (Frente)
	elif dy < 0:
		if dx < 0: return 3   # Arriba-Izquierda
		elif dx > 0: return 5  # Arriba-Derecha
		else: return 4        # Arriba (Espalda)
	else:
		if dx < 0: return 2   # Izquierda
		elif dx > 0: return 6  # Derecha
		else: return current_row
