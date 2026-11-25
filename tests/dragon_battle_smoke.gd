extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var gm = root.get_node("GameManager")
	gm.init_party("javier")
	gm.current_enemy_data = {
		"type": "dragon_boss", "name": "El Señor del Dragón",
		"hp": 280, "max_hp": 280, "atk": 14, "def": 6,
		"spritesheet_path": "res://assets/characters/dragon_boss_battle_spritesheet.png"
	}
	var battle = load("res://scenes/battle.tscn").instantiate()
	root.add_child(battle)
	current_scene = battle
	await process_frame
	Engine.time_scale = 10.0
	# Exercise every dragon animation frame and verify atlas bounds.
	await battle.play_dragon_special_anim("Javier")
	var region: Rect2 = battle.boss_atlas.region
	var texture_size: Vector2 = battle.boss_atlas.atlas.get_size()
	assert(Rect2(Vector2.ZERO, texture_size).encloses(region))
	var previous_hp: int = battle.battle_party[0]["hp"]
	await battle.enemy_turn()
	assert(battle.dragon_special_cooldown == 1, "Dragon must not use its special on its first turn")
	assert(battle.battle_party[0]["hp"] > 0)
	print("DRAGON_BATTLE_SMOKE passed: special animation, atlas and first-turn cooldown")
	battle.queue_free()
	await process_frame
	drain_pending_loads(gm)
	quit()

func drain_pending_loads(gm):
	for path in ["res://scenes/character_select.tscn", "res://scenes/overworld.tscn", "res://scenes/battle.tscn"]:
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	gm.preloaded_scenes.clear()
