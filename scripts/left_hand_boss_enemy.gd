class_name LeftHandBossEnemy extends Enemy

@export var movement_patterns: Array[BossMovement]
var current_pattern: BossMovement
var pattern_index: int = 0
var pattern_time: float = 0.0
var pattern_duration: float = 5.0

func _ready():
	_choose_new_pattern()
	super._ready()

func _process(delta: float) -> void:
	pattern_time += delta

	if pattern_time > pattern_duration:
		_choose_new_pattern()
	
	global_position = current_pattern.get_next_position(self, pattern_time, delta)

	super._process(delta)
	

func player_letter_typed(letter: String, dmg: float) -> bool:
	if not is_mouse_over():
		return false
	return super.player_letter_typed(letter, dmg)

func is_mouse_over() -> bool:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var camera := viewport.get_camera_3d()
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))

	if result and result.collider == self:
		return true

	return false
	
func play_hit_animation():
	is_hurt = true
	hurt_counter += 1
	
func _choose_new_pattern() -> void:
	pattern_index += 1
	current_pattern = movement_patterns[pattern_index % movement_patterns.size()]
	if current_pattern is HoverMovement:
		current_pattern.base_position = global_position
	pattern_time = 0.0
	pattern_duration = randf_range(3.5, 6.5)
