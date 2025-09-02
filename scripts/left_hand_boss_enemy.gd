class_name LeftHandBossEnemy extends Enemy

var movement_plane: BossMovementPlane
@onready var pause_movement_timer: Timer = $PauseMovementTimer
var current_cell: Vector2i
var cell_to_move_to: Vector2i 

func _ready():
	
	super._ready()

func _process(delta: float) -> void:
	if pause_movement_timer.is_stopped():
		pause_movement_timer.start(Global.rng.randf_range(1.0, 2.0))
	if cell_to_move_to:
		move_to_cell(delta)
	super._process(delta)
	
func set_movement_plane(plane: BossMovementPlane) -> void:
	movement_plane = plane

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


func _on_pause_movement_timer_timeout() -> void:
	# find a new cell on the boss movement plane and move to it
	if not current_cell:
		current_cell = movement_plane.get_center_cell()
	cell_to_move_to = movement_plane.get_random_cell(current_cell)
	
func move_to_cell(delta: float) -> void:
	return
