class_name Enemy
extends CharacterBody3D

signal damage_dealt

@export var speed := 1.0
@export var max_distance_from_player := 1.5
@export var time_until_dmg_s = 3.0
@export var damage := 10

var can_move := false
var mesh_material: Material
var saturation = 0.0 

@onready var player: CharacterBody3D = $"../Player"
@onready var label_anchor: Marker3D = $"Label Anchor"
@onready var mesh: MeshInstance3D = $Mesh
@onready var timer: Timer = $Timer


func _ready() -> void:
	# each enemy needs its own shader material
	var original_material = mesh.get_surface_override_material(0)
	mesh_material = original_material.duplicate()
	mesh.set_surface_override_material(0, mesh_material)


func _process(delta: float) -> void:
	if timer.is_stopped():
		timer.start(time_until_dmg_s)
		
	# set shader params
	var portion_time_left = timer.time_left / time_until_dmg_s
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
	


func get_label_anchor() -> Marker3D:
	return label_anchor


func _on_timer_timeout() -> void:
	# deal dmg to player
	damage_dealt.emit(damage)
