extends Control

const MAIN_MENU = "res://scenes/main_menu.tscn"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
