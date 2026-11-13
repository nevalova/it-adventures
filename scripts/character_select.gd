extends Control

@onready var title_label = $MainContainer/HeaderBox/TitleLabel
@onready var subtitle_label = $MainContainer/HeaderBox/SubtitleLabel
@onready var cards_container = $MainContainer/ContentBox/CardsContainer
@onready var portrait_rect = $MainContainer/ContentBox/PreviewPanel/MarginContainer/HBoxDetails/PortraitBox/PortraitFrame/PortraitRect
@onready var name_label = $MainContainer/ContentBox/PreviewPanel/MarginContainer/HBoxDetails/VBoxInfo/NameLabel
@onready var role_label = $MainContainer/ContentBox/PreviewPanel/MarginContainer/HBoxDetails/VBoxInfo/RoleLabel
@onready var desc_label = $MainContainer/ContentBox/PreviewPanel/MarginContainer/HBoxDetails/VBoxInfo/DescLabel
@onready var stats_label = $MainContainer/ContentBox/PreviewPanel/MarginContainer/HBoxDetails/VBoxInfo/StatsLabel
@onready var mechanic_label = $MainContainer/ContentBox/PreviewPanel/MarginContainer/HBoxDetails/VBoxInfo/MechanicLabel
@onready var select_button = $MainContainer/BottomBox/SelectButton

var character_keys = ["javier", "tonazo", "israel", "juan_carlos", "alejandro"]
var current_selected_id = "javier"

func _ready():
	setup_cards()
	update_preview(current_selected_id)
	select_button.pressed.connect(_on_confirm_selection)

func setup_cards():
	for child in cards_container.get_children():
		child.queue_free()
		
	# Mostramos los 5 personajes de IT
	for id in character_keys:
		var data = GameManager.characters_data[id]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(120, 42)
		btn.text = data["name"] + "\n[" + data["role"].substr(0, 12) + "]"
		btn.tooltip_text = data["title"]
		
		var style = StyleBoxFlat.new()
		style.bg_color = data["color"].darkened(0.6)
		style.border_color = data["color"]
		style.border_width_bottom = 2
		style.border_width_top = 2
		style.border_width_left = 2
		style.border_width_right = 2
		style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal", style)
		
		btn.pressed.connect(func():
			current_selected_id = id
			update_preview(id)
		)
		cards_container.add_child(btn)

func update_preview(char_id: String):
	var data = GameManager.characters_data[char_id]
	name_label.text = data["name"].to_upper()
	role_label.text = data["role"] + " - " + data["title"]
	desc_label.text = data["description"]
	stats_label.text = "HP: %d  |  ATQ: %d  |  DEF: %d" % [data["max_hp"], data["atk"], data["def"]]
	
	if ResourceLoader.exists(data.get("portrait_path", "")):
		portrait_rect.texture = load(data["portrait_path"])
	
	if char_id == "javier":
		mechanic_label.text = "★ HABILIDAD ESPECIAL:\n'Ataca un turno sí y otro no' (Descansa en turnos pares viendo memes/café, ¡daño brutal en turnos impares!)"
		mechanic_label.modulate = Color(1, 0.9, 0.2)
	else:
		mechanic_label.text = "★ HABILIDAD ESPECIAL:\n" + data["special_move_name"]
		mechanic_label.modulate = Color(0.7, 0.9, 1.0)

func _on_confirm_selection():
	GameManager.init_party(current_selected_id)
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")
