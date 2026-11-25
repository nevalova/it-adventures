extends SceneTree

var failures: Array[String] = []

func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var gm = root.get_node("GameManager")
	gm.init_party("javier")
	gm.party[0]["hp"] = 17
	gm.add_exp_to_party(1)
	check(gm.party[0]["hp"] == 17, "EXP without level-up must preserve battle HP")
	var before = gm.characters_data["javier"].duplicate(true)
	gm.add_exp_to_party(160)
	check(gm.party[0]["level"] > before["level"], "Small problems must grant levels")
	check(gm.party[0]["atk"] > before["atk"] and gm.party[0]["def"] > before["def"], "Levels must increase attack and defense")
	check(gm.party[0]["hp"] == gm.party[0]["max_hp"], "Level-up must restore HP")
	gm.intro_cutscene_done = true
	gm.player_saved_position = Vector2(140, 200)
	var world = load("res://scenes/overworld.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	await physics_frame
	check(world.y_sort_enabled, "World must sort actors and furniture together")
	check(not world.player.y_sort_enabled, "Player sprite and label must be one sorting unit")
	check(world.can_ambient_npcs_walk(), "NPCs must be able to walk during free exploration")
	var checked = 0
	for actor in world.get_children():
		var sprite = actor.get_node_or_null("Sprite2D") as Sprite2D
		if sprite and sprite.hframes == 4 and sprite.vframes == 12:
			check(not actor.y_sort_enabled, "Actor must sort atomically: " + str(actor.name))
			var image = sprite.texture.get_image()
			var cell = Vector2i(image.get_width() / 4, image.get_height() / 12)
			var bounds = image.get_region(Rect2i(Vector2i.ZERO, cell)).get_used_rect()
			var height = bounds.size.y * sprite.scale.y
			check(absf(height - (42.0 if actor.name == "DragonBoss" else 38.0)) < 0.1, "Wrong visual height: " + str(actor.name))
			check(absf(sprite.position.y + (bounds.end.y - cell.y * 0.5) * sprite.scale.y) < 0.1, "Feet not anchored: " + str(actor.name))
			checked += 1
	check(checked >= 10, "All office actors must be validated")
	var walker: Node2D
	for actor in world.get_children():
		if actor.get_script() == load("res://scripts/enemy.gd") and actor.enemy_type != "printer":
			walker = actor
			break
	check(walker != null, "Expected an ambient walker")
	if walker:
		walker.global_position = Vector2(800, 205)
		walker.home_position = walker.global_position
		walker.wander_target = walker.global_position + Vector2(30, 0)
		walker.change_timer = 10.0
		var start = walker.global_position
		for i in range(30):
			await physics_frame
		check(walker.global_position.distance_to(start) > 1.0, "Walker must advance through a clear corridor")
		world.player.can_move = false
		var paused = walker.global_position
		for i in range(5):
			await physics_frame
		check(walker.global_position == paused, "Walker must pause during dialogue")
		world.player.can_move = true
		walker.global_position = Vector2(640, 84)
		walker.home_position = walker.global_position
		walker.wander_target = Vector2(710, 84)
		walker.change_timer = 10.0
		for i in range(120):
			await physics_frame
		check(walker.global_position.x <= 653.0, "Walker must stop at furniture, not cross it")
		world.player.can_move = false
	if "--visual" in OS.get_cmdline_user_args():
		world.player.global_position = Vector2(345, 125)
		world.player.set_facing(Vector2.DOWN)
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/it-adventures-desk-behind.png")
		world.player.global_position = Vector2(345, 175)
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/it-adventures-desk-front.png")
	print("IT_ADVENTURES_CHECKS actors=", checked, " failures=", failures.size())
	world.queue_free()
	await process_frame
	drain_pending_loads(gm)
	quit(0 if failures.is_empty() else 1)

func drain_pending_loads(gm):
	for path in ["res://scenes/character_select.tscn", "res://scenes/overworld.tscn", "res://scenes/battle.tscn"]:
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	gm.preloaded_scenes.clear()
