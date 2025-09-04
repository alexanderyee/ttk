class_name LeftHandBossEnemy extends Enemy

var movement_plane: BossMovementPlane
var current_cell: Vector2i
var cell_to_move_to: Vector2i 
var moving_time := 0.0
var total_move_time := 2.5
@onready var pause_movement_timer: Timer = $PauseMovementTimer


func _ready():
	# we assume boss enemy spawn point is in the center of the movement plane
	current_cell = movement_plane.get_center_cell()
	super._ready()

func _process(delta: float) -> void:
	if pause_movement_timer.is_stopped() and cell_to_move_to == current_cell:
		pause_movement_timer.start(Global.rng.randf_range(1.0, 2.0))
	if cell_to_move_to != current_cell:
		move_to_cell(delta)
	
	# rotate to face the player (if model faces +X)
	var to_player = (player.global_position - global_position).normalized()
	look_at(global_position + Vector3(to_player.z, 0.0, -to_player.x), Vector3.UP)
	
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
	pause_movement_timer.stop()
	# find a new cell on the boss movement plane and move to it
	cell_to_move_to = movement_plane.get_random_cell(current_cell)
	moving_time = 0.0
	
func move_to_cell(delta: float) -> void:
	moving_time += delta
	var current_cell_pos = movement_plane.get_cell_center_global_position(current_cell.x, current_cell.y)
	var next_cell_pos = movement_plane.get_cell_center_global_position(cell_to_move_to.x, cell_to_move_to.y)
	var u = clamp(moving_time / total_move_time, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)
	
	global_position = current_cell_pos.lerp(next_cell_pos, u)
	if u >= 1.0:
		current_cell = cell_to_move_to
