class_name Enemy
extends CharacterBody3D

signal damage_dealt(dmg: int)
signal enemy_died(enemy: Enemy)
signal word_added(enemy: Enemy, word: String)

enum DeathState {STILL_ALIVE, FAINTED, DEAD}

@export var speed := 1.0
@export var max_distance_from_player := 1.5
@export var damage_cycle_time = 3.0
@export var damage := 0
@export var current_health: float
@export var total_health := 1
@export var max_x_shake := .1
@export var noise : FastNoiseLite
@export var noise_speed := 50.0
@export var gravity_enabled := false

var can_move := false
var mesh_material: Material
var saturation := 0.0
var hurt_counter := 0
var is_hurt := false
var hurt_time := 0.0
var original_model_pos: Vector3
var current_dmg_taken := 0.0
var current_typo_count := 0
var word_tag : String
var is_word_set := false
var word_cycle_time : float
var death_state: DeathState = DeathState.STILL_ALIVE

@onready var model: Node3D = $model
@onready var body: MeshInstance3D = $model/Body
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var label_anchor: Marker3D = $"Label Anchor"
@onready var dmg_cycle_timer: Timer = $DamageCycleTimer
@onready var word_cycle_timer: Timer = $WordCycleTimer
@onready var enemy_word_canvas: EnemyWordCanvas = $EnemyWordCanvas

func _ready() -> void:
	connect("word_added", WordBank._on_enemy_word_added)
	
	original_model_pos = model.position
	
	current_health = total_health
	add_to_group("enemy")

func _process(delta: float) -> void:
	if dmg_cycle_timer.is_stopped() and death_state == DeathState.STILL_ALIVE and is_word_set:
		dmg_cycle_timer.start(damage_cycle_time)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and gravity_enabled:
		velocity += get_gravity() * delta
		
	move_and_slide()
	
func set_word() -> bool:
	if not word_tag:
		printerr("enemy word_tag hasn't been set!")
		return false

	# get word from word bank
	var word = WordBank.get_random_word_from_tag(word_tag)
	if not word or word.length() == 0:
		printerr("Could not find suitable word/phrase for word tag: ", word_tag)
		return false
	
	enemy_word_canvas.set_word(word)
	word_added.emit(self, word)
	current_typo_count = 0
	is_word_set = true
	return true
	
func set_active(is_active: bool = true) -> void:
	enemy_word_canvas.set_active(is_active)
	if death_state == DeathState.FAINTED:
		die()

func get_label_anchor() -> Marker3D:
	return label_anchor

func get_word_canvas() -> EnemyWordCanvas:
	return enemy_word_canvas

func get_word_panel() -> EnemyWordPanel:
	return enemy_word_canvas.get_word_panel()

func get_word() -> String:
	return get_word_panel().get_word()

func _on_timer_timeout() -> void:
	# deal dmg to player
	
	# we check here if enemy is actually already dead, since the enemy could already be despawning
	if current_health > 0:
		damage_dealt.emit(damage)



func update_health_ui() -> void:
	enemy_word_canvas.update_health(current_health, total_health, current_dmg_taken)

# process keystroke input by the player. returns whether or not the keystroke was correct 
func player_letter_typed(letter: String, dmg: float) -> bool:
	var keystroke_result: EnemyWordPanel.KeystrokeResult = get_word_panel().letter_typed(letter)
	if keystroke_result == EnemyWordPanel.KeystrokeResult.TYPO:
		current_typo_count += 1
		return false
		
			
	if death_state == DeathState.STILL_ALIVE:
		take_damage(dmg)
	
	if keystroke_result == EnemyWordPanel.KeystrokeResult.PHRASE_COMPLETED:
		enemy_word_canvas.set_taken_damage_done()
		is_word_set = false
		current_dmg_taken = 0
		dmg_cycle_timer.stop()
		enemy_word_canvas.set_word_completed_text(current_typo_count)
		play_hit_animation()
		if current_health <= 0:
			die()
		else:
			# start dmg_cycle_timer for spawning next word
			word_cycle_timer.start(word_cycle_time)

	return true
	
# handle animations for getting hit
func play_hit_animation() -> void:
	if death_state == DeathState.STILL_ALIVE:
		model.position.z = original_model_pos.z
		var start_pos := model.global_position
		var back_pos := start_pos + Vector3(0, 0, -0.5)
		var end_rotation_z = (-1.0 if hurt_counter % 2 == 0 else 1.0) * Global.rng.randf_range(5.0, 12.0)
		var end_rotation := Vector3(0, 0, end_rotation_z)
		var tween := create_tween()
		tween.set_parallel()
		# push back
		tween.tween_property(model, "global_transform:origin:z", back_pos.z, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		# rotate
		tween.tween_property(model, "rotation_degrees", end_rotation, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	is_hurt = true
	hurt_counter += 1


func take_damage(dmg: float) -> void:
	current_health -= dmg
	current_dmg_taken += dmg
	update_health_ui()
	if current_health <= 0:
		enemy_word_canvas.set_taken_damage_done()
		faint()
	
func _on_word_cycle_timer_timeout() -> void:
	set_word()
	word_cycle_timer.stop()

	
func faint() -> void:
	death_state = DeathState.FAINTED
	dmg_cycle_timer.stop()

	model.position.z = original_model_pos.z
	var start_pos := model.global_position
	var top_pos := start_pos + Vector3(0, 0.2, 0)
	var bottom_pos := start_pos + Vector3(0, -1.0, 0)
	var end_rotation_z = (-1.0 if hurt_counter % 2 == 0 else 1.0) * Global.rng.randf_range(5.0, 12.0)
	var end_rotation := Vector3(0, 0, 90)
	var tween := create_tween()
	# go up
	tween.tween_property(model, "global_transform:origin:y", top_pos.y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# rotate
	tween.tween_property(model, "rotation_degrees", end_rotation, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween = tween.set_parallel()
	tween.tween_property(model, "global_transform:origin:y", bottom_pos.y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func die() -> void:
	death_state = DeathState.DEAD
	dmg_cycle_timer.stop()
	
	var start_pos = global_transform.origin
	var peak_pos = start_pos + Vector3(0, 0.5, 0)
	var end_pos = start_pos + Vector3(0, -0.5, 0)
	
	var tween := create_tween()

	# Rise
	tween.tween_property(self, "global_transform:origin", peak_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Fall
	tween.tween_property(self, "global_transform:origin", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween = tween.set_parallel()

	
	# Free when done
	enemy_died.emit(self)
	tween.chain().tween_callback(self.queue_free)
	
