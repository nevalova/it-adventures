extends Node2D

@onready var player = $Player
@onready var hud_hero_name = $CanvasLayer/HUD/HeroInfo/HeroName
@onready var hud_hero_role = $CanvasLayer/HUD/HeroInfo/HeroRole
@onready var hud_stats = $CanvasLayer/HUD/HeroInfo/HeroStats
@onready var btn_switch = $CanvasLayer/HUD/TouchControls/RightBox/SwitchBtn

# Botones táctiles virtuales
@onready var btn_up = $CanvasLayer/HUD/TouchControls/DpadBox/BtnUp
@onready var btn_down = $CanvasLayer/HUD/TouchControls/DpadBox/BtnDown
@onready var btn_left = $CanvasLayer/HUD/TouchControls/DpadBox/BtnLeft
@onready var btn_right = $CanvasLayer/HUD/TouchControls/DpadBox/BtnRight

func _ready():
	var leader = GameManager.get_leader_data()
	hud_hero_name.text = leader["name"]
	hud_hero_role.text = leader["role"]
	hud_stats.text = "HP: %d/%d  |  ATQ: %d" % [leader["hp"], leader["max_hp"], leader["atk"]]
	hud_hero_name.modulate = leader["color"]
	
	if GameManager.player_saved_position != Vector2.ZERO:
		player.global_position = GameManager.player_saved_position
	
	btn_switch.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
	)
	
	# Conexión táctil del D-Pad
	btn_up.button_down.connect(func(): player.dpad_up = true)
	btn_up.button_up.connect(func(): player.dpad_up = false)
	
	btn_down.button_down.connect(func(): player.dpad_down = true)
	btn_down.button_up.connect(func(): player.dpad_down = false)
	
	btn_left.button_down.connect(func(): player.dpad_left = true)
	btn_left.button_up.connect(func(): player.dpad_left = false)
	
	btn_right.button_down.connect(func(): player.dpad_right = true)
	btn_right.button_up.connect(func(): player.dpad_right = false)
