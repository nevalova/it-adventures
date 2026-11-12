extends Control

@onready var prompt_label = $PromptLabel

var blink_timer: float = 0.0

func _process(delta):
	blink_timer += delta * 4.0
	prompt_label.modulate.a = 0.4 + 0.6 * abs(sin(blink_timer))

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_tree().change_scene_to_file("res://scenes/character_select.tscn")
