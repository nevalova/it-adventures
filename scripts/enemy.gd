extends Area2D

@export var enemy_type: String = "printer" # "printer" o "bug"
@export var move_speed: float = 30.0

var wander_direction: Vector2 = Vector2.ZERO
var change_timer: float = 0.0

@onready var sprite = $Sprite2D
@onready var name_tag = $NameTag

var enemy_specs = {
	"printer": {
		"name": "Impresora Maldita",
		"desc": "Tiene atasco de papel, no tiene tóner y huele a quemado.",
		"hp": 90,
		"max_hp": 90,
		"atk": 20,
		"def": 8,
		"texture_path": "res://assets/printer_enemy.png",
		"attacks": ["Lanzar Tóner Ardiente", "Atasco de Papel Infinito", "Error 404 No Responde"]
	},
	"bug": {
		"name": "Bug de Producción",
		"desc": "Apareció en viernes a las 6:50 PM. Es impredecible y hace daño masivo.",
		"hp": 110,
		"max_hp": 110,
		"atk": 25,
		"def": 12,
		"texture_path": "res://assets/bug_enemy.png",
		"attacks": ["NullPointerException", "Memory Leak Fatal", "Loop Infinito"]
	}
}

func _ready():
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

func _process(delta):
	if enemy_type == "printer":
		# La impresora vibra peligrosamente sobrecalentada
		var shake = sin(Time.get_ticks_msec() * 0.04) * 1.8
		sprite.position.x = shake
		return
		
	change_timer -= delta
	if change_timer <= 0:
		pick_random_direction()
	
	position += wander_direction * move_speed * delta

func pick_random_direction():
	change_timer = randf_range(1.5, 3.5)
	var dirs = [Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	wander_direction = dirs[randi() % dirs.size()]

func _on_body_entered(body):
	if body.name == "Player":
		var spec = enemy_specs.get(enemy_type, enemy_specs["printer"]).duplicate(true)
		GameManager.current_enemy_data = spec
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
