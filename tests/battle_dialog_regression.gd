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
	gm.current_enemy_data = {"type": "dragon_boss", "name": "El Señor del Dragón", "hp": 280, "max_hp": 280, "atk": 14}
	var battle = gm.get_preloaded_scene("res://scenes/battle.tscn").instantiate()
	root.add_child(battle)
	current_scene = battle
	await process_frame
	battle._show_boss_defeat_dialog(["Primer diálogo de prueba.", "Segundo diálogo de prueba."])
	await process_frame
	check(battle.battle_dialog_active, "Dialogue must mark the battle as modal")
	check(not battle.command_panel.is_visible_in_tree(), "Combat commands must be hidden during dialogue")
	check(not battle.battle_log_panel.is_visible_in_tree(), "Duplicate log must not appear under dialogue")
	var overlay = battle.get_node("BossDefeatDialog")
	var button = overlay.find_children("*", "Button", true, false)[0]
	button.pressed.emit()
	await process_frame
	await process_frame
	check(battle.battle_dialog_active, "Continue must advance to the second line without ending the dialogue")
	button.pressed.emit()
	await process_frame
	await process_frame
	check(not battle.battle_dialog_active, "Continue must close the final line immediately")
	check(battle.command_panel.is_visible_in_tree(), "Commands must return if battle is still running")
	battle.is_battle_over = true
	battle.boss_atlas.region = Rect2(5 * 128, 5 * 128, 128, 128)
	battle._show_boss_defeat_dialog(["¡Aghhh...! ¡No es la última vez que sabrán de mí! ¡Volveré por mi dragón impreso en 3D!"])
	await process_frame
	if "--visual" in OS.get_cmdline_user_args():
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/terra/OneDrive/Documentos/ChatGPT/macro/tmp/it-adventures-dragon-dialog.png")
	overlay = battle.get_node("BossDefeatDialog")
	button = overlay.find_children("*", "Button", true, false)[0]
	button.pressed.emit()
	await process_frame
	await process_frame
	check(not battle.command_panel.visible, "Commands must stay hidden after the boss is defeated")
	print("BATTLE_DIALOG_CHECKS failures=", failures.size())
	battle.queue_free()
	await process_frame
	for path in ["res://scenes/character_select.tscn", "res://scenes/overworld.tscn", "res://scenes/battle.tscn"]:
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	gm.preloaded_scenes.clear()
	await process_frame
	quit(0 if failures.is_empty() else 1)
