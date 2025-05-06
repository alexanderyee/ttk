extends Control

const MAIN := "res://scenes/main.tscn"

@onready var new_run_button: Button = $MarginContainer/VBoxContainer2/NewRunButton
@onready var options_button: Button = $MarginContainer/VBoxContainer2/OptionsButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer2/QuitButton


func _on_new_run_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN)


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
