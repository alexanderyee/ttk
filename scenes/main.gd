extends Node3D

var active_enemy: Enemy
var active_enemy_panel: EnemyWordPanel
var words_typed = 0
var letters_typed = 0
var typos = 0
var total_active_typing_time_s = 0.0

@onready var stopwatch: Stopwatch = $Stopwatch
@onready var active_stopwatch: Stopwatch = $ActiveStopwatch
@onready var enemy_words_ui: EnemyWordsUI = $EnemyWordsUI
@onready var player: Player = $Player
@onready var ui: UI = $UI
@onready var sfx_player: SFXPlayer = $SFXPlayer
@onready var enemy_spawner: Node3D = $EnemySpawner

func _ready() -> void:
	active_stopwatch.start()
	active_stopwatch.pause()
	enemy_spawner.connect("word_added", _on_enemy_spawner_word_added)
	pass

func _process(delta: float) -> void:
	if active_enemy_panel:
		if active_stopwatch.is_paused():
			active_stopwatch.unpause()
	else:
		active_stopwatch.pause()

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
			var is_letter_typed_correct: bool = active_enemy_panel.letter_typed(letter_typed)
			if is_letter_typed_correct:
				letters_typed += 1
			else:
				typos += 1
				# play typo sfx
				sfx_player.play_sfx(SFXPlayer.SFX.TYPO)
				

func sort_enemies_by_distance_ascending(a: Enemy, b: Enemy):
	return (player.position - a.position).length() < (player.position - b.position).length()

func on_enemy_word_typed(word: String):
	words_typed += 1
	active_enemy = null
	active_enemy_panel = null
	# update ui
	var wpm: float = words_typed / stopwatch.get_time() * 60.0
	var ttk: float = active_stopwatch.get_time() / words_typed
	ui.update_wpm(roundi(wpm))
	ui.update_words_typed(words_typed)
	ui.update_ttk(ttk)
	ui.update_accuracy((float(letters_typed) - typos) / letters_typed * 100)
	# play word typed sfx
	sfx_player.play_sfx(SFXPlayer.SFX.WORD_TYPED)
	
func _on_enemy_spawner_word_added(enemy: Enemy, word: String):
	enemy.connect("damage_dealt", _on_enemy_damage_dealt)
	
func _on_enemy_damage_dealt(dmg: int):
	var player_died = player.damage_dealt(dmg)
	ui.update_health(player.get_current_health(), player.get_total_health())
