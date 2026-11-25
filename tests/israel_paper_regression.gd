extends SceneTree

var failures: Array[String] = []

func check(value: bool, message: String):
	if not value:
		failures.append(message)
		push_error(message)

func _initialize():
	call_deferred("run")

func run():
	var gm = root.get_node("GameManager")
	gm.init_party("israel")
	for id in ["javier", "tonazo", "juan_carlos"]:
		gm.add_hero_to_party(id)
	gm.intro_cutscene_done = true
	gm.office_cutscene_done = true
	gm.paper_quest_state = 0
	gm.paper_quest_accepted = false
	gm.player_saved_position = Vector2(850, 220)
	var world = load("res://scenes/overworld.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	gm.printer_defeated = true
	world._set_interactable("supply_paper_box")
	world._trigger_current_interaction()
	check(gm.paper_quest_state == 0, "Cannot collect paper before receiving the request")
	world._advance_dialog()
	world._set_interactable("director")
	world._trigger_current_interaction()
	check(world.dialog_speaker.text == "Personaje Legalmente Seguro", "Censored character must give the paper mission")
	check(gm.paper_quest_accepted, "Talking to the director must grant the mission")
	world._advance_dialog()
	world._set_interactable("supply_paper_box")
	world._trigger_current_interaction()
	check(gm.paper_quest_state == 1, "Accepted mission must allow collecting delivery paper")
	world._advance_dialog()
	if "--visual" in OS.get_cmdline_user_args():
		world.player.can_move = false
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/it-adventures-nelly-paper.png")
	world.queue_free()
	await process_frame
	gm.current_enemy_data = {"type": "senor_apoyo", "name": "El Señor", "hp": 1, "max_hp": 1, "atk": 1}
	var battle = load("res://scenes/battle.tscn").instantiate()
	root.add_child(battle)
	current_scene = battle
	await process_frame
	check(battle.boss_frame_row == 6, "Israel's opponent must face right")
	check(battle.boss_frame_col == 0, "Opponent must use a planted idle pose")
	var original_region = battle.boss_atlas.region
	for i in range(3):
		battle._process(0.5)
	check(battle.boss_atlas.region == original_region, "Idle must never cycle through walking poses")
	var leader = gm.get_leader_data()
	var image = load(leader["spritesheet_path"]).get_image()
	var cell = Vector2i(image.get_width() / 4, image.get_height() / 12)
	var hero_bounds = image.get_region(Rect2i(Vector2i(0, cell.y * 2), cell)).get_used_rect()
	var hero_height = hero_bounds.size.y * leader["battle_scale"].y
	var enemy_bounds = battle.boss_atlas.atlas.get_image().get_region(Rect2i(battle.boss_atlas.region)).get_used_rect()
	var enemy_height = enemy_bounds.size.y * battle.enemy_sprite.size.y / battle.boss_cell_size
	check(absf(hero_height - enemy_height) < 1.0, "Opponent must match the hero's visible size")
	if "--visual" in OS.get_cmdline_user_args():
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/it-adventures-israel-battle.png")
	print("ISRAEL_PAPER_CHECKS failures=", failures.size())
	battle.queue_free()
	await process_frame
	drain_pending_loads(gm)
	quit(0 if failures.is_empty() else 1)

func drain_pending_loads(gm):
	for path in ["res://scenes/character_select.tscn", "res://scenes/overworld.tscn", "res://scenes/battle.tscn"]:
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	gm.preloaded_scenes.clear()
