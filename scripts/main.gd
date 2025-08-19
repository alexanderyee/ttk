extends Node3D


@export var time_per_level := 30.0 if not Global.DEBUG_MODE else 15.0
@export var debug_current_level := 1

var active_enemy: Enemy
var active_enemy_panel: EnemyWordPanel
var player_died := false
var perfect_word_counter := 0

@onready var stopwatch: Stopwatch = $GameSystems/Stopwatch
@onready var active_stopwatch: Stopwatch = $GameSystems/ActiveStopwatch
@onready var player: Player = $Player
@onready var ui: UI = $UI
@onready var sfx_player: SFXPlayer = $SFXPlayer
@onready var enemy_spawner: EnemySpawner = $GameSystems/EnemySpawner
@onready var player_death_screen: PlayerDeathScreen = $PlayerDeathScreen
@onready var level_timer: Timer = $GameSystems/LevelTimer
@onready var level_intermission_screen: LevelIntermissionScreen = $LevelIntermissionScreen
@onready var ui_damage_vignette: DamageVignette = $UI/DamageVignette
@onready var level_countdown_screen: LevelCountdownScreen = $LevelCountdownScreen
@onready var level_orchestrator: LevelOrchestrator = $GameSystems/LevelOrchestrator

func _ready() -> void:
	# connect any signals from children
	enemy_spawner.connect("enemy_spawned", _on_enemy_spawned)
	level_intermission_screen.connect("begin_next_level", _on_begin_next_level)
	level_countdown_screen.connect("countdown_finished", _on_level_countdown_finished)
	level_timer.wait_time = time_per_level

func _process(_delta: float) -> void:
	# intro sequence check
	if PlayerStats.get_current_level() == 0 and not level_countdown_screen.visible:
		if true:
			PlayerStats.set_current_level(debug_current_level)
		_on_begin_next_level()
	if active_enemy_panel:
		if active_stopwatch.is_paused():
			active_stopwatch.unpause()
	else:
		active_stopwatch.pause()
	
	ui.update_level_time(level_timer.wait_time - level_timer.time_left, level_timer.wait_time)
	
	# check if level has been completed
	if level_timer.is_stopped() and not level_countdown_screen.visible:
		# check if this is the last remaining enemy
		var no_enemies_remaining = enemy_spawner.get_enemies_count() <= 0
		if no_enemies_remaining and not level_intermission_screen.visible:
			# show level stats
			stopwatch.stop()
			active_stopwatch.stop()
			PlayerStats.add_level_time(stopwatch.get_time())
			PlayerStats.add_active_time(active_stopwatch.get_time())
			level_intermission_screen.update_stat_labels()
			level_intermission_screen.visible = true
			ui.hide_stats()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if player_died:
			return
		if event.is_action_pressed("switch_active"):
			# sort enemies by position, left to right then top to bottom
			# if no active enemy, select top-left most
			# else, make next enemy active
			var enemies_sorted_by_pos = enemy_spawner.get_enemies_sorted_by_pos()
			if not active_enemy:
				if enemies_sorted_by_pos.size() <= 0:
					return
				set_active_enemy(enemies_sorted_by_pos[0])
			else:
				var active_enemy_idx = -1
				for i in range(enemies_sorted_by_pos.size()):
					if enemies_sorted_by_pos[i] == active_enemy:
						active_enemy_idx = i
				
				if active_enemy_idx < 0:
					push_warning("unable to switch active enemy, active enemy not found!")
					return
				var next_enemy_idx = (active_enemy_idx + 1) % enemies_sorted_by_pos.size()
				unset_active_enemy(active_enemy)
				if active_enemy_idx != next_enemy_idx:
					set_active_enemy(enemies_sorted_by_pos[next_enemy_idx])
			return
		
		var letter_typed := char(event.unicode)
		
		if not active_enemy:
			var enemy_word_panels = enemy_spawner.get_words_set_enemy_word_panels_dict()
			var matching_enemies = []
			for enemy in enemy_word_panels:
				var enemy_word_panel : EnemyWordPanel = enemy_word_panels[enemy]
				var enemy_next_char = enemy_word_panel.get_word()[enemy_word_panel.letter_index]
				if enemy_next_char == letter_typed:
					matching_enemies.append(enemy)
		
			if matching_enemies.is_empty():
				return
			if matching_enemies.size() > 1:
				# if we have multiple enemies with the same first char, sort by dist from player
				# TODO change this to time til damage taken? we want to kill the enemies that are
				#	   about to shoot first. also could do enemies that have already been worked on
				matching_enemies.sort_custom(sort_enemies_by_distance_ascending)
			
			set_active_enemy(matching_enemies[0])
			
			# start stopwatch
			if not stopwatch.is_started():
				stopwatch.start()
			
		if active_enemy and letter_typed:
			var is_keystroke_correct: bool = active_enemy.player_letter_typed(letter_typed, player.damage)
			
			if is_keystroke_correct:
				PlayerStats.add_letters_typed(1)

			else:
				perfect_word_counter = 0
				PlayerStats.add_typos(1)
				# play typo sfx
				sfx_player.play_sfx(SFXPlayer.SFX.TYPO)
			if stopwatch.get_time() > 0.0:
				ui.update_wpm(roundi((PlayerStats.get_level_letters_typed() / 5.0) / (stopwatch.get_time() / 60.0)))
			ui.update_accuracy(PlayerStats.get_level_acc())
			
