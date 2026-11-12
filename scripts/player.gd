extends CharacterBody2D

@export var speed: float = 140.0

var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var anim_tick: float = 0.0

@onready var sprite = $Sprite2D

func _ready():
	# Color de acuerdo al héroe seleccionado
	var leader = GameManager.get_leader_data()
	$Sprite2D.self_modulate = leader["color"]
	$NameTag.text = leader["name"]

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Compatibilidad directa con WASD y flechas
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x = -1.0
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x = 1.0
		
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y = -1.0
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y = 1.0

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		facing_direction = input_vector
		velocity = input_vector * speed
		is_moving = true
		anim_tick += delta * 10.0
		# Pequeño bop retro estilo Chrono Trigger / FF6
		$Sprite2D.position.y = -4 + sin(anim_tick) * 2
	else:
		velocity = Vector2.ZERO
		is_moving = false
		$Sprite2D.position.y = -4

	move_and_slide()
	GameManager.player_saved_position = global_position
