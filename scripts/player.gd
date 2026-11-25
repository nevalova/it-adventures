extends CharacterBody2D

const SpriteLayout = preload("res://scripts/sprite_layout.gd")

@export var speed: float = 140.0
@export var walk_anim_speed: float = 8.0

var facing_direction: Vector2 = Vector2.RIGHT
var is_moving: bool = false
var anim_timer: float = 0.0
var current_row: int = 6 # Row 6 = Este (Derecha)
var can_move: bool = true
var is_scripted_walking: bool = false

# Controles táctiles móviles
var dpad_up: bool = false
var dpad_down: bool = false
var dpad_left: bool = false
var dpad_right: bool = false

# Control tipo Análogo Arrastrable (Joystick)
var joystick_vector: Vector2 = Vector2.ZERO

# Control tipo Point and Click
var target_position: Vector2 = Vector2.ZERO
var is_navigating: bool = false
var stuck_timer: float = 0.0
var last_nav_pos: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite2D
@onready var name_tag = $NameTag

func navigate_to(pos: Vector2):
	target_position = pos
	is_navigating = true
	stuck_timer = 0.0
	last_nav_pos = global_position

func cancel_navigation():
	is_navigating = false
	stuck_timer = 0.0

func _ready():
	var leader = GameManager.get_leader_data()
	name_tag.text = leader["name"]
	
	if ResourceLoader.exists(leader.get("spritesheet_path", "")):
		sprite.texture = load(leader["spritesheet_path"])
		sprite.hframes = 4
		sprite.vframes = 12
		var ow_scale = leader.get("overworld_scale", Vector2(0.24, 0.24))
		sprite.scale = ow_scale
		if ow_scale.y > 0.25:
			sprite.position = Vector2(0, -11)
			name_tag.position.y = -36.0
		else:
			sprite.position = Vector2(0, -10)
			name_tag.position.y = -34.0
		current_row = 6
		sprite.frame = current_row * 4 + 0 # Mirando a la derecha
		facing_direction = Vector2.RIGHT

	SpriteLayout.configure(sprite, name_tag)
	y_sort_enabled = false

func play_walk_anim(dir: Vector2, frame_col: int):
	is_scripted_walking = true
	facing_direction = dir
	current_row = get_direction_row(dir)
	sprite.frame = current_row * 4 + (frame_col % 4)

func set_facing(dir: Vector2):
	is_scripted_walking = false
	facing_direction = dir
	current_row = get_direction_row(dir)
	sprite.frame = current_row * 4 + 0

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		is_moving = false
		cancel_navigation()
		if not is_scripted_walking:
			anim_timer = 0.0
			sprite.frame = current_row * 4 + 0
		move_and_slide()
		return
		
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

	# Si hay entrada por teclado, cancelar navegación automática
	if input_vector != Vector2.ZERO:
		cancel_navigation()

	# Modos táctiles según la configuración de GameManager
	if GameManager.control_type == "dpad":
		if dpad_left:
			input_vector.x = -1.0
		elif dpad_right:
			input_vector.x = 1.0
			
		if dpad_up:
			input_vector.y = -1.0
		elif dpad_down:
			input_vector.y = 1.0
	elif GameManager.control_type == "joystick":
		if joystick_vector.length() > 0.05:
			input_vector = joystick_vector
			cancel_navigation()
	elif GameManager.control_type == "point_and_click":
		if is_navigating:
			var diff = target_position - global_position
			if diff.length() <= 8.0:
				cancel_navigation()
			else:
				input_vector = diff.normalized()
				# Evitar atasco infinito en paredes
				if global_position.distance_to(last_nav_pos) < 0.6:
					stuck_timer += delta
					if stuck_timer > 0.4:
						cancel_navigation()
				else:
					stuck_timer = 0.0
					last_nav_pos = global_position

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
