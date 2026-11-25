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
	gm.init_party("javier")
	gm.intro_cutscene_done = false
	gm.office_cutscene_done = false
	check(gm.party.size() == 1, "New game must start with only the selected hero")
	var world = load("res://scenes/overworld.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	world.roberto.position.x = 200
	world._process(0)
	check(world.dialog_box.visible, "Roberto must still deliver the printer report")
	world._advance_dialog()
	world._advance_dialog()
	check(gm.intro_cutscene_done, "Roberto report must finish normally")
	check(world.current_state == world.State.FREE_EXPLORE, "Roberto must wait after his report")
	check(world.site_exit_barrier.collision_layer == 2, "Solo exit must be physically blocked")
	check(world.companion_nodes.size() == 4, "Exactly four unselected heroes must occupy desks")
	check(not world.has_node("DeskIT2"), "Fifth starting desk must be removed")
	check(world.get_node("Nelly").position.x > 588, "Nelly must be outside the starting site")
	for hero_id in world.companion_nodes:
		var actor = world.companion_nodes[hero_id]
		check(actor.position == actor.get_meta("office_pos"), "Every companion must start at a desk")
	world.player.position = Vector2(540, 190)
	world._physics_process(0.016)
	check(world.dialog_speaker.text == "Personaje Legalmente Seguro", "Exit warning must use the censored character")
	check(world.dialog_message.text.contains("te comerán vivo"), "Exit warning must explain the danger")
	check(world.player.position.x <= 525 and not world.player.can_move, "Exit warning must keep player inside")
	world._advance_dialog()
	world._on_office_trigger_entered(world.player)
	check(not gm.office_cutscene_done, "Finance scene must not start without four heroes")
	world._advance_dialog()
	# Recruit the first three desk heroes and keep the fourth available.
	var recruited = 0
	for hero_id in world.companion_nodes:
		if recruited < 3:
			gm.add_hero_to_party(hero_id)
			recruited += 1
	world._refresh_team_departure()
	check(gm.party.size() == 4, "Three recruits must fill the party")
	check(world.site_exit_barrier.collision_layer == 0, "Complete party must unlock the exit")
	check(world.current_state == world.State.ROBERTO_RUN_TO_OFFICE, "Roberto must leave only after recruitment")
	world.player.position = Vector2(400, 210)
	world._update_stationed_companions()
	for hero_id in world.companion_nodes:
		var actor = world.companion_nodes[hero_id]
		check(actor.position == actor.get_meta("office_pos"), "Recruited companions must never follow the player")
	if "--visual" in OS.get_cmdline_user_args():
		world.player.position = Vector2(300, 205)
		world.player.can_move = false
		world.roberto.position = Vector2(500, 190)
		world.current_state = world.State.FREE_EXPLORE
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/it-adventures-four-desks.png")
	# Losing a teammate before departure must close the gate again.
	gm.remove_hero_from_party(gm.party[1]["id"])
	world.player.can_move = true
	world._refresh_team_departure()
	check(world.site_exit_barrier.collision_layer == 2, "Removing a recruit must re-lock the departure gate")
	check(world.current_state != world.State.ROBERTO_RUN_TO_OFFICE, "Roberto must wait again if team becomes incomplete")
	if "--visual" in OS.get_cmdline_user_args():
		world.player.position = Vector2(540, 190)
		world._physics_process(0.016)
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/it-adventures-team-warning.png")
	print("TEAM_DEPARTURE_CHECKS failures=", failures.size())
	world.queue_free()
	await process_frame
	drain_pending_loads(gm)
	quit(0 if failures.is_empty() else 1)

func drain_pending_loads(gm):
	for path in ["res://scenes/character_select.tscn", "res://scenes/overworld.tscn", "res://scenes/battle.tscn"]:
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	gm.preloaded_scenes.clear()