func set_active_enemy(enemy: Enemy) -> void:
	active_enemy = enemy
	active_enemy.set_active()
	active_enemy_panel = enemy_spawner.get_enemy_word_panel_from_enemy(enemy)

func unset_active_enemy(enemy: Enemy = null) -> void:
	active_enemy = null
	active_enemy_panel = null

	if enemy:
		enemy.set_active(false)

func sort_enemies_by_distance_ascending(a: Enemy, b: Enemy):
	return (player.position - a.position).length() < (player.position - b.position).length()

func _on_enemy_spawned(enemy: Enemy):
	enemy.connect("damage_dealt", _on_enemy_damage_dealt)
	enemy.connect("damage_dealt", ui_damage_vignette._on_enemy_damage_dealt)
	enemy.connect("enemy_died", _on_enemy_died)
	enemy.get_word_panel().word_typed.connect(on_enemy_word_typed)
	enemy.get_word_panel().word_typed.connect(WordBank._on_enemy_word_typed)

func on_enemy_word_typed(word: String):
	PlayerStats.add_words_typed(word)

	# update ui
	ui.update_words_typed(PlayerStats.get_level_words_typed())
	ui.update_ttk(active_stopwatch.get_time() / PlayerStats.get_level_enemies_killed())
	
	# play word typed sfx
	perfect_word_counter += 1
	if perfect_word_counter >= 5:
		sfx_player.play_sfx(SFXPlayer.SFX.PERFECT_WORD_5)
	else:
		sfx_player.play_sfx(SFXPlayer.SFX.get("PERFECT_WORD_" + str(perfect_word_counter)))

	unset_active_enemy()


func _on_enemy_died(_enemy: Enemy):
	PlayerStats.add_enemies_killed(1)
	

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
		ui.disable_damage_vignette()


func _on_level_timer_timeout() -> void:
	level_timer.stop()
	
	# despawn any remaining enemies, stop enemy spawner
	enemy_spawner.stop()
	
func _on_begin_next_level():
	level_orchestrator.transition_player_from_level(PlayerStats.get_current_level())
	level_intermission_screen.visible = false
	PlayerStats.increment_current_level()
	ui.update_level(PlayerStats.get_current_level())
	# clear stats ui
	ui.clear_stats()
	level_countdown_screen.visible = true
	level_countdown_screen.start_countdown(Global.LEVEL_COUNTDOWN_TIME)
	# clear existing words
	# TODO do this after each run once we have enough words and phrases
	WordBank.clear_existing_words()

func _on_level_countdown_finished() -> void:
	stopwatch.reset()
	active_stopwatch.reset()
	active_stopwatch.start()
	active_stopwatch.pause()
	enemy_spawner.start()
	level_timer.start(time_per_level)
	ui.show_stats()
	
