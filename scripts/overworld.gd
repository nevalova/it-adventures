extends Node2D

@onready var player = $Player
@onready var hud_hero_name = $CanvasLayer/HUD/HeroInfo/HeroName
@onready var hud_hero_role = $CanvasLayer/HUD/HeroInfo/HeroRole
@onready var hud_stats = $CanvasLayer/HUD/HeroInfo/HeroStats
@onready var btn_switch = $CanvasLayer/HUD/SwitchBtn

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
