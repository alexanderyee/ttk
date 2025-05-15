class_name Enemy
extends CharacterBody3D

signal damage_dealt(dmg: int)
signal enemy_died(enemy: Enemy)

@export var speed := 1.0
@export var max_distance_from_player := 1.5
@export var damage_cycle_time = 3.0
@export var damage := 0
@export var health := 1

var can_move := false
var mesh_material: Material
var saturation = 0.0

@onready var player: CharacterBody3D = $"../Player"
@onready var label_anchor: Marker3D = $"Label Anchor"
@onready var mesh: MeshInstance3D = $Mesh
@onready var timer: Timer = $Timer
@onready var enemy_word_canvas: EnemyWordCanvas = $EnemyWordCanvas


func _ready() -> void:
	# each enemy needs its own shader material
	var original_material = mesh.get_surface_override_material(0)
	mesh_material = original_material.duplicate()
	mesh.set_surface_override_material(0, mesh_material)
	enemy_word_canvas.get_word_panel().connect("word_typed", _on_enemy_word_panel_word_typed)

func _process(delta: float) -> void:
	if timer.is_stopped():
		timer.start(damage_cycle_time)
		
	# set shader params
	var portion_time_left = timer.time_left / damage_cycle_time
	var shader_intensity = 1.0 - portion_time_left
	mesh_material.set("shader_parameter/intensity", shader_intensity)
	mesh_material.set("shader_parameter/is_flashing", portion_time_left < 0.5 and portion_time_left > 0.2)
	mesh_material.set("shader_parameter/is_flashing_fast", portion_time_left < 0.2)
	
	if can_move:
		var vector_to_player := player.position - position
		can_move = vector_to_player.length() >= max_distance_from_player
		# move towards player
		if can_move:
			velocity = vector_to_player.normalized() * speed * Vector3(1, 0, 1)
		else:
			velocity = Vector3.ZERO
		move_and_slide()
	
func set_word(word: String) -> void:
	enemy_word_canvas.set_word(word)

func get_label_anchor() -> Marker3D:
	return label_anchor

func get_word_panel() -> EnemyWordPanel:
	return enemy_word_canvas.get_word_panel()

func _on_timer_timeout() -> void:
	# deal dmg to player
	damage_dealt.emit(damage)

func _on_enemy_word_panel_word_typed(word: String) -> void:
	# deal dmg to this enemy
	health -= 1
	if health <= 0:
		enemy_died.emit(self)
		die()

func die():
	var start_pos = global_transform.origin
	var peak_pos = start_pos + Vector3(0, 0.5, 0)
	var end_pos = start_pos + Vector3(0, -0.5, 0)
	
	var tween := create_tween()

	# Rise
	tween.tween_property(self, "global_transform:origin", peak_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Fall
	tween.tween_property(self, "global_transform:origin", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween = tween.set_parallel()
	# and fade out
	var mat := mesh.get_surface_override_material(0)
	tween.tween_method(func(fade): mat.set_shader_parameter("fade_amount", fade), 0.0, 1.0, 0.4).set_delay(0.1)
	
	# Free when done
	tween.chain().tween_callback(self.queue_free)
