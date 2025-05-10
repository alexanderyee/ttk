extends Node3D

@export var time_per_level := 30.0

var active_enemy: Enemy
var active_enemy_panel: EnemyWordPanel
var player_died := false

@onready var stopwatch: Stopwatch = $Stopwatch
@onready var active_stopwatch: Stopwatch = $ActiveStopwatch
@onready var player: Player = $Player
@onready var ui: UI = $UI
@onready var sfx_player: SFXPlayer = $SFXPlayer
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var player_death_screen: PlayerDeathScreen = $PlayerDeathScreen
@onready var level_timer: Timer = $LevelTimer
@onready var level_intermission_screen: LevelIntermissionScreen = $LevelIntermissionScreen


func _ready() -> void:
	active_stopwatch.start()
	active_stopwatch.pause()
	enemy_spawner.connect("word_added", _on_enemy_spawner_word_added)
	level_intermission_screen.connect("begin_next_level", _on_begin_next_level)
	level_timer.start(time_per_level)
	enemy_spawner.start()


func _process(delta: float) -> void:
	if active_enemy_panel:
		if active_stopwatch.is_paused():
			active_stopwatch.unpause()
	else:
		active_stopwatch.pause()
	
	ui.update_level_time(level_timer.wait_time - level_timer.time_left, level_timer.wait_time)
	
	# check if level has been completed
	if level_timer.is_stopped():
		# check if this is the last remaining enemy
		var no_enemies_remaining := true
		for child in get_children():
			if child is Enemy:
				no_enemies_remaining = false
		if no_enemies_remaining and not level_intermission_screen.visible:
			# show level stats
			stopwatch.stop()
			active_stopwatch.stop()
			PlayerStats.add_level_time(stopwatch.get_time())
			PlayerStats.add_active_time(active_stopwatch.get_time())
			level_intermission_screen.update_stat_labels()
			level_intermission_screen.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if player_died:
			return
		
		var letter_typed := char(event.unicode)
		
		if not active_enemy:
			# find all enemies whose first char matches the typed letter
			var enemy_word_panels = enemy_spawner.get_enemy_word_panels_dict()
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
				PlayerStats.add_letters_typed(1)
				if stopwatch.get_time() > 0.0:
					ui.update_wpm(roundi((PlayerStats.get_level_letters_typed() / 5.0) / (stopwatch.get_time() / 60.0)))
				ui.update_accuracy(PlayerStats.get_level_acc())
			else:
				PlayerStats.add_typos(1)
				ui.update_accuracy(PlayerStats.get_level_acc())
				
				# play typo sfx
				sfx_player.play_sfx(SFXPlayer.SFX.TYPO)


func sort_enemies_by_distance_ascending(a: Enemy, b: Enemy):
	return (player.position - a.position).length() < (player.position - b.position).length()


func on_enemy_word_typed(word: String):
	PlayerStats.add_words_typed(word)
	# TODO update this when enemies can take mult. hits
	PlayerStats.add_enemies_killed(1)
	active_enemy = null
	active_enemy_panel = null

	# update ui
	ui.update_words_typed(PlayerStats.get_level_words_typed())
	ui.update_ttk(active_stopwatch.get_time() / PlayerStats.get_level_enemies_killed())
	
	# play word typed sfx
	sfx_player.play_sfx(SFXPlayer.SFX.WORD_TYPED)


func _on_enemy_spawner_word_added(enemy: Enemy, word: String):
	enemy.connect("damage_dealt", _on_enemy_damage_dealt)


func _on_enemy_damage_dealt(dmg: int):
	player_died = player.damage_dealt(dmg)
	ui.update_health(player.get_current_health(), player.get_total_health())
	
	if player_died:
		player_death()


func player_death():
	if not player_death_screen.visible:
		# TODO - dedupe with level timer timeout?
		stopwatch.stop()
		active_stopwatch.stop()
		PlayerStats.add_level_time(stopwatch.get_time())
		PlayerStats.add_active_time(active_stopwatch.get_time())
		player_death_screen.update_stat_labels()
		player_death_screen.visible = true
		level_timer.paused = true


func _on_level_timer_timeout() -> void:
	level_timer.stop()
	
	# despawn any remaining enemies, stop enemy spawner
	enemy_spawner.stop()
	
func _on_begin_next_level():
	PlayerStats.increment_current_level()
	level_intermission_screen.visible = false
	stopwatch.reset()
	active_stopwatch.reset()
	active_stopwatch.start()
	active_stopwatch.pause()
	enemy_spawner.start()
	level_timer.start(time_per_level)
	
	# clear stats ui
	ui.clear_stats()
