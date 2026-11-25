extends SceneTree

var failures: Array[String] = []

func check(value: bool, message: String):
	if not value:
		failures.append(message)
		push_error(message)

func _initialize():
	call_deferred("run")

func drain_preloads(gm):
	for path in ["res://scenes/character_select.tscn", "res://scenes/overworld.tscn", "res://scenes/battle.tscn"]:
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	gm.preloaded_scenes.clear()

func run():
	var gm = root.get_node("GameManager")
	gm.init_party("israel")
	for id in ["javier", "tonazo", "juan_carlos"]:
		gm.add_hero_to_party(id)
	check(gm.get_apoyo_portrait().resource_path.ends_with("senor_apoyo_portrait.png"), "Healthy portrait must remain original")
	check(gm.get_apoyo_spritesheet_path().ends_with("senor_apoyo_spritesheet.png"), "Human sprites must remain original")
	for count in range(1, 11):
		gm.record_apoyo_defeat()
		check(gm.apoyo_defeat_count == count, "Each victory must count exactly once")
		check(gm.get_apoyo_taunt() == gm.APOYO_TAUNTS[(count - 1) % 4], "Israel's exact four lines must rotate")
		check(gm.apoyo_is_skeleton() == (count >= 10), "Skeleton must unlock only after ten victories")
		var bruised = gm.get_apoyo_portrait(true) as AtlasTexture
		check(bruised != null, "Human defeat portrait must show bruising")
		check(bruised.atlas.get_size().x == bruised.region.size.x * 2, "Bruise portrait must use one atlas cell")
	check(gm.get_apoyo_portrait().resource_path.ends_with("senor_apoyo_skeleton_portrait.png"), "Eleventh encounter must use the existing skeleton portrait")
	check(gm.get_apoyo_spritesheet_path().contains("skeleton"), "Eleventh encounter must use the comic skeleton sprite")
	# Exercise the actual JSON conversion that used to break character visuals.
	var save_data = JSON.parse_string(JSON.stringify({
		"selected_hero_id": "israel", "characters_data": gm.characters_data,
		"party_ids": ["israel", "javier", "tonazo", "juan_carlos"],
		"apoyo_defeat_count": 10, "intro_cutscene_done": true,
		"office_cutscene_done": true, "player_saved_position_x": 1100,
		"player_saved_position_y": 220
	}))
	check(gm.restore_save_data(save_data), "Save data must load")
	check(gm.apoyo_defeat_count == 10, "Skeleton unlock must survive JSON load")
	for member in gm.party:
		check(member["battle_scale"] is Vector2 and member["overworld_scale"] is Vector2, "Saved scale must remain a Vector2")
		check(member["color"] is Color, "Saved hero color must remain a Color")
	gm.just_defeated_senor_apoyo = false
	gm.current_enemy_data = {"type": "senor_apoyo", "name": "El Señor", "hp": 1, "max_hp": 1, "atk": 1, "is_skeleton": true, "spritesheet_path": gm.get_apoyo_spritesheet_path()}
	var battle = gm.get_preloaded_scene("res://scenes/battle.tscn").instantiate()
	root.add_child(battle)
	current_scene = battle
	for i in range(5):
		await process_frame
	check(battle.battler_sprites.size() == 4, "Every recruited hero must have a battle sprite after loading")
	var arena: Rect2 = battle.hero_arena.get_global_rect()
	for sprite in battle.battler_sprites:
		var rect: Rect2 = sprite.get_rect()
		var rendered = Rect2(sprite.to_global(rect.position), rect.size * sprite.global_scale)
		check(sprite.is_visible_in_tree() and arena.encloses(rendered), "Hero must stay fully visible inside the combat arena")
	check(battle.boss_atlas.atlas.resource_path.contains("skeleton"), "Skeleton sheet must be installed in battle")
	check(battle.boss_frame_row == 6 and battle.boss_frame_col == 0, "Skeleton must idle facing right")
	if "--visual" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/apoyo-skeleton-party.png")
	# The transition must cover the old scene, load under black, then reveal it.
	gm.current_enemy_data["is_skeleton"] = false
	gm.just_defeated_senor_apoyo = true
	gm.dragon_boss_defeated = true
	gm.dragon_flee_cutscene_done = false
	gm.change_scene_with_fade(self, "res://scenes/overworld.tscn")
	check(gm.scene_transition_active and paused, "Fade must block gameplay immediately")
	await scene_changed
	var black = gm.get_node("SceneFade/Black")
	check(black.color.a > 0.99, "World must be loaded while the screen is fully black")
	var world = current_scene
	while gm.scene_transition_active:
		await process_frame
	check(not paused, "World must resume after fade-in")
	check(world.current_state == world.State.FREE_EXPLORE, "Returning from support fight must not trigger a final-boss sequence")
	check(world.dialog_speaker.text == "El Señor", "Return must show only the support encounter dialogue")
	check(world.dialog_message.text == "¿Me... apoyas?", "Even after defeat he must still ask for help")
	check(world.dialog_portrait.texture is AtlasTexture, "Tenth defeat must still show bruised human in postfight dialogue")
	world._advance_dialog()
	check(world.dialog_speaker.text == "Israel" and world.dialog_message.text == gm.get_apoyo_taunt(), "Israel's current taunt must follow the damaged portrait")
	world._advance_dialog()
	world._update_stationed_companions()
	for hero_id in world.companion_nodes:
		var actor = world.companion_nodes[hero_id]
		check(actor.visible == not gm.is_hero_in_party(hero_id), "Recruited heroes must disappear from the overworld")
	check(world.enemy_printer.get_parent() == world.get_node("PrinterTable"), "Printer must be grouped with its table")
	check(world.enemy_printer.get_index() > world.get_node("PrinterTable/Sprite").get_index(), "Printer must draw above the tabletop")
	if "--visual" in OS.get_cmdline_user_args():
		world.player.can_move = false
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/apoyo-printer-table.png")
	world._start_senor_apoyo_dialog()
	check(world.dialog_message.text == "¿Me apoyas?", "Skeleton must keep his original catchphrase")
	check(world.dialog_portrait.texture.resource_path.contains("skeleton_portrait"), "Next encounter must now reveal skeleton portrait")
	world._advance_dialog()
	check(world.dialog_speaker.text == "Roberto Huerta", "An NPC must react to the first skeleton encounter")
	check(world.dialog_portrait.texture.resource_path.ends_with("roberto_huerta_portrait.png"), "The reaction must show Roberto's portrait")
	check(world.dialog_message.text == "Ya déjalo, ya está muerto.", "Roberto must say the requested skeleton line")
	world._advance_dialog()
	check(world.dialog_speaker.text == "Israel", "The normal encounter must continue after Roberto's reaction")
	world._start_senor_apoyo_dialog()
	check(world.dialog_queue.size() == 1 and world.dialog_queue[0]["speaker"] == "Israel", "The one-time skeleton reaction must not repeat")
	save_data["apoyo_skeleton_comment_seen"] = true
	gm.restore_save_data(save_data)
	check(gm.apoyo_skeleton_comment_seen, "The one-time reaction flag must survive loading")
	check(gm.APOYO_TAUNTS[1] == "No me duraste ni el arranque.", "The corrected Israel line must replace the old one")
	print("APOYO_EASTER_EGG_CHECKS failures=", failures.size())
	world.queue_free()
	await process_frame
	drain_preloads(gm)
	await process_frame
	quit(0 if failures.is_empty() else 1)
