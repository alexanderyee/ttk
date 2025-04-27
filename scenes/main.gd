extends Node3D

var active_enemy: Enemy
var active_enemy_panel: EnemyWordPanel
var words_typed = 0

@onready var stopwatch: Stopwatch = $Stopwatch
@onready var enemy_words_ui: EnemyWordsUI = $EnemyWordsUI
@onready var player: CharacterBody3D = $Player
@onready var ui: UI = $UI


func _ready() -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_pressed():
		
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		var letter_typed := OS.get_keycode_string(keycode).to_lower()
		
		if not active_enemy:
			# find all enemies whose first char matches the typed letter
			var enemy_word_panels = enemy_words_ui.get_enemy_word_panels_dict()
			var matching_enemies = []
			for enemy in enemy_word_panels:
				var enemy_word_panel : EnemyWordPanel = enemy_word_panels[enemy]
				var enemy_first_char = enemy_word_panel.get_word()[0]
				if enemy_first_char == letter_typed:
					matching_enemies.append(enemy)
			
			if matching_enemies.is_empty():
				return
			if matching_enemies.size() > 1:
				# if we have multiple enemies with the same first char, sort by dist from player
				# TODO change this to time til damage taken? we want to kill the enemies that are
				#	   about to shoot first	
				matching_enemies.sort_custom(sort_enemies_by_distance_ascending)
			
			active_enemy = matching_enemies[0]
			active_enemy_panel = enemy_word_panels[matching_enemies[0]]
			active_enemy_panel.word_typed.connect(on_enemy_word_typed)
			active_enemy_panel.set_active()
			
			# start stopwatch
			if not stopwatch.is_started():
				stopwatch.start()
			
		if active_enemy_panel:
			active_enemy_panel.letter_typed(letter_typed)
		
		pass

func sort_enemies_by_distance_ascending(a: Enemy, b: Enemy):
	return (player.position - a.position).length() < (player.position - b.position).length()

func on_enemy_word_typed(word: String):
	words_typed += 1
	active_enemy = null
	active_enemy_panel = null
	# update ui
	var wpm: float = words_typed / stopwatch.get_time() * 60.0
	ui.update_wpm(roundi(wpm))
	ui.update_words_typed(words_typed)
